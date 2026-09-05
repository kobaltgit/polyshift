# 🏗️ Архитектура и стек технологий

PolyShift спроектирован по принципу максимальной производительности, минимального веса и нулевого влияния на ресурсы компьютера.

---

## 💻 Стек технологий

* **Ядро (Backend)**: Rust (2021 edition) + Tauri v2
* **Фронтенд (UI)**: Svelte 5 + SvelteKit + TypeScript + Vite
* **Стилизация**: Custom Slate Dark CSS Design System (Glassmorphism, Windows Fluent Design вдохновение)
* **AI Провайдер**: Google Gemini REST API (v1beta) с прямым SSE-стримингом (`streamGenerateContent?alt=sse`)
* **Сборка инсталлятора**: NSIS (Nullsoft Scriptable Install System) через Tauri CLI

---

## 📐 Архитектурная схема

```mermaid
graph TD
    subgraph Windows System APIs
        Hotkeys[Win32: RegisterHotKey Alt+T/G/S/E]
        Clip[Win32: SendInput Ctrl+C & Clipboard]
        DPAPI[Win32 CryptoAPI: CryptProtectData]
        Mutex[Win32: CreateMutexW Single Instance]
    end

    subgraph Rust Core
        HotkeyThread[hotkeys.rs: Global Message Loop]
        GeminiClient[gemini.rs: Reqwest Async SSE Streaming]
        SettingsMgr[settings.rs: %APPDATA%/PolyShift/config.json]
        TrayMgr[tray.rs: Windows System Tray]
        UpdateMgr[updater.rs: GitHub Releases Checker]
    end

    subgraph Svelte 5 UI
        HUD[HudOverlay.svelte: Glass Window Near Cursor]
        Settings[SettingsFlyout.svelte: Configuration Window]
    end

    Hotkeys --> HotkeyThread
    HotkeyThread --> Clip
    Clip --> GeminiClient
    GeminiClient -->|app.emit stream-token| HUD
    SettingsMgr <--> DPAPI
    TrayMgr <--> Settings
    UpdateMgr -->|app.emit update-status| Settings
```

---

## ⚡ Оптимизации производительности

1. **Единичный экземпляр (Single Instance Mutex)**: При повторном клике на иконку не запускается дубликат процесса — системный мьютекс `Local\PolyShift_SingleInstance_Mutex` отсекает повторные запуски.
2. **Нулевой простой**: Окно HUD при скрытии не уничтожается, а прячется через Win32 API, благодаря чему повторное открытие по горячей клавише происходит за **< 5 миллисекунд**.
3. **Прямой стриминг токенов**: Парсинг JSON-чанков Gemini SSE происходит на лету в фоновом Tokio-потоке с мгновенной передачей в SvelteKit через внутреннюю шину событий Tauri.
