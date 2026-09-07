<p align="center">
  <img src="src-tauri/icons/128x128.png" width="96" height="96" alt="PolyShift Logo" />
  <h1 align="center">PolyShift</h1>
  <strong>Молниеносный нативный ИИ-помощник и переводчик у курсора для Windows 10 & 11 на Rust и Tauri v2.</strong><br/>
  <em>Blazing-fast native AI assistant & cursor HUD translator for Windows 10 & 11 built with Rust & Tauri v2.</em>
</p>

<p align="center">
  <a href="https://github.com/kobaltgit/polyshift/releases/latest"><img src="https://img.shields.io/github/v/release/kobaltgit/polyshift?color=38bdf8&label=Latest%20Release" alt="Latest Release" /></a>
  <a href="https://kobaltgit.github.io/polyshift/"><img src="https://img.shields.io/badge/Website-Flutter%20Web-02569B.svg?logo=flutter" alt="Live Website" /></a>
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg?logo=windows" alt="Windows 10/11" />
  <img src="https://img.shields.io/badge/Rust-2021%20Edition-DEA584.svg?logo=rust" alt="Rust 2021" />
  <img src="https://img.shields.io/badge/Tauri-v2.0-FFC131.svg?logo=tauri" alt="Tauri v2" />
  <img src="https://img.shields.io/badge/Frontend-Svelte%205%20(Runes)-FF3E00.svg?logo=svelte" alt="Svelte 5" />
  <img src="https://img.shields.io/badge/RAM-%3C%2020%20MB-34d399.svg" alt="Low RAM" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License" /></a>
</p>

<p align="center">
  <a href="#-о-проекте">🇷🇺 Русский</a> • <a href="#-about-the-project">🇬🇧 English</a> • <a href="#-экосистема-kobalt-tools">🌐 Экосистема</a>
</p>

---

## 🇷🇺 О проекте

**PolyShift** — сверхлегковесный нативный ИИ-помощник для Windows 10 & 11, входящий в экосистему системных инструментов **Kobalt Tools** ([StashIt](https://github.com/kobaltgit/StashIt), [MiniBin](https://github.com/kobaltgit/minibin), [Undoit](https://github.com/kobaltgit/undoit), [PeekIt](https://github.com/kobaltgit/peekit)).

Позволяет мгновенно переводить, редактировать стиль, делать краткую выжимку или объяснять любой выделенный текст прямо поверх активного окна без переключения в браузер. Ответы транслируются потоком в реальном времени через бесплатный API Google Gemini в полупрозрачном стеклянном HUD-оверлее.

Потребляет **всего 12–18 МБ RAM** в фоновом режиме благодаря нативному ядру на **Rust** и реактивному интерфейсу на **Svelte 5** под движком **Tauri v2**.

### ⚡ Сравнение с аналогами

| Параметр | PolyShift v2 | Electron-помощники | Браузерные переводчики |
| :--- | :--- | :--- | :--- |
| **Стек технологий** | **Rust + Tauri v2 + Svelte 5** | Node.js + Chromium + Electron | Вкладка Chrome/Edge |
| **ОЗУ в фоне** | **12–18 МБ** | 250–600 МБ | 150–300 МБ на вкладку |
| **Холодный запуск** | **~50 мс** | 1.5–3.0 сек | Зависит от браузера |
| **Размер дистрибутива** | **~4.5 МБ** | > 120 МБ | — |
| **Приватность API** | **Прямой TLS к Google (без прокси)** | Часто через сервера авторов | Серверы переводчика |
| **Шифрование ключей** | **Аппаратный Windows DPAPI** | Обычный текст / JSON | Cookie браузера |

### 🎯 Ключевые возможности

- 🌐 **Мгновенный перевод (`Alt + T`):** Перевод любого выделенного текста на родной язык с автокопированием в буфер обмена.
- ✍️ **Грамматика и полировка (`Alt + G`):** Исправление грамматики и стилистики на профессиональном английском без потери смысла.
- 📑 **Суммаризация (`Alt + S`):** 2–4 ёмких тезиса из гигантских статей, лонгридов или юридических документов.
- 💡 **Объяснение терминов и ошибок (`Alt + E`):** Доступное объяснение научных понятий или текста ошибок компилятора и консоли.
- 🔒 **Безопасность Windows DPAPI:** API-ключ шифруется аппаратно модулем `CryptProtectData` локального пользователя.
- 🪟 **Плавающий HUD-оверлей:** Перемещение окна мышью за заголовок, закрытие по `Esc`, поддержка темной и светлой темы.

### 📥 Установка и загрузка

Скачайте актуальную версию со [страницы последнего релиза](https://github.com/kobaltgit/polyshift/releases/latest):

- **Инсталлятор (`PolyShift_setup.exe` или `.msi`):** Быстрая установка без прав администратора.
- **Portable версия (`.zip`):** Запуск в один клик без инсталляции.

### 🔑 Быстрый старт с Google Gemini API (1 минута)

1. Получите бесплатный ключ на **[aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)** (официальный Free Tier Google, до 15 запросов в минуту, без карт и оплат).
2. Откройте «Настройки» в трее PolyShift (правый клик по иконке у часов).
3. Вставьте ключ и нажмите **«Проверить»** -> **«Сохранить»**.

---

## 🇬🇧 About the Project

**PolyShift** is an ultra-lightweight, native Windows 10 & 11 AI assistant and HUD translator, part of the **Kobalt Tools** desktop ecosystem ([StashIt](https://github.com/kobaltgit/StashIt), [MiniBin](https://github.com/kobaltgit/minibin), [Undoit](https://github.com/kobaltgit/undoit), [PeekIt](https://github.com/kobaltgit/peekit)).

It instantly translates, polishes grammar, summarizes, or explains any highlighted text across any application via low-latency global shortcuts. Powered by Google Gemini API with live token streaming inside a sleek Fluent acrylic overlay.

Consumes only **12–18 MB RAM** in background idle mode, built entirely with **Rust 2021** and **Svelte 5** under **Tauri v2**.

### ⚡ Key Benchmarks

| Metric | PolyShift v2 | Electron AI Apps | Browser Translators |
| :--- | :--- | :--- | :--- |
| **Tech Stack** | **Rust + Tauri v2 + Svelte 5** | Node.js + Chromium + Electron | Chrome / Edge Tab |
| **Idle RAM** | **12–18 MB** | 250–600 MB | 150–300 MB per tab |
| **Cold Launch** | **~50 ms** | 1.5–3.0 sec | Browser dependent |
| **Installer Size** | **~4.5 MB** | > 120 MB | — |
| **API Privacy** | **Direct client TLS to Google (zero proxy)** | Routed via author servers | Cloud servers |
| **Key Storage** | **Hardware Windows DPAPI** | Plain text / localStorage | Browser cookies |

### 🎯 Core Features

- 🌐 **Instant Cursor Translation (`Alt + T`):** Translates selected text directly at your mouse cursor with optional auto-clipboard copy.
- ✍️ **Grammar & Tone Polish (`Alt + G`):** Corrects grammar and refines text into professional English without altering core meaning.
- 📑 **Instant Summary (`Alt + S`):** Distills long articles, PDFs, or terms into 2–4 concise bullet points.
- 💡 **Explain & Debug (`Alt + E`):** Human-readable explanations of complex terms, stack traces, and compiler error logs.
- 🔒 **Hardware DPAPI Security:** API keys are encrypted via `CryptProtectData` tied exclusively to your Windows user account.
- 🪟 **Draggable Fluent HUD:** Acrylic translucent overlay, draggable by title, dismissed with `Esc`.

### 📥 Installation & Download

Download the latest release from [GitHub Releases](https://github.com/kobaltgit/polyshift/releases/latest):

- **Installer (`.exe` / `.msi`):** Pure user-mode install, no administrator prompts.
- **Portable (`.zip`):** Unpack and run anywhere.

---

## 🛠️ Сборка и разработка / Development

```bash
# 1. Установка зависимостей фронтенда
npm install

# 2. Запуск в режиме разработки (Hot Reload)
npm run tauri dev

# 3. Сборка релизного установщика
npm run tauri build
```

---

## 🌐 Экосистема Kobalt Tools

| Проект | Описание | Стек | Ссылки |
| :--- | :--- | :--- | :--- |
| 📥 **StashIt** | Плавающий карман Drag-and-Drop (Dropover / Yoink для Windows) | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/StashIt) • [Web](https://kobaltgit.github.io/StashIt/) |
| 🗑️ **MiniBin** | Умная корзина в системном трее с Flyout-интерфейсом | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/minibin) • [Web](https://kobaltgit.github.io/minibin/) |
| ⏱️ **Undoit** | Локальная машина времени и версионирование файлов (Ctrl+Z) | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/undoit) • [Web](https://kobaltgit.github.io/Undoit/) |
| 🌐 **PolyShift** | HUD-помощник и контекстный перевод у курсора с Gemini AI | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/polyshift) • [Web](https://kobaltgit.github.io/polyshift/) |
| 👁️ **PeekIt** | Мгновенный предпросмотр файлов по клавише Space | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/peekit) • [Web](https://kobaltgit.github.io/PeekIt/) |
| 🧩 **PeekIt Plugins** | Официальный реестр и SDK веб-плагинов для PeekIt | TypeScript + Web SDK | [Repo](https://github.com/kobaltgit/peekit-plugins) • [Web](https://kobaltgit.github.io/peekit-plugins/) |
| 🎨 **kobalt_ui** | Общая библиотека UI компонентов (шапка, футер, релизы) | Flutter Web (Dart) | [Repo](https://github.com/kobaltgit/kobalt_ui) |

---

## 📄 Лицензия / License

Распространяется под лицензией **MIT**. Подробнее в файле [LICENSE](LICENSE).  
Copyright (c) 2025–2026 Kobalt.
