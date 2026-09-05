<div align="center">

# 🌐 PolyShift (Полишифт)

**Молниеносный нативный ИИ-помощник для Windows 10/11.**  
*Мгновенный перевод, исправление стиля, суммаризация и объяснение выделенного текста по горячим клавишам.*

[![Release](https://img.shields.io/badge/release-v2.0.0-3B82F6.svg?style=for-the-badge)](https://github.com/kobaltgit/polyshift/releases)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6.svg?style=for-the-badge&logo=windows)](https://github.com/kobaltgit/polyshift)
[![Rust](https://img.shields.io/badge/core-Rust%202021-DEA584.svg?style=for-the-badge&logo=rust)](https://www.rust-lang.org/)
[![Tauri](https://img.shields.io/badge/framework-Tauri%20v2-24C8DB.svg?style=for-the-badge&logo=tauri)](https://tauri.app/)
[![Svelte](https://img.shields.io/badge/ui-Svelte%205-FF3E00.svg?style=for-the-badge&logo=svelte)](https://svelte.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)](LICENSE)

[**Скачать инсталлятор (.exe)**](https://github.com/kobaltgit/polyshift/releases) • [**Портабельная версия (.zip)**](https://github.com/kobaltgit/polyshift/releases) • [**Вики / Документация**](wiki/Home.md)

</div>

---

## ✨ Что такое PolyShift?

**PolyShift** — это легковесная системная утилита, созданная на замену громоздким веб-переводчикам и медленным расширениям.

Вам больше не нужно копировать текст, переключаться в браузер и вставлять его в онлайн-переводчик. Достаточно **выделить любой текст в любой программе** (браузере, коде, PDF, Discord, Word) и нажать сочетание клавиш — прямо возле курсора появится аккуратный полупрозрачный HUD-оверлей со стримингом перевода в реальном времени.

```
Выделили текст  ──►  Нажали Alt + T  ──►  Стриминг перевода за 200 мс прямо у курсора!
```

---

## 🚀 Ключевые возможности

* ⚡ **Сверхбыстрый отклик (< 5 мс)**: Окно HUD предзагружено в памяти и мгновенно позиционируется у курсора мыши.
* 🪶 **Экстремально лёгкий (~15 МБ RAM)**: Нативное Win32-ядро на Rust вместо тяжеловесного Electron, пожирающего сотни мегабайт.
* 🌊 **Потоковый SSE-стриминг**: Токены появляются на экране моментально по мере генерации языковой моделью.
* 🔒 **Аппаратное шифрование Windows DPAPI**: Ваш персональный API-ключ Gemini шифруется мастер-ключом вашей учётной записи Windows (`CryptProtectData`) и надёжно защищён.
* 🛡️ **Zero-Knowledge и приватность**: Прямое HTTPS-соединение между вашим ПК и серверами Google — никаких промежуточных прокси, логов или телеметрии автора.
* 📋 **Автокопирование**: Перевод автоматически помещается в буфер обмена для мгновенной вставки через `Ctrl + V`.
* 🔄 **Автообновления**: Фоновый модуль с защитой от спама и кулдауном проверяет новые версии на GitHub.
* 💎 **Кинематографичный дизайн**: Slate Dark палитра (`#0B1120`), глубокий Glassmorphism, акцентные неоновые контуры и читабельная типографика с поддержкой Markdown.

---

## ⌨️ Глобальные горячие клавиши

| Хоткей | Действие | Описание |
| :--- | :--- | :--- |
| **`Alt + T`** | **Умный перевод** | Мгновенный перевод на выбранный язык (по умолчанию — Русский, если текст на русском — переводит на English). |
| **`Alt + G`** | **Грамматика и стиль** | Исправление опечаток, пунктуации и улучшение стиля без искажения смысла. |
| **`Alt + S`** | **Суммаризация** | Выжимка ключевых тезисов длинного письма, документа или статьи. |
| **`Alt + E`** | **Объяснение и анализ** | Подробный разбор сложного термина, фрагмента кода или концепции простым языком. |
| **`Esc`** | **Скрыть оверлей** | Мгновенное закрытие плавающего окна. |

*Горячие клавиши работают глобально во всех приложениях Windows.*

---

## 📦 Установка и запуск

### Вариант 1: Установщик Windows (Рекомендуется)
1. Скачайте **`PolyShift_2.0.0_x64-setup.exe`** со страницы [Releases](https://github.com/kobaltgit/polyshift/releases).
2. Запустите установщик и следуйте подсказкам мастера.
3. PolyShift появится в автозагрузке и меню «Пуск».

### Вариант 2: Портабельная версия (Portable)
1. Скачайте **`PolyShift-v2.0.0-Portable-x64.zip`**.
2. Распакуйте архив в любую удобную папку.
3. Запустите `PolyShift.exe`.

---

## ⚙️ Первоначальная настройка

1. После запуска иконка PolyShift появится в **системном трее Windows** (возле часов).
2. Кликните правой кнопкой мыши по иконке трея и выберите **«Настройки»**.
3. В поле API-ключа вставьте ваш бесплатный ключ Google Gemini (получить ключ можно за 1 минуту в [Google AI Studio](https://aistudio.google.com/app/apikey)).
4. Нажмите **«Проверить»** — приложение замерит пинг и покажет задержку соединения.
5. Нажмите **«Сохранить настройки»**. PolyShift готов к работе!

---

## 🛠️ Сборка из исходников

### Требования:
- Windows 10 или 11 (x64)
- [Rust & Cargo](https://rustup.rs/) (стабильная ветка)
- [Node.js](https://nodejs.org/) (18.x или 20.x+)
- Visual Studio C++ Build Tools

### Команды:
```bash
# 1. Клонировать репозиторий
git clone https://github.com/kobaltgit/polyshift.git
cd polyshift

# 2. Установить зависимости UI
npm install

# 3. Запуск в режиме разработки с хот-релоадом
npm run tauri dev

# 4. Проверка типов и линтинг
npm run check
cd src-tauri && cargo check && cd ..

# 5. Сборка продакшен-дистрибутива (EXE + Setup)
npm run tauri build
```

---

## 🏛️ Архитектура

```mermaid
graph TD
    User([Выделение текста в любом окне]) -->|Alt+T / Alt+G / Alt+S / Alt+E| WinHotkey[Win32 RegisterHotKey]
    WinHotkey --> RustCore[Rust Backend / Tokio Runtime]
    RustCore --> Clip[Win32 SendInput Ctrl+C & Clipboard API]
    Clip --> Gemini[Google Gemini REST SSE streamGenerateContent]
    RustCore <--> DPAPI[Windows DPAPI CryptProtectData]
    Gemini -->|Tauri Event stream-token| SvelteHUD[Svelte 5 Glass HUD Overlay]
    RustCore --> Tray[Windows System Tray & Menu]
```

---

## 📄 Лицензия

Проект распространяется под свободной лицензией **MIT License**. Подробности в файле [LICENSE](LICENSE).

---

<div align="center">
Разработано с ❤️ для быстрого и комфортного чтения и работы на Windows.
</div>
