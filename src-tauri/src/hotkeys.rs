use crate::clipboard::{capture_selected_text, set_clipboard_text};
use crate::gemini::{execute_streaming_action, AiAction};
use crate::security::decrypt_string;
use crate::settings::load_settings;
use serde::Serialize;
use std::thread;
use tauri::{AppHandle, Emitter, Manager, PhysicalPosition};
use windows_sys::Win32::Foundation::{HWND, POINT};
use windows_sys::Win32::UI::Input::KeyboardAndMouse::{RegisterHotKey, UnregisterHotKey, MOD_ALT};
use windows_sys::Win32::UI::WindowsAndMessaging::{
    DispatchMessageW, GetCursorPos, GetMessageW, TranslateMessage, MSG, WM_HOTKEY,
};

const HOTKEY_TRANSLATE: i32 = 101; // Alt + T
const HOTKEY_GRAMMAR: i32 = 102;   // Alt + G
const HOTKEY_SUMMARIZE: i32 = 103; // Alt + S
const HOTKEY_EXPLAIN: i32 = 104;   // Alt + E

#[derive(Serialize, Clone)]
struct ActionPayload {
    action: AiAction,
    badge: &'static str,
    title: &'static str,
    source_text: String,
}

pub fn start_hotkey_thread(app: AppHandle) {
    thread::spawn(move || {
        unsafe {
            // Register global hotkeys
            RegisterHotKey(0 as HWND, HOTKEY_TRANSLATE, MOD_ALT as u32, 0x54); // 'T'
            RegisterHotKey(0 as HWND, HOTKEY_GRAMMAR, MOD_ALT as u32, 0x47);   // 'G'
            RegisterHotKey(0 as HWND, HOTKEY_SUMMARIZE, MOD_ALT as u32, 0x53); // 'S'
            RegisterHotKey(0 as HWND, HOTKEY_EXPLAIN, MOD_ALT as u32, 0x45);   // 'E'

            let mut msg: MSG = std::mem::zeroed();
            while GetMessageW(&mut msg, 0 as HWND, 0, 0) > 0 {
                if msg.message == WM_HOTKEY {
                    let hotkey_id = msg.wParam as i32;
                    let action = match hotkey_id {
                        HOTKEY_TRANSLATE => Some(AiAction::Translate),
                        HOTKEY_GRAMMAR => Some(AiAction::Grammar),
                        HOTKEY_SUMMARIZE => Some(AiAction::Summarize),
                        HOTKEY_EXPLAIN => Some(AiAction::Explain),
                        _ => None,
                    };

                    if let Some(act) = action {
                        handle_action_trigger(&app, act);
                    }
                }
                TranslateMessage(&msg);
                DispatchMessageW(&msg);
            }

            UnregisterHotKey(0 as HWND, HOTKEY_TRANSLATE);
            UnregisterHotKey(0 as HWND, HOTKEY_GRAMMAR);
            UnregisterHotKey(0 as HWND, HOTKEY_SUMMARIZE);
            UnregisterHotKey(0 as HWND, HOTKEY_EXPLAIN);
        }
    });
}

fn handle_action_trigger(app: &AppHandle, action: AiAction) {
    let app_clone = app.clone();

    // Run capture and API call on a separate worker
    thread::spawn(move || {
        let captured = match capture_selected_text() {
            Ok(text) => text,
            Err(err) => {
                show_hud_window(&app_clone);
                let _ = app_clone.emit("stream-error", &err);
                return;
            }
        };

        show_hud_window(&app_clone);

        let payload = ActionPayload {
            action,
            badge: action.badge(),
            title: action.title(),
            source_text: captured.clone(),
        };
        let _ = app_clone.emit("action-started", &payload);

        let settings = load_settings();
        let api_key = match decrypt_string(&settings.encrypted_api_key) {
            Ok(k) if !k.is_empty() => k,
            _ => {
                let _ = app_clone.emit(
                    "stream-error",
                    "API ключ не настроен. Откройте Настройки в трее и укажите ваш ключ Google Gemini.",
                );
                return;
            }
        };

        // Async execution of streaming action
        let app_handle_for_async = app_clone.clone();
        let target_lang = settings.target_language.clone();
        let model = settings.model.clone();
        let auto_copy = settings.auto_copy;

        tauri::async_runtime::spawn(async move {
            match execute_streaming_action(
                &app_handle_for_async,
                &api_key,
                &model,
                action,
                &captured,
                &target_lang,
            )
            .await
            {
                Ok(translated_text) => {
                    if auto_copy && !translated_text.is_empty() {
                        let _ = set_clipboard_text(&translated_text);
                    }
                }
                Err(_) => {}
            }
        });
    });
}

fn show_hud_window(app: &AppHandle) {
    if let Some(hud) = app.get_webview_window("hud") {
        // Position window near cursor
        unsafe {
            let mut pt: POINT = std::mem::zeroed();
            if GetCursorPos(&mut pt) != 0 {
                let pos_x = pt.x + 16;
                let pos_y = pt.y + 16;
                let _ = hud.set_position(PhysicalPosition::new(pos_x, pos_y));
            }
        }
        let _ = hud.show();
        let _ = hud.set_focus();
    }
}
