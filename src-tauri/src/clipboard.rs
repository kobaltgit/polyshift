use std::ptr;
use std::thread;
use std::time::Duration;
use windows_sys::Win32::Foundation::HWND;
use windows_sys::Win32::System::DataExchange::{
    CloseClipboard, EmptyClipboard, GetClipboardData, OpenClipboard, SetClipboardData,
};
use windows_sys::Win32::System::Memory::{GlobalAlloc, GlobalLock, GlobalUnlock, GMEM_MOVEABLE};
use windows_sys::Win32::UI::Input::KeyboardAndMouse::{
    SendInput, INPUT, INPUT_KEYBOARD, KEYBDINPUT, KEYEVENTF_KEYUP, VK_CONTROL, VK_MENU, VK_SHIFT,
};

const CF_UNICODETEXT: u32 = 13;

/// Safely captures highlighted text by releasing modifiers and simulating Ctrl+C.
pub fn capture_selected_text() -> Result<String, String> {
    // 1. Force release physical modifier keys (Alt, Ctrl, Shift)
    release_modifier_keys();
    thread::sleep(Duration::from_millis(40));

    // 2. Clear clipboard first to avoid reading stale data
    let _ = clear_clipboard();
    thread::sleep(Duration::from_millis(20));

    // 3. Send Ctrl + C
    simulate_ctrl_c();

    // 4. Wait for application to copy text (up to 300ms polling)
    for _ in 0..12 {
        thread::sleep(Duration::from_millis(25));
        if let Ok(text) = get_clipboard_text() {
            let trimmed = text.trim();
            if !trimmed.is_empty() {
                return Ok(trimmed.to_string());
            }
        }
    }

    Err("Не удалось захватить текст: убедитесь, что фрагмент выделен".into())
}

/// Sets unicode text directly to the Windows clipboard.
pub fn set_clipboard_text(text: &str) -> Result<(), String> {
    let wide: Vec<u16> = text.encode_utf16().chain(std::iter::once(0)).collect();
    let byte_len = wide.len() * 2;

    unsafe {
        if OpenClipboard(0 as HWND) == 0 {
            return Err("Cannot open clipboard to write".into());
        }

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
    unsafe {
        if OpenClipboard(0 as HWND) == 0 {
            return Err("Cannot open clipboard to read".into());
        }

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
    unsafe {
        if OpenClipboard(0 as HWND) != 0 {
            EmptyClipboard();
            CloseClipboard();
            Ok(())
        } else {
            Err("Cannot open clipboard to empty".into())
        }
    }
}

fn release_modifier_keys() {
    let keys = [VK_MENU, VK_CONTROL, VK_SHIFT];
    for &vk in &keys {
        let mut input = INPUT {
            r#type: INPUT_KEYBOARD,
            Anonymous: windows_sys::Win32::UI::Input::KeyboardAndMouse::INPUT_0 {
                ki: KEYBDINPUT {
                    wVk: vk,
                    wScan: 0,
                    dwFlags: KEYEVENTF_KEYUP,
                    time: 0,
                    dwExtraInfo: 0,
                },
            },
        };
        unsafe {
            SendInput(1, &mut input, std::mem::size_of::<INPUT>() as i32);
        }
    }
}

fn simulate_ctrl_c() {
    // KeyDown Ctrl, KeyDown 'C', KeyUp 'C', KeyUp Ctrl
    let mut inputs: [INPUT; 4] = [
        // Ctrl Down
        INPUT {
            r#type: INPUT_KEYBOARD,
            Anonymous: windows_sys::Win32::UI::Input::KeyboardAndMouse::INPUT_0 {
                ki: KEYBDINPUT {
                    wVk: VK_CONTROL,
                    wScan: 0,
                    dwFlags: 0,
                    time: 0,
                    dwExtraInfo: 0,
                },
            },
        },
        // 'C' Down (0x43)
        INPUT {
            r#type: INPUT_KEYBOARD,
            Anonymous: windows_sys::Win32::UI::Input::KeyboardAndMouse::INPUT_0 {
                ki: KEYBDINPUT {
                    wVk: 0x43,
                    wScan: 0,
                    dwFlags: 0,
                    time: 0,
                    dwExtraInfo: 0,
                },
            },
        },
        // 'C' Up
        INPUT {
            r#type: INPUT_KEYBOARD,
            Anonymous: windows_sys::Win32::UI::Input::KeyboardAndMouse::INPUT_0 {
                ki: KEYBDINPUT {
                    wVk: 0x43,
                    wScan: 0,
                    dwFlags: KEYEVENTF_KEYUP,
                    time: 0,
                    dwExtraInfo: 0,
                },
            },
        },
        // Ctrl Up
        INPUT {
            r#type: INPUT_KEYBOARD,
            Anonymous: windows_sys::Win32::UI::Input::KeyboardAndMouse::INPUT_0 {
                ki: KEYBDINPUT {
                    wVk: VK_CONTROL,
                    wScan: 0,
                    dwFlags: KEYEVENTF_KEYUP,
                    time: 0,
                    dwExtraInfo: 0,
                },
            },
        },
    ];

    unsafe {
        SendInput(
            inputs.len() as u32,
            inputs.as_mut_ptr(),
            std::mem::size_of::<INPUT>() as i32,
        );
    }
}
