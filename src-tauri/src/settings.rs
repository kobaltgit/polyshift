use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;
use winreg::enums::{HKEY_CURRENT_USER, KEY_SET_VALUE};
use winreg::RegKey;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AppSettings {
    pub encrypted_api_key: String,
    pub model: String,
    pub target_language: String,
    pub auto_copy: bool,
    pub auto_start: bool,
    pub auto_check_updates: bool,
    pub last_update_check_time: u64,
    pub last_notified_version: String,
}

impl Default for AppSettings {
    fn default() -> Self {
        Self {
            encrypted_api_key: String::new(),
            model: "gemini-2.5-flash".to_string(),
            target_language: "Русский".to_string(),
            auto_copy: true,
            auto_start: false,
            auto_check_updates: true,
            last_update_check_time: 0,
            last_notified_version: String::new(),
        }
    }
}

pub fn get_settings_path() -> PathBuf {
    let app_data = std::env::var("APPDATA").unwrap_or_else(|_| ".".to_string());
    let dir = PathBuf::from(app_data).join("PolyShift");
    let _ = fs::create_dir_all(&dir);
    dir.join("settings.json")
}

pub fn load_settings() -> AppSettings {
    let path = get_settings_path();
    if let Ok(data) = fs::read_to_string(&path) {
        if let Ok(settings) = serde_json::from_str::<AppSettings>(&data) {
            return settings;
        }
    }
    AppSettings::default()
}

pub fn save_settings(settings: &AppSettings) -> Result<(), String> {
    let path = get_settings_path();
    let json = serde_json::to_string_pretty(settings)
        .map_err(|e| format!("Failed to serialize settings: {}", e))?;
    fs::write(&path, json).map_err(|e| format!("Failed to write settings file: {}", e))?;

    // Update Windows autostart registry key if auto_start changed
    let _ = sync_autostart_registry(settings.auto_start);

    Ok(())
}

fn sync_autostart_registry(enable: bool) -> Result<(), String> {
    let hkcu = RegKey::predef(HKEY_CURRENT_USER);
    let path = r"Software\Microsoft\Windows\CurrentVersion\Run";
    let (key, _) = hkcu
        .create_subkey_with_flags(path, KEY_SET_VALUE)
        .map_err(|e| format!("Failed to open registry key: {}", e))?;

    let app_name = "PolyShift";

    if enable {
        if let Ok(current_exe) = std::env::current_exe() {
            let exe_str = current_exe.to_string_lossy().to_string();
            let _ = key.set_value(app_name, &exe_str);
        }
    } else {
        let _ = key.delete_value(app_name);
    }
    Ok(())
}
