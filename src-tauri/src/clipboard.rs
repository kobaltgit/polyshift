use std::ptr;
use std::thread;
use std::time::Duration;
use windows_sys::Win32::Foundation::HWND;
use windows_sys::Win32::System::DataExchange::{
    CloseClipboard, EmptyClipboard, GetClipboardData, GetClipboardSequenceNumber,
    IsClipboardFormatAvailable, OpenClipboard, SetClipboardData,
};
use windows_sys::Win32::System::Memory::{
    GlobalAlloc, GlobalLock, GlobalSize, GlobalUnlock, GMEM_MOVEABLE,
};
use windows_sys::Win32::UI::Input::KeyboardAndMouse::{
    GetAsyncKeyState, MapVirtualKeyW, SendInput, INPUT, INPUT_KEYBOARD, KEYBDINPUT,
    KEYEVENTF_KEYUP, MAPVK_VK_TO_VSC, VK_CONTROL, VK_MENU, VK_SHIFT,
};

const CF_DIB: u32 = 8;
const CF_UNICODETEXT: u32 = 13;

#[derive(Debug, Clone)]
pub enum CapturedInput {
    Text(String),
    ImagePng(Vec<u8>),
}

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

/// Captures user input robustly:
/// 1. Backs up any existing clipboard screenshot/image so it's not destroyed.
/// 2. Attempts to capture newly selected text via Ctrl+C.
/// 3. If no text was highlighted, checks if an image (screenshot from PrtScn / Win+Shift+S)
///    is present in the clipboard.
/// 4. Gracefully falls back to pre-existing text or returns a descriptive user guide error.
pub fn capture_input_robust() -> Result<CapturedInput, String> {
    // 0. Backup existing clipboard content (both text and image) before any manipulation
    let pre_existing_image = get_clipboard_image_png().ok();
    let pre_existing_text = get_clipboard_text().ok().unwrap_or_default();
    let initial_seq = unsafe { GetClipboardSequenceNumber() };

    // 1. Wait for physical keys (Alt, etc.) to be released by user's fingers (up to 150ms)
    wait_for_physical_modifier_release();

    // 2. Clear clipboard so we can definitively detect new text from Ctrl+C
    let _ = clear_clipboard();
    thread::sleep(Duration::from_millis(30));

    // 3. Send Ctrl + C with hardware scan codes and Alt-suppression
    simulate_ctrl_c_robust();

    // 4. Wait for application to copy text (up to 750ms polling for PDF readers / heavy apps)
    // 30 iterations * 25ms = 750ms maximum, returns instantly as soon as text is ready
    for _ in 0..30 {
        thread::sleep(Duration::from_millis(25));
        let current_seq = unsafe { GetClipboardSequenceNumber() };
        if current_seq != initial_seq {
            if let Ok(text) = get_clipboard_text() {
                let trimmed = text.trim();
                if !trimmed.is_empty() {
                    return Ok(CapturedInput::Text(trimmed.to_string()));
                }
            }
        }
    }

    // 5. Check if text arrived without sequence increment
    if let Ok(text) = get_clipboard_text() {
        let trimmed = text.trim();
        if !trimmed.is_empty() {
            return Ok(CapturedInput::Text(trimmed.to_string()));
        }
    }

    // 6. If no text was selected by Ctrl+C: Check if the user took a screenshot!
    if let Some(img_bytes) = pre_existing_image {
        return Ok(CapturedInput::ImagePng(img_bytes));
    }

    // Also check if an image is currently in the clipboard (e.g. placed during delay)
    if let Ok(img_bytes) = get_clipboard_image_png() {
        return Ok(CapturedInput::ImagePng(img_bytes));
    }

    // 7. Graceful fallback: If pre-existing text was present in clipboard before hotkey press
    let trimmed_pre = pre_existing_text.trim();
    if !trimmed_pre.is_empty() {
        let _ = set_clipboard_text(trimmed_pre);
        return Ok(CapturedInput::Text(trimmed_pre.to_string()));
    }

    Err("Не удалось захватить текст или скриншот: выделите текст или сделайте снимок экрана (Win + Shift + S)".into())
}

/// Backwards-compatible helper for text-only capture
#[allow(dead_code)]
pub fn capture_selected_text() -> Result<String, String> {
    match capture_input_robust()? {
        CapturedInput::Text(text) => Ok(text),
        CapturedInput::ImagePng(_) => {
            Err("В буфере обмена обнаружен скриншот, но запрошено только текстовое выделение".into())
        }
    }
}

/// Reads CF_DIB image from clipboard, constructs a valid BMP header,
/// decodes via `image` crate and encodes to high-quality compressed PNG bytes.
pub fn get_clipboard_image_png() -> Result<Vec<u8>, String> {
    unsafe {
        if IsClipboardFormatAvailable(CF_DIB) == 0 {
            return Err("В буфере обмена нет изображения".into());
        }
    }

    if !try_open_clipboard(8, 10) {
        return Err("Не удалось открыть буфер обмена для чтения изображения".into());
    }

    unsafe {
        let h_data = GetClipboardData(CF_DIB);
        if h_data.is_null() {
            CloseClipboard();
            return Err("Данные изображения отсутствуют в буфере".into());
        }

        let size = GlobalSize(h_data as _);
        if size < 40 {
            CloseClipboard();
            return Err("Размер данных DIB слишком мал".into());
        }

        let ptr = GlobalLock(h_data as _) as *const u8;
        if ptr.is_null() {
            CloseClipboard();
            return Err("Не удалось заблокировать память буфера".into());
        }

        let dib_bytes = std::slice::from_raw_parts(ptr, size);
        let result = convert_dib_to_png(dib_bytes);

        GlobalUnlock(h_data as _);
        CloseClipboard();

        result
    }
}

/// Converts raw Windows CF_DIB bytes to PNG
fn convert_dib_to_png(dib_bytes: &[u8]) -> Result<Vec<u8>, String> {
    if dib_bytes.len() < 40 {
        return Err("DIB data too short".into());
    }

    let bi_size = u32::from_le_bytes(
        dib_bytes[0..4]
            .try_into()
            .map_err(|_| "Failed to read biSize")?,
    ) as usize;

    if bi_size < 40 || bi_size > dib_bytes.len() {
        return Err(format!("Invalid biSize: {}", bi_size));
    }

    let bi_bit_count = u16::from_le_bytes(
        dib_bytes[14..16]
            .try_into()
            .map_err(|_| "Failed to read biBitCount")?,
    );
    let bi_compression = u32::from_le_bytes(
        dib_bytes[16..20]
            .try_into()
            .map_err(|_| "Failed to read biCompression")?,
    );
    let bi_clr_used = if bi_size >= 36 {
        u32::from_le_bytes(
            dib_bytes[32..36]
                .try_into()
                .map_err(|_| "Failed to read biClrUsed")?,
        ) as usize
    } else {
        0
    };

    let palette_size = if bi_clr_used != 0 {
        bi_clr_used * 4
    } else if bi_bit_count <= 8 {
        (1usize << bi_bit_count) * 4
    } else if bi_compression == 3 && bi_size == 40 {
        // BI_BITFIELDS with standard 40-byte BITMAPINFOHEADER has 3 RGB bitmasks (12 bytes)
        12
    } else {
        0
    };

    let bf_off_bits = 14 + bi_size + palette_size;
    let total_size = (14 + dib_bytes.len()) as u32;

    let mut bmp_data = Vec::with_capacity(14 + dib_bytes.len());
    bmp_data.extend_from_slice(b"BM");
    bmp_data.extend_from_slice(&total_size.to_le_bytes());
    bmp_data.extend_from_slice(&[0u8; 4]); // bfReserved1, bfReserved2
    bmp_data.extend_from_slice(&(bf_off_bits as u32).to_le_bytes());
    bmp_data.extend_from_slice(dib_bytes);

    let img = image::load_from_memory_with_format(&bmp_data, image::ImageFormat::Bmp)
        .map_err(|e| format!("Не удалось декодировать изображение из буфера: {}", e))?;

    // Optimize resolution if screenshot is extremely large (multi-monitor or 4K/8K)
    let (w, h) = (img.width(), img.height());
    let final_img = if w > 2560 || h > 2560 {
        img.resize(2560, 2560, image::imageops::FilterType::Triangle)
    } else {
        img
    };

    let mut png_bytes = Vec::new();
    final_img
        .write_to(
            &mut std::io::Cursor::new(&mut png_bytes),
            image::ImageFormat::Png,
        )
        .map_err(|e| format!("Не удалось упаковать PNG: {}", e))?;

    Ok(png_bytes)
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
