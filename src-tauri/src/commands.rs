use crate::clipboard::set_clipboard_text;
use crate::gemini::{default_fallback_models, list_models, ping_api_key, ModelInfo, PingResult};
use crate::security::{decrypt_string, encrypt_string};
use crate::settings::{load_settings, save_settings};
use crate::updater::{check_updates_with_cooldown, UpdateCheckResult};
use serde::{Deserialize, Serialize};
use tauri::{AppHandle, Manager};

#[derive(Serialize)]
pub struct SettingsDto {
    pub api_key: String, // Plaintext when returning to user's local UI
    pub model: String,
    pub target_language: String,
    pub auto_copy: bool,
    pub auto_start: bool,
    pub auto_check_updates: bool,
}

#[derive(Deserialize)]
pub struct SaveSettingsDto {
    pub api_key: String,
    pub model: String,
    pub target_language: String,
    pub auto_copy: bool,
    pub auto_start: bool,
    pub auto_check_updates: bool,
}

#[tauri::command]
pub fn get_settings() -> Result<SettingsDto, String> {
    let settings = load_settings();
    let api_key = decrypt_string(&settings.encrypted_api_key).unwrap_or_default();
    Ok(SettingsDto {
        api_key,
        model: settings.model,
        target_language: settings.target_language,
        auto_copy: settings.auto_copy,
        auto_start: settings.auto_start,
        auto_check_updates: settings.auto_check_updates,
    })
}

#[tauri::command]
pub fn save_app_settings(dto: SaveSettingsDto) -> Result<(), String> {
    let mut settings = load_settings();
    let encrypted = encrypt_string(&dto.api_key)?;

    settings.encrypted_api_key = encrypted;
    settings.model = dto.model;
    settings.target_language = dto.target_language;
    settings.auto_copy = dto.auto_copy;
    settings.auto_start = dto.auto_start;
    settings.auto_check_updates = dto.auto_check_updates;

    save_settings(&settings)?;
    Ok(())
}

#[tauri::command]
pub async fn ping_key(api_key: String) -> PingResult {
    ping_api_key(&api_key).await
}

#[tauri::command]
pub async fn fetch_models_from_api(api_key: Option<String>) -> Result<Vec<ModelInfo>, String> {
    let key = if let Some(k) = api_key {
        if !k.trim().is_empty() {
            k
        } else {
            let settings = load_settings();
            decrypt_string(&settings.encrypted_api_key).unwrap_or_default()
        }
    } else {
        let settings = load_settings();
        decrypt_string(&settings.encrypted_api_key).unwrap_or_default()
    };

    if key.trim().is_empty() {
        return Ok(default_fallback_models());
    }

    match list_models(&key).await {
        Ok(models) if !models.is_empty() => Ok(models),
        _ => Ok(default_fallback_models()),
    }
}

#[tauri::command]
pub fn check_updates(app: AppHandle) -> Result<UpdateCheckResult, String> {
    check_updates_with_cooldown(&app, true)
}

#[tauri::command]
pub fn copy_text(text: String) -> Result<(), String> {
    set_clipboard_text(&text)
}

#[tauri::command]
pub fn drag_hud(window: tauri::WebviewWindow) {
    let _ = window.start_dragging();
}

#[tauri::command]
pub fn hide_hud(app: AppHandle) {
    if let Some(hud) = app.get_webview_window("hud") {
        let _ = hud.hide();
    }
}

#[tauri::command]
pub fn hide_settings(app: AppHandle) {
    if let Some(win) = app.get_webview_window("settings") {
        let _ = win.hide();
    }
}

#[tauri::command]
pub fn exit_application(app: AppHandle) {
    app.exit(0);
}
