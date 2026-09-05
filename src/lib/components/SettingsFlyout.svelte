<script lang="ts">
  import { onMount } from 'svelte';
  import { 
    Key, 
    Sparkles, 
    Globe, 
    Zap, 
    RefreshCw, 
    Check, 
    ShieldCheck, 
    Eye, 
    EyeOff, 
    ExternalLink, 
    Download, 
    Cpu, 
    Sliders, 
    Info, 
    Keyboard, 
    CheckCircle2, 
    XCircle,
    X
  } from 'lucide-svelte';

  interface ModelInfo {
    id: string;
    display_name: string;
    description: string;
  }

  interface SettingsDto {
    api_key: string;
    model: string;
    target_language: string;
    auto_copy: boolean;
    auto_start: boolean;
    auto_check_updates: boolean;
  }

  interface PingResult {
    success: boolean;
    latency_ms: u64;
    models: ModelInfo[];
    error: string | null;
  }

  type u64 = number;

  let isTauri = $state(false);
  let activeTab = $state<'general' | 'behavior' | 'updates'>('general');

  // Form state
  let apiKey = $state('');
  let showApiKey = $state(false);
  let selectedModel = $state('gemini-2.5-flash');
  let targetLanguage = $state('Русский');
  let autoCopy = $state(true);
  let autoStart = $state(false);
  let autoCheckUpdates = $state(true);

  // Dynamic models list
  let availableModels = $state<ModelInfo[]>([
    { id: 'gemini-2.5-flash', display_name: 'Gemini 2.5 Flash (Рекомендуется)', description: 'Быстрая модель нового поколения' },
    { id: 'gemini-2.0-flash', display_name: 'Gemini 2.0 Flash', description: 'Сверхнизкая задержка' },
    { id: 'gemini-1.5-flash', display_name: 'Gemini 1.5 Flash', description: 'Стабильная и быстрая' },
    { id: 'gemini-1.5-pro', display_name: 'Gemini 1.5 Pro', description: 'Глубокий анализ контекста' },
  ]);

  // Statuses
  let isCheckingKey = $state(false);
  let pingResult = $state<{ ok: boolean; latency?: number; msg?: string } | null>(null);
  let isFetchingModels = $state(false);
  let isSaving = $state(false);
  let saveSuccess = $state(false);

  // Update check status
  let isCheckingUpdates = $state(false);
  let updateStatus = $state<{
    checked: boolean;
    hasUpdate: boolean;
    latestVersion?: string;
    releaseUrl?: string;
    msg?: string;
  }>({ checked: false, hasUpdate: false });

  const languageOptions = [
    'Русский',
    'English',
    'Deutsch',
    'Español',
    'Français',
    'Italiano',
    'Português',
    'Polski',
    'Українська',
    'Türkçe',
    '中文 (Упрощенный)',
    '日本語',
    '한국어'
  ];

  async function openUrl(url: string) {
    if (isTauri) {
      try {
        const { openUrl: tauriOpenUrl } = await import('@tauri-apps/plugin-opener');
        await tauriOpenUrl(url);
        return;
      } catch {}
    }
    window.open(url, '_blank');
  }

  async function loadSettingsData() {
    if (!isTauri) return;
    try {
      const { invoke } = await import('@tauri-apps/api/core');
      const settings = await invoke<SettingsDto>('get_settings');
      apiKey = settings.api_key;
      selectedModel = settings.model || 'gemini-2.5-flash';
      targetLanguage = settings.target_language || 'Русский';
      autoCopy = settings.auto_copy;
      autoStart = settings.auto_start;
      autoCheckUpdates = settings.auto_check_updates;

      // Also refresh models from API if key is present
      if (apiKey) {
        fetchModels();
      }
    } catch (e) {
      console.error('Failed to load settings', e);
    }
  }

  async function pingKey() {
    if (!apiKey.trim()) {
      pingResult = { ok: false, msg: 'Введите ключ для проверки' };
      return;
    }
    isCheckingKey = true;
    pingResult = null;

    try {
      if (isTauri) {
        const { invoke } = await import('@tauri-apps/api/core');
        const res = await invoke<PingResult>('ping_key', { apiKey: apiKey.trim() });
        if (res.success) {
          pingResult = { ok: true, latency: res.latency_ms };
          if (res.models && res.models.length > 0) {
            availableModels = res.models;
          }
        } else {
          pingResult = { ok: false, msg: res.error || 'Ошибка проверки ключа' };
        }
      } else {
        // Mock browser simulation
        await new Promise((r) => setTimeout(r, 600));
        pingResult = { ok: true, latency: 145 };
      }
    } catch (e: any) {
      pingResult = { ok: false, msg: e?.toString() || 'Ошибка запроса' };
    } finally {
      isCheckingKey = false;
    }
  }

  async function fetchModels() {
    isFetchingModels = true;
    try {
      if (isTauri) {
        const { invoke } = await import('@tauri-apps/api/core');
        const models = await invoke<ModelInfo[]>('fetch_models_from_api', { apiKey: apiKey.trim() });
        if (models && models.length > 0) {
          availableModels = models;
        }
      }
    } catch (e) {
      console.error('Failed to fetch models', e);
    } finally {
      isFetchingModels = false;
    }
  }

  async function checkForUpdates() {
    isCheckingUpdates = true;
    try {
      if (isTauri) {
        const { invoke } = await import('@tauri-apps/api/core');
        const res = await invoke<any>('check_updates');
        updateStatus = {
          checked: true,
          hasUpdate: res.has_update,
          latestVersion: res.latest_version,
          releaseUrl: res.release_url,
          msg: res.has_update ? `Доступна новая версия: ${res.latest_version}` : 'У вас установлена актуальная версия'
        };
      } else {
        await new Promise((r) => setTimeout(r, 700));
        updateStatus = {
          checked: true,
          hasUpdate: false,
          latestVersion: '2.0.0',
          msg: 'У вас установлена актуальная версия'
        };
      }
    } catch (e: any) {
      updateStatus = {
        checked: true,
        hasUpdate: false,
        msg: e?.toString() || 'Сбой проверки обновлений'
      };
    } finally {
      isCheckingUpdates = false;
    }
  }

  async function save() {
    isSaving = true;
    saveSuccess = false;

    try {
      if (isTauri) {
        const { invoke } = await import('@tauri-apps/api/core');
        await invoke('save_app_settings', {
          dto: {
            api_key: apiKey.trim(),
            model: selectedModel,
            target_language: targetLanguage,
            auto_copy: autoCopy,
            auto_start: autoStart,
            auto_check_updates: autoCheckUpdates
          }
        });
      }
      saveSuccess = true;
      setTimeout(() => { saveSuccess = false; }, 2500);
    } catch (e) {
      console.error('Failed to save settings', e);
    } finally {
      isSaving = false;
    }
  }

  async function closeSettings() {
    if (isTauri) {
      try {
        const { invoke } = await import('@tauri-apps/api/core');
        await invoke('hide_settings');
      } catch (e) {
        console.error(e);
      }
    }
  }

  onMount(async () => {
    try {
      const { invoke } = await import('@tauri-apps/api/core');
      isTauri = true;
      await loadSettingsData();
    } catch {
      isTauri = false;
    }
  });
</script>

<main class="settings-window">
  <!-- Window Header -->
  <header class="settings-header" data-tauri-drag-region>
    <div class="header-branding" data-tauri-drag-region>
      <div class="logo-box">
        <Sparkles size={16} color="#FFFFFF" />
      </div>
      <div>
        <h1 class="header-title">PolyShift</h1>
        <p class="header-subtitle">Настройки приложения • v2.0.0</p>
      </div>
    </div>

    <button class="close-btn" onclick={closeSettings} title="Закрыть настройки">
      <X size={16} />
    </button>
  </header>

  <!-- Navigation Tabs -->
  <nav class="settings-tabs">
    <button 
      class="tab-btn {activeTab === 'general' ? 'active' : ''}" 
      onclick={() => activeTab = 'general'}
    >
      <Sliders size={14} />
      <span>Основные</span>
    </button>
    <button 
      class="tab-btn {activeTab === 'behavior' ? 'active' : ''}" 
      onclick={() => activeTab = 'behavior'}
    >
      <Keyboard size={14} />
      <span>Поведение</span>
    </button>
    <button 
      class="tab-btn {activeTab === 'updates' ? 'active' : ''}" 
      onclick={() => activeTab = 'updates'}
    >
      <Download size={14} />
      <span>Обновления</span>
    </button>
  </nav>

  <!-- Scrollable Content Area -->
  <div class="settings-content">
    {#if activeTab === 'general'}
      <div class="tab-panel animate-fade-in">
        <!-- API Key Card -->
        <section class="config-card">
          <div class="card-header">
            <div class="card-icon-wrap">
              <Key size={16} class="card-icon" />
            </div>
            <div>
              <h2 class="card-title">Google Gemini API Ключ</h2>
              <p class="card-desc">Аппаратно шифруется Windows DPAPI и защищён локальной учётной записью</p>
            </div>
          </div>

          <div class="input-row">
            <div class="input-wrap">
              <input 
                type={showApiKey ? 'text' : 'password'} 
                class="text-input" 
                placeholder="Вставьте AIzaSy..."
                bind:value={apiKey}
                spellcheck="false"
              />
              <button 
                type="button"
                class="toggle-eye-btn" 
                onclick={() => showApiKey = !showApiKey}
                title={showApiKey ? 'Скрыть ключ' : 'Показать ключ'}
              >
                {#if showApiKey}
                  <EyeOff size={15} />
                {:else}
                  <Eye size={15} />
                {/if}
              </button>
            </div>

            <button 
              class="action-btn" 
              onclick={pingKey} 
              disabled={isCheckingKey}
            >
              {#if isCheckingKey}
                <RefreshCw size={14} class="animate-spin-slow" />
                <span>Проверка...</span>
              {:else}
                <Zap size={14} />
                <span>Проверить</span>
              {/if}
            </button>
          </div>

          <!-- Ping Feedback -->
          {#if pingResult}
            <div class="ping-status-banner {pingResult.ok ? 'success' : 'fail'} animate-fade-in">
              {#if pingResult.ok}
                <CheckCircle2 size={16} class="ping-icon" />
                <span>Ключ активен! Задержка ответа: <strong>{pingResult.latency} мс</strong></span>
              {:else}
                <XCircle size={16} class="ping-icon" />
                <span>{pingResult.msg}</span>
              {/if}
            </div>
          {/if}

          <div class="card-footer-tip">
            <ShieldCheck size={14} class="tip-icon" />
            <span>Нет ключа?</span>
            <button 
              class="link-button" 
              onclick={() => openUrl('https://aistudio.google.com/app/apikey')}
            >
              Получить бесплатно в Google AI Studio
              <ExternalLink size={12} />
            </button>
          </div>
        </section>

        <!-- AI Model Card -->
        <section class="config-card">
          <div class="card-header">
            <div class="card-icon-wrap">
              <Cpu size={16} class="card-icon" />
            </div>
            <div>
              <h2 class="card-title">Модель Gemini</h2>
              <p class="card-desc">Выберите модель для мгновенной потоковой генерации</p>
            </div>
            <button 
              class="refresh-icon-btn" 
              onclick={fetchModels} 
              disabled={isFetchingModels}
              title="Обновить список доступных моделей через API"
            >
              <RefreshCw size={13} class={isFetchingModels ? 'animate-spin-slow' : ''} />
            </button>
          </div>

          <div class="select-wrap">
            <select class="select-input" bind:value={selectedModel}>
              {#each availableModels as m}
                <option value={m.id}>{m.display_name} ({m.id})</option>
              {/each}
            </select>
          </div>
        </section>

        <!-- Target Language Card -->
        <section class="config-card">
          <div class="card-header">
            <div class="card-icon-wrap">
              <Globe size={16} class="card-icon" />
            </div>
            <div>
              <h2 class="card-title">Основной язык перевода</h2>
              <p class="card-desc">Язык, на который PolyShift будет переводить выделенный текст по Alt+T</p>
            </div>
          </div>

          <div class="select-wrap">
            <select class="select-input" bind:value={targetLanguage}>
              {#each languageOptions as lang}
                <option value={lang}>{lang}</option>
              {/each}
            </select>
          </div>
        </section>
      </div>

    {:else if activeTab === 'behavior'}
      <div class="tab-panel animate-fade-in">
        <!-- Automation Toggles -->
        <section class="config-card">
          <h2 class="card-title-standalone">Поведение и автоматизация</h2>

          <div class="toggle-row">
            <div>
              <div class="toggle-title">Автокопирование в буфер обмена</div>
              <div class="toggle-desc">Автоматически помещать готовый перевод в буфер обмена</div>
            </div>
            <label class="switch">
              <input type="checkbox" bind:checked={autoCopy} />
              <span class="slider"></span>
            </label>
          </div>

          <div class="toggle-divider"></div>

          <div class="toggle-row">
            <div>
              <div class="toggle-title">Автозапуск вместе с Windows</div>
              <div class="toggle-desc">Запускать PolyShift в системный трей при входе в систему</div>
            </div>
            <label class="switch">
              <input type="checkbox" bind:checked={autoStart} />
              <span class="slider"></span>
            </label>
          </div>

          <div class="toggle-divider"></div>

          <div class="toggle-row">
            <div>
              <div class="toggle-title">Фоновая проверка обновлений</div>
              <div class="toggle-desc">Проверять наличие свежих релизов с GitHub раз в неделю</div>
            </div>
            <label class="switch">
              <input type="checkbox" bind:checked={autoCheckUpdates} />
              <span class="slider"></span>
            </label>
          </div>
        </section>

        <!-- Hotkeys Cheatsheet -->
        <section class="config-card">
          <h2 class="card-title-standalone">Глобальные горячие клавиши Windows</h2>
          <div class="shortcuts-list">
            <div class="shortcut-item">
              <span class="shortcut-badge">Alt + T</span>
              <div class="shortcut-desc">
                <strong>Умный перевод</strong> — мгновенный перевод выделенного фрагмента
              </div>
            </div>
            <div class="shortcut-item">
              <span class="shortcut-badge">Alt + G</span>
              <div class="shortcut-desc">
                <strong>Грамматика и стиль</strong> — исправление опечаток и полировка тона текста
              </div>
            </div>
            <div class="shortcut-item">
              <span class="shortcut-badge">Alt + S</span>
              <div class="shortcut-desc">
                <strong>Суммаризация</strong> — краткая выжимка ключевых тезисов статьи или письма
              </div>
            </div>
            <div class="shortcut-item">
              <span class="shortcut-badge">Alt + E</span>
              <div class="shortcut-desc">
                <strong>Анализ и объяснение</strong> — разбор сложного термина, кода или концепции
              </div>
            </div>
          </div>
        </section>
      </div>

    {:else if activeTab === 'updates'}
      <div class="tab-panel animate-fade-in">
        <section class="config-card updates-center-card">
          <div class="version-badge-huge">
            <Sparkles size={28} color="#3B82F6" />
          </div>
          <h2 class="updates-app-name">PolyShift v2.0.0</h2>
          <p class="updates-app-desc">Нативный скоростной AI-ассистент для Windows (Tauri v2 + Rust + SvelteKit)</p>

          <div class="updates-action-box">
            <button 
              class="primary-update-btn" 
              onclick={checkForUpdates} 
              disabled={isCheckingUpdates}
            >
              {#if isCheckingUpdates}
                <RefreshCw size={15} class="animate-spin-slow" />
                <span>Проверяю GitHub...</span>
              {:else}
                <Download size={15} />
                <span>Проверить обновления</span>
              {/if}
            </button>
          </div>

          {#if updateStatus.checked}
            <div class="update-result-banner {updateStatus.hasUpdate ? 'has-update' : 'up-to-date'} animate-fade-in">
              {#if updateStatus.hasUpdate}
                <Info size={18} />
                <div>
                  <strong>Доступна новая версия: {updateStatus.latestVersion}</strong>
                  <div class="update-links">
                    <button class="link-button" onclick={() => openUrl(updateStatus.releaseUrl || 'https://github.com/kobaltgit/polyshift/releases')}>
                      Перейти к релизу на GitHub
                      <ExternalLink size={12} />
                    </button>
                  </div>
                </div>
              {:else}
                <CheckCircle2 size={18} color="#10B981" />
                <span>{updateStatus.msg}</span>
              {/if}
            </div>
          {/if}
        </section>
      </div>
    {/if}
  </div>

  <!-- Window Footer with Save Button -->
  <footer class="settings-footer">
    <div class="save-feedback">
      {#if saveSuccess}
        <div class="toast-success animate-fade-in">
          <Check size={14} />
          <span>Настройки успешно сохранены!</span>
        </div>
      {/if}
    </div>

    <div class="footer-btn-group">
      <button class="btn secondary-btn" onclick={closeSettings}>
        Закрыть
      </button>
      <button class="btn primary-btn" onclick={save} disabled={isSaving}>
        {#if isSaving}
          <RefreshCw size={14} class="animate-spin-slow" />
          <span>Сохранение...</span>
        {:else}
          <Check size={15} />
          <span>Сохранить настройки</span>
        {/if}
      </button>
    </div>
  </footer>
</main>

<style>
  .settings-window {
    width: 100vw;
    height: 100vh;
    display: flex;
    flex-direction: column;
    background: #0B1120;
    color: #F8FAFC;
    overflow: hidden;
  }

  /* Header */
  .settings-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    background: rgba(15, 23, 42, 0.7);
    border-bottom: 1px solid rgba(148, 163, 184, 0.1);
  }

  .header-branding {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .logo-box {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 0 15px rgba(59, 130, 246, 0.4);
  }

  .header-title {
    font-size: 16px;
    font-weight: 700;
    line-height: 1.2;
    color: #FFFFFF;
  }

  .header-subtitle {
    font-size: 11.5px;
    color: #94A3B8;
  }

  .close-btn {
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    border: none;
    border-radius: 6px;
    color: #94A3B8;
    cursor: pointer;
    transition: all 0.15s;
  }

  .close-btn:hover {
    background: rgba(239, 68, 68, 0.2);
    color: #FCA5A5;
  }

  /* Tabs */
  .settings-tabs {
    display: flex;
    gap: 4px;
    padding: 8px 16px 0;
    background: rgba(15, 23, 42, 0.4);
    border-bottom: 1px solid rgba(148, 163, 184, 0.1);
  }

  .tab-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 14px;
    background: transparent;
    border: none;
    border-bottom: 2px solid transparent;
    color: #94A3B8;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.15s;
  }

  .tab-btn:hover {
    color: #F8FAFC;
  }

  .tab-btn.active {
    color: #3B82F6;
    border-bottom-color: #3B82F6;
    font-weight: 600;
  }

  /* Content */
  .settings-content {
    flex: 1;
    overflow-y: auto;
    padding: 16px 20px;
  }

  .tab-panel {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  /* Config Card */
  .config-card {
    background: rgba(15, 23, 42, 0.6);
    border: 1px solid rgba(148, 163, 184, 0.12);
    border-radius: 12px;
    padding: 14px 16px;
    transition: border-color 0.2s;
  }

  .config-card:hover {
    border-color: rgba(59, 130, 246, 0.25);
  }

  .card-header {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    margin-bottom: 12px;
  }

  .card-icon-wrap {
    width: 28px;
    height: 28px;
    border-radius: 6px;
    background: rgba(59, 130, 246, 0.15);
    border: 1px solid rgba(59, 130, 246, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  :global(.card-icon) {
    color: #60A5FA;
  }

  .card-title {
    font-size: 13.5px;
    font-weight: 600;
    color: #F8FAFC;
    margin-bottom: 2px;
  }

  .card-title-standalone {
    font-size: 13.5px;
    font-weight: 600;
    color: #F8FAFC;
    margin-bottom: 14px;
  }

  .card-desc {
    font-size: 11.5px;
    color: #94A3B8;
    line-height: 1.35;
  }

  .refresh-icon-btn {
    margin-left: auto;
    background: transparent;
    border: 1px solid rgba(148, 163, 184, 0.15);
    border-radius: 6px;
    color: #94A3B8;
    width: 26px;
    height: 26px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
  }

  .refresh-icon-btn:hover {
    color: #3B82F6;
    border-color: #3B82F6;
  }

  /* Inputs */
  .input-row {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .input-wrap {
    position: relative;
    flex: 1;
  }

  .text-input {
    width: 100%;
    background: rgba(6, 11, 20, 0.7);
    border: 1px solid rgba(148, 163, 184, 0.15);
    border-radius: 8px;
    padding: 9px 36px 9px 12px;
    font-size: 13px;
    color: #F8FAFC;
    font-family: 'JetBrains Mono', monospace;
    outline: none;
    transition: border-color 0.2s, box-shadow 0.2s;
  }

  .text-input:focus {
    border-color: #3B82F6;
    box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.2);
  }

  .toggle-eye-btn {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    background: transparent;
    border: none;
    color: #64748B;
    cursor: pointer;
    display: flex;
    align-items: center;
    padding: 4px;
  }

  .toggle-eye-btn:hover {
    color: #CBD5E1;
  }

  .select-wrap {
    position: relative;
  }

  .select-input {
    width: 100%;
    background: rgba(6, 11, 20, 0.7);
    border: 1px solid rgba(148, 163, 184, 0.15);
    border-radius: 8px;
    padding: 9px 12px;
    font-size: 13px;
    color: #F8FAFC;
    outline: none;
    cursor: pointer;
    appearance: none;
    -webkit-appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2394A3B8' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 10px center;
  }

  .select-input:focus {
    border-color: #3B82F6;
  }

  .select-input option {
    background: #0F172A;
    color: #F8FAFC;
  }

  .action-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 9px 14px;
    background: rgba(59, 130, 246, 0.15);
    border: 1px solid rgba(59, 130, 246, 0.35);
    border-radius: 8px;
    color: #93C5FD;
    font-size: 12.5px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s;
    white-space: nowrap;
  }

  .action-btn:hover:not(:disabled) {
    background: rgba(59, 130, 246, 0.25);
    border-color: #3B82F6;
    color: #FFFFFF;
  }

  .action-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .ping-status-banner {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 10px;
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 12px;
  }

  .ping-status-banner.success {
    background: rgba(16, 185, 129, 0.12);
    border: 1px solid rgba(16, 185, 129, 0.3);
    color: #6EE7B7;
  }

  .ping-status-banner.fail {
    background: rgba(239, 68, 68, 0.12);
    border: 1px solid rgba(239, 68, 68, 0.3);
    color: #FCA5A5;
  }

  .card-footer-tip {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-top: 10px;
    font-size: 11.5px;
    color: #64748B;
  }

  :global(.tip-icon) {
    color: #10B981;
  }

  .link-button {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    background: none;
    border: none;
    color: #60A5FA;
    font-size: 11.5px;
    cursor: pointer;
    text-decoration: underline;
    padding: 0;
  }

  .link-button:hover {
    color: #93C5FD;
  }

  /* Toggles */
  .toggle-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
  }

  .toggle-title {
    font-size: 13px;
    font-weight: 600;
    color: #F8FAFC;
    margin-bottom: 2px;
  }

  .toggle-desc {
    font-size: 11.5px;
    color: #94A3B8;
  }

  .toggle-divider {
    height: 1px;
    background: rgba(148, 163, 184, 0.08);
    margin: 12px 0;
  }

  .switch {
    position: relative;
    display: inline-block;
    width: 40px;
    height: 22px;
    flex-shrink: 0;
  }

  .switch input {
    opacity: 0;
    width: 0;
    height: 0;
  }

  .slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #334155;
    transition: 0.2s;
    border-radius: 34px;
  }

  .slider:before {
    position: absolute;
    content: "";
    height: 16px;
    width: 16px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: 0.2s;
    border-radius: 50%;
  }

  input:checked + .slider {
    background-color: #3B82F6;
  }

  input:checked + .slider:before {
    transform: translateX(18px);
  }

  /* Shortcuts List */
  .shortcuts-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .shortcut-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 8px 10px;
    background: rgba(6, 11, 20, 0.5);
    border: 1px solid rgba(148, 163, 184, 0.08);
    border-radius: 8px;
  }

  .shortcut-badge {
    font-size: 11px;
    font-weight: 700;
    padding: 3px 8px;
    border-radius: 6px;
    background: rgba(59, 130, 246, 0.2);
    border: 1px solid rgba(59, 130, 246, 0.4);
    color: #93C5FD;
    font-family: 'JetBrains Mono', monospace;
    white-space: nowrap;
  }

  .shortcut-desc {
    font-size: 12px;
    color: #CBD5E1;
  }

  .shortcut-desc strong {
    color: #FFFFFF;
  }

  /* Updates panel */
  .updates-center-card {
    text-align: center;
    padding: 28px 16px;
  }

  .version-badge-huge {
    width: 56px;
    height: 56px;
    border-radius: 14px;
    background: rgba(59, 130, 246, 0.15);
    border: 1px solid rgba(59, 130, 246, 0.35);
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 12px;
    box-shadow: 0 0 20px rgba(59, 130, 246, 0.2);
  }

  .updates-app-name {
    font-size: 18px;
    font-weight: 700;
    color: #FFFFFF;
    margin-bottom: 4px;
  }

  .updates-app-desc {
    font-size: 12px;
    color: #94A3B8;
    max-width: 320px;
    margin: 0 auto 18px;
  }

  .primary-update-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 20px;
    background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%);
    border: none;
    border-radius: 8px;
    color: white;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(37, 99, 235, 0.35);
    transition: all 0.15s;
  }

  .primary-update-btn:hover:not(:disabled) {
    transform: translateY(-1px);
    box-shadow: 0 6px 18px rgba(37, 99, 235, 0.45);
  }

  .update-result-banner {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-top: 18px;
    padding: 12px 14px;
    border-radius: 10px;
    font-size: 12.5px;
    text-align: left;
  }

  .update-result-banner.up-to-date {
    background: rgba(16, 185, 129, 0.12);
    border: 1px solid rgba(16, 185, 129, 0.3);
    color: #A7F3D0;
  }

  .update-result-banner.has-update {
    background: rgba(59, 130, 246, 0.15);
    border: 1px solid rgba(59, 130, 246, 0.35);
    color: #BFDBFE;
  }

  .update-links {
    margin-top: 4px;
  }

  /* Footer */
  .settings-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 20px;
    background: rgba(15, 23, 42, 0.7);
    border-top: 1px solid rgba(148, 163, 184, 0.1);
  }

  .save-feedback {
    min-height: 24px;
  }

  .toast-success {
    display: flex;
    align-items: center;
    gap: 6px;
    color: #10B981;
    font-size: 12px;
    font-weight: 600;
  }

  .footer-btn-group {
    display: flex;
    gap: 8px;
  }

  .btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 14px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s;
  }

  .secondary-btn {
    background: transparent;
    border: 1px solid rgba(148, 163, 184, 0.2);
    color: #94A3B8;
  }

  .secondary-btn:hover {
    background: rgba(255, 255, 255, 0.06);
    color: #F8FAFC;
  }

  .primary-btn {
    background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%);
    border: 1px solid transparent;
    color: white;
    box-shadow: 0 2px 10px rgba(59, 130, 246, 0.3);
  }

  .primary-btn:hover:not(:disabled) {
    box-shadow: 0 4px 14px rgba(59, 130, 246, 0.45);
    transform: translateY(-1px);
  }

  .primary-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
</style>
