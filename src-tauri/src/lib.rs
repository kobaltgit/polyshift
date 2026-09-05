mod clipboard;
mod commands;
mod gemini;
mod hotkeys;
mod security;
mod settings;
mod single_instance;
mod tray;
mod updater;

use single_instance::NamedMutex;
use tauri::WindowEvent;

pub fn run() {
    // 1. Single instance lock: only one instance of PolyShift can run at a time
    let _mutex = match NamedMutex::try_acquire("Local\\PolyShift_SingleInstance_Mutex") {
        Some(m) => m,
        None => {
            // Already running; silently exit
            std::process::exit(0);
        }
    };

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            let handle = app.handle().clone();

            // 2. Initialize System Tray
            if let Err(e) = tray::setup_tray(&handle) {
                eprintln!("Failed to initialize system tray: {}", e);
            }

            // 3. Start Global Win32 Hotkey listener thread
            hotkeys::start_hotkey_thread(handle.clone());

            // 4. Start Background Update Checker thread (respects 1h cooldown, 7d period)
            updater::start_background_updater(handle.clone());

            Ok(())
        })
        .on_window_event(|window, event| {
            // When user closes settings window, hide it to tray instead of exiting
            if let WindowEvent::CloseRequested { api, .. } = event {
                if window.label() == "settings" {
                    api.prevent_close();
                    let _ = window.hide();
                } else if window.label() == "hud" {
                    api.prevent_close();
                    let _ = window.hide();
                }
            }
        })
        .invoke_handler(tauri::generate_handler![
            commands::get_settings,
            commands::save_app_settings,
            commands::ping_key,
            commands::fetch_models_from_api,
            commands::check_updates,
            commands::copy_text,
            commands::drag_hud,
            commands::hide_hud,
            commands::hide_settings,
            commands::exit_application
        ])
        .run(tauri::generate_context!())
        .expect("error while running PolyShift application");
}
