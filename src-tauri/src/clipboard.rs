use std::ptr;
use std::thread;
use std::time::Duration;
use windows_sys::Win32::Foundation::HWND;
use windows_sys::Win32::System::DataExchange::{
    CloseClipboard, EmptyClipboard, GetClipboardData, GetClipboardSequenceNumber, OpenClipboard,
    SetClipboardData,
};
use windows_sys::Win32::System::Memory::{GlobalAlloc, GlobalLock, GlobalUnlock, GMEM_MOVEABLE};
use windows_sys::Win32::UI::Input::KeyboardAndMouse::{
    GetAsyncKeyState, MapVirtualKeyW, SendInput, INPUT, INPUT_KEYBOARD, KEYBDINPUT,
    KEYEVENTF_KEYUP, MAPVK_VK_TO_VSC, VK_CONTROL, VK_MENU, VK_SHIFT,
};

const CF_UNICODETEXT: u32 = 13;

/// Attempts to open the clipboard with retries in case another process holds it.
fn try_open_clipboard(max_retries: u32, delay_ms: u64) -> bool {
    for _ in 0..max_retries {
        unsafe {
            if OpenClipboard(0 as HWND) != 0 {
                return true;
            }
        }
        thread::sleep(Duration::from_millis(delay_ms));
    }
    false
}

/// Safely captures highlighted text by waiting for physical key release,
/// suppressing the Win32 Alt-menu loop, and sending hardware scan codes.
pub fn capture_selected_text() -> Result<String, String> {
    // 0. Backup existing clipboard content as graceful fallback
    let pre_existing_text = get_clipboard_text().ok().unwrap_or_default();
    let initial_seq = unsafe { GetClipboardSequenceNumber() };

    // 1. Wait for physical keys (Alt, etc.) to be released by user's fingers (up to 150ms)
    wait_for_physical_modifier_release();

    // 2. Clear clipboard so we can definitively detect new text
    let _ = clear_clipboard();
    thread::sleep(Duration::from_millis(30));

    // 3. Send Ctrl + C with hardware scan codes and Alt-suppression
    simulate_ctrl_c_robust();

    // 4. Wait for application to copy text (up to 1000ms polling for PDF readers / heavy apps)
    // 40 iterations * 25ms = 1000ms maximum, returns instantly as soon as text is ready
    for _ in 0..40 {
        thread::sleep(Duration::from_millis(25));
        let current_seq = unsafe { GetClipboardSequenceNumber() };
        if current_seq != initial_seq {
            if let Ok(text) = get_clipboard_text() {
                let trimmed = text.trim();
                if !trimmed.is_empty() {
                    return Ok(trimmed.to_string());
                }
            }
        }
    }

    // 5. Final attempt: check if clipboard has text even if sequence didn't register
    if let Ok(text) = get_clipboard_text() {
        let trimmed = text.trim();
        if !trimmed.is_empty() {
            return Ok(trimmed.to_string());
        }
    }

    // 6. Graceful fallback: If synthetic Ctrl+C was blocked by the target app,
    // but the user had already copied text before pressing the hotkey, restore and use it!
    let trimmed_pre = pre_existing_text.trim();
    if !trimmed_pre.is_empty() {
        let _ = set_clipboard_text(trimmed_pre);
        return Ok(trimmed_pre.to_string());
    }

    Err("Не удалось захватить текст: убедитесь, что фрагмент выделен (или скопируйте его через Ctrl+C перед вызовом)".into())
}

/// Sets unicode text directly to the Windows clipboard.
pub fn set_clipboard_text(text: &str) -> Result<(), String> {
    let wide: Vec<u16> = text.encode_utf16().chain(std::iter::once(0)).collect();
    let byte_len = wide.len() * 2;

    if !try_open_clipboard(8, 10) {
        return Err("Cannot open clipboard to write".into());
    }

    unsafe {
        EmptyClipboard();

        let h_mem = GlobalAlloc(GMEM_MOVEABLE, byte_len);
        if h_mem.is_null() {
            CloseClipboard();
            return Err("GlobalAlloc failed for clipboard data".into());
        }

        let p_mem = GlobalLock(h_mem) as *mut u16;
        if p_mem.is_null() {
            CloseClipboard();
            return Err("GlobalLock failed for clipboard data".into());
        }

        ptr::copy_nonoverlapping(wide.as_ptr(), p_mem, wide.len());
        GlobalUnlock(h_mem);

        SetClipboardData(CF_UNICODETEXT, h_mem as _);
        CloseClipboard();
        Ok(())
    }
}

/// Reads current unicode text from Windows clipboard.
pub fn get_clipboard_text() -> Result<String, String> {
    if !try_open_clipboard(8, 10) {
        return Err("Cannot open clipboard to read".into());
    }

    unsafe {
        let h_data = GetClipboardData(CF_UNICODETEXT);
        if h_data.is_null() {
            CloseClipboard();
            return Err("Clipboard has no text".into());
        }

        let p_wide = GlobalLock(h_data as _) as *const u16;
        if p_wide.is_null() {
            CloseClipboard();
            return Err("Cannot lock clipboard memory".into());
        }

        let mut len = 0;
        while *p_wide.add(len) != 0 {
            len += 1;
        }

        let slice = std::slice::from_raw_parts(p_wide, len);
        let result = String::from_utf16_lossy(slice);

        GlobalUnlock(h_data as _);
        CloseClipboard();

        Ok(result)
    }
}

fn clear_clipboard() -> Result<(), String> {
    if try_open_clipboard(5, 10) {
        unsafe {
            EmptyClipboard();
            CloseClipboard();
        }
        Ok(())
    } else {
        Err("Cannot open clipboard to empty".into())
    }
}

/// Waits for physical modifier keys (Alt, Ctrl, Shift) to be released by user.
fn wait_for_physical_modifier_release() {
    for _ in 0..10 {
        let alt_down = unsafe { (GetAsyncKeyState(VK_MENU as i32) as u16 & 0x8000) != 0 };
        let ctrl_down = unsafe { (GetAsyncKeyState(VK_CONTROL as i32) as u16 & 0x8000) != 0 };
        let shift_down = unsafe { (GetAsyncKeyState(VK_SHIFT as i32) as u16 & 0x8000) != 0 };
        if !alt_down && !ctrl_down && !shift_down {
            break;
        }
        thread::sleep(Duration::from_millis(15));
    }
}

/// Sends Ctrl+C with full hardware scan codes.
/// Crucially, we press Ctrl DOWN first before releasing Alt/Shift,
/// which tells Windows this is a combo and prevents Win32 apps (like PDF-XChange Viewer)
/// from entering the menu bar loop (SC_KEYMENU).
fn simulate_ctrl_c_robust() {
    let ctrl_scan = unsafe { MapVirtualKeyW(VK_CONTROL as u32, MAPVK_VK_TO_VSC) } as u16;
    let c_scan = unsafe { MapVirtualKeyW(0x43, MAPVK_VK_TO_VSC) } as u16;
    let alt_scan = unsafe { MapVirtualKeyW(VK_MENU as u32, MAPVK_VK_TO_VSC) } as u16;
    let shift_scan = unsafe { MapVirtualKeyW(VK_SHIFT as u32, MAPVK_VK_TO_VSC) } as u16;

    let mut inputs: Vec<INPUT> = Vec::with_capacity(8);

    // 1. Press Ctrl DOWN first (suppresses Alt menu activation)
    inputs.push(create_key_input(VK_CONTROL, ctrl_scan, 0));

    // 2. Release Alt and Shift if held
    inputs.push(create_key_input(VK_MENU, alt_scan, KEYEVENTF_KEYUP));
    inputs.push(create_key_input(VK_SHIFT, shift_scan, KEYEVENTF_KEYUP));

    // 3. Press 'C' DOWN
    inputs.push(create_key_input(0x43, c_scan, 0));

    // 4. Release 'C' UP
    inputs.push(create_key_input(0x43, c_scan, KEYEVENTF_KEYUP));

    // 5. Release Ctrl UP
    inputs.push(create_key_input(VK_CONTROL, ctrl_scan, KEYEVENTF_KEYUP));

    unsafe {
        SendInput(
            inputs.len() as u32,
            inputs.as_mut_ptr(),
            std::mem::size_of::<INPUT>() as i32,
        );
    }
}

fn create_key_input(vk: u16, scan: u16, flags: u32) -> INPUT {
    INPUT {
        r#type: INPUT_KEYBOARD,
        Anonymous: windows_sys::Win32::UI::Input::KeyboardAndMouse::INPUT_0 {
            ki: KEYBDINPUT {
                wVk: vk,
                wScan: scan,
                dwFlags: flags,
                time: 0,
                dwExtraInfo: 0,
            },
        },
    }
}
