use crate::updater::check_updates_with_cooldown;
use tauri::{
    menu::{Menu, MenuItem, PredefinedMenuItem},
    tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent},
    AppHandle, Manager,
};

pub fn setup_tray(app: &AppHandle) -> Result<(), Box<dyn std::error::Error>> {
    let title_item = MenuItem::with_id(app, "title", "PolyShift v2.0", false, None::<&str>)?;
    let sep1 = PredefinedMenuItem::separator(app)?;

    let hotkey_info = MenuItem::with_id(
        app,
        "hotkeys",
        "Шорткаты: Alt+T (Перевод) | Alt+G | Alt+S | Alt+E",
        false,
        None::<&str>,
    )?;

    let settings_item = MenuItem::with_id(app, "settings", "⚙️ Настройки", true, None::<&str>)?;
    let check_update_item = MenuItem::with_id(
        app,
        "check_updates",
        "🔄 Проверить обновления",
        true,
        None::<&str>,
    )?;
    let sep2 = PredefinedMenuItem::separator(app)?;
    let quit_item = MenuItem::with_id(app, "quit", "❌ Выход", true, None::<&str>)?;

    let menu = Menu::with_items(
        app,
        &[
            &title_item,
            &sep1,
            &hotkey_info,
            &settings_item,
            &check_update_item,
            &sep2,
            &quit_item,
        ],
    )?;

    let tray = TrayIconBuilder::with_id("main-tray")
        .menu(&menu)
        .tooltip("PolyShift — Интеллектуальный помощник языков")
        .show_menu_on_left_click(false)
        .on_menu_event(|app, event| match event.id.as_ref() {
            "settings" => {
                show_settings_window(app);
            }
            "check_updates" => {
                let app_handle = app.clone();
                tauri::async_runtime::spawn(async move {
                    let _ = check_updates_with_cooldown(&app_handle, true);
                });
                show_settings_window(app);
            }
            "quit" => {
                app.exit(0);
            }
            _ => {}
        })
        .on_tray_icon_event(|tray, event| {
            if let TrayIconEvent::Click {
                button: MouseButton::Left,
                button_state: MouseButtonState::Up,
                ..
            } = event
            {
                show_settings_window(tray.app_handle());
            }
        });

    #[cfg(target_os = "windows")]
    let tray = tray.icon(app.default_window_icon().cloned().unwrap());

    tray.build(app)?;

    Ok(())
}

pub fn show_settings_window(app: &AppHandle) {
    if let Some(win) = app.get_webview_window("settings") {
        let _ = win.show();
        let _ = win.unminimize();
        let _ = win.set_focus();
    }
}
