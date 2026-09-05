# 🛠️ Сборка из исходников

Если вы хотите собрать PolyShift самостоятельно или внести изменения в код, следуйте этой инструкции.

---

## 📋 Требования к окружению

1. **Операционная система**: Windows 10 или Windows 11 (64-bit)
2. **Rust & Cargo**: актуальная стабильная версия ([rustup.rs](https://rustup.rs/))
3. **Node.js**: LTS версия (18.x или 20.x+) и менеджер пакетов `npm`
4. **C++ Build Tools**: Visual Studio 2022 C++ Build Tools (MSVC)
5. **WebView2**: предустановлен в Windows 10/11 по умолчанию

---

## 🚀 Пошаговая сборка

### 1. Клонирование репозитория
```bash
git clone https://github.com/kobaltgit/polyshift.git
cd polyshift
```

### 2. Установка зависимостей фронтенда
```bash
npm install
```

### 3. Запуск в режиме разработки (Hot-reload)
```bash
npm run tauri dev
```
В режиме разработки Vite и Cargo будут автоматически пересобирать изменения на лету при редактировании файлов Svelte или Rust.

### 4. Проверка типов и кода
```bash
# Проверка типов SvelteKit
npm run check

# Проверка Rust ядра
cd src-tauri
cargo check
```

### 5. Сборка продакшен-релиза
```bash
npm run tauri build
```
После сборки готовые исполняемые файлы будут находиться в:
* **Инсталлятор**: `src-tauri/target/release/bundle/nsis/PolyShift_2.0.0_x64-setup.exe`
* **Автономный EXE**: `src-tauri/target/release/polyshift.exe`
