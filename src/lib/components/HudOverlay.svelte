<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { marked } from 'marked';
  import { invoke } from '@tauri-apps/api/core';
  import { 
    Copy, 
    Check, 
    X, 
    Sparkles, 
    Camera,
    Settings, 
    AlertCircle, 
    ChevronDown, 
    ChevronUp,
    ExternalLink
  } from 'lucide-svelte';

  // Tauri API imports with dynamic fallback for browser dev mode
  let isTauri = $state(false);
  let unlistenFns: Array<() => void> = [];

  let title = $state('PolyShift AI');
  let badge = $state('Alt + T');
  let sourceText = $state('');
  let isImage = $state(false);
  let imagePreview = $state<string | null>(null);
  let showImagePreview = $state(false);
  let outputText = $state('');
  let errorMessage = $state('');
  let status = $state<'idle' | 'streaming' | 'done' | 'error'>('idle');
  let isCopied = $state(false);
  let showSourceText = $state(false);

  let renderedHtml = $derived.by(() => {
    if (!outputText) return '';
    try {
      return marked.parse(outputText, { breaks: true, gfm: true }) as string;
    } catch {
      return outputText;
    }
  });

  async function hideHud() {
    if (isTauri) {
      try {
        await invoke('hide_hud');
      } catch (e) {
        console.error('hide_hud error', e);
      }
    } else {
      status = 'idle';
    }
  }

  async function copyResult() {
    if (!outputText) return;
    try {
      if (isTauri) {
        await invoke('copy_text', { text: outputText });
      } else {
        await navigator.clipboard.writeText(outputText);
      }
      isCopied = true;
      setTimeout(() => { isCopied = false; }, 2000);
    } catch (e) {
      console.error('Failed to copy', e);
    }
  }

  function startDrag(e: MouseEvent) {
    const target = e.target as HTMLElement;
    if (target && target.closest('button')) return;

    if (e.button === 0 && isTauri) {
      invoke('drag_hud').catch((err) => console.error('Failed to start dragging', err));
    }
  }

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') {
      hideHud();
    }
  }

  onMount(async () => {
    window.addEventListener('keydown', handleKeydown);

    try {
      const { listen } = await import('@tauri-apps/api/event');
      isTauri = true;

      const u1 = await listen<any>('action-started', (event) => {
        const payload = event.payload;
        title = payload.title || 'PolyShift AI';
        badge = payload.badge || 'Alt + T';
        sourceText = payload.source_text || '';
        isImage = !!payload.is_image;
        imagePreview = payload.image_preview || null;
        showImagePreview = false;
        outputText = '';
        errorMessage = '';
        status = 'streaming';
        isCopied = false;
      });

      const u2 = await listen<string>('stream-token', (event) => {
        status = 'streaming';
        outputText += event.payload;
      });

      const u3 = await listen<string>('stream-complete', (event) => {
        status = 'done';
        outputText = event.payload;
      });

      const u4 = await listen<string>('stream-error', (event) => {
        status = 'error';
        errorMessage = event.payload;
      });

      unlistenFns = [u1, u2, u3, u4];
    } catch {
      // Running in standard browser preview mode: set mock sample data
      isTauri = false;
      title = 'Умный перевод';
      badge = 'Alt + T';
      sourceText = 'PolyShift is a blazing-fast, native AI companion for Windows built with Rust and SvelteKit.';
      outputText = 'PolyShift — это молниеносный нативный ИИ-помощник для Windows, созданный на связке Rust и SvelteKit.';
      status = 'done';
    }
  });

  onDestroy(() => {
    window.removeEventListener('keydown', handleKeydown);
    for (const fn of unlistenFns) {
      try { fn(); } catch {}
    }
  });
</script>

<main class="hud-container animate-fade-in">
  <!-- Draggable Header -->
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <header class="hud-header" data-tauri-drag-region role="region" aria-label="Панель заголовка окна" onmousedown={startDrag}>
    <div class="hud-header-left" data-tauri-drag-region>
      <div class="app-icon-badge">
        <Sparkles size={14} class="sparkle-icon" />
      </div>
      <div class="title-wrap" data-tauri-drag-region>
        <span class="hud-title">{title}</span>
        <span class="hud-badge">{badge}</span>
        {#if isImage}
          <span class="hud-badge image-badge">
            <Camera size={11} class="badge-icon" />
            Скриншот
          </span>
        {/if}
      </div>
    </div>

    <div class="hud-header-actions">
      {#if outputText}
        <button 
          class="icon-btn {isCopied ? 'copied' : ''}" 
          onclick={copyResult} 
          title="Скопировать результат (Ctrl+C)"
        >
          {#if isCopied}
            <Check size={14} color="#10B981" />
          {:else}
            <Copy size={14} />
          {/if}
        </button>
      {/if}

      <button class="icon-btn close-btn" onclick={hideHud} title="Закрыть (Esc)">
        <X size={15} />
      </button>
    </div>
  </header>

  <!-- Collapsible Screenshot / Source Text Preview -->
  {#if isImage && imagePreview}
    <section class="source-preview image-source-preview">
      <button 
        class="source-toggle" 
        onclick={() => showImagePreview = !showImagePreview}
        type="button"
      >
        <span class="source-label">
          <Camera size={12} class="source-icon" />
          Снимок экрана:
        </span>
        <span class="source-snippet image-snippet-hint">
          {showImagePreview ? 'Нажмите, чтобы свернуть' : 'Нажмите, чтобы просмотреть снимок'}
        </span>
        {#if showImagePreview}
          <ChevronUp size={13} />
        {:else}
          <ChevronDown size={13} />
        {/if}
      </button>

      {#if showImagePreview}
        <div class="image-preview-container animate-fade-in">
          <img src={imagePreview} alt="Захваченный скриншот" class="screenshot-img" />
        </div>
      {/if}
    </section>
  {:else if sourceText}
    <section class="source-preview">
      <button 
        class="source-toggle" 
        onclick={() => showSourceText = !showSourceText}
        type="button"
      >
        <span class="source-label">Исходный фрагмент:</span>
        <span class="source-snippet">
          {sourceText.length > 50 ? sourceText.slice(0, 50) + '…' : sourceText}
        </span>
        {#if showSourceText}
          <ChevronUp size={13} />
        {:else}
          <ChevronDown size={13} />
        {/if}
      </button>

      {#if showSourceText}
        <div class="source-full-box animate-fade-in">
          {sourceText}
        </div>
      {/if}
    </section>
  {/if}

  <!-- Main Output / Streaming View -->
  <section class="hud-body">
    {#if status === 'streaming' && !outputText}
      <div class="loading-state">
        <div class="pulsing-orb"></div>
        <span>{isImage ? 'Распознаю скриншот и обрабатываю...' : 'Генерирую ответ через Gemini...'}</span>
      </div>
    {:else if status === 'error'}
      <div class="error-state">
        <AlertCircle size={20} class="error-icon" />
        <div class="error-content">
          <p class="error-title">Ошибка выполнения</p>
          <p class="error-desc">{errorMessage}</p>
        </div>
      </div>
    {:else if outputText}
      <div class="markdown-wrapper">
        <div class="markdown-body">
          {@html renderedHtml}
        </div>
        {#if status === 'streaming'}
          <span class="streaming-cursor"></span>
        {/if}
      </div>
    {:else}
      <div class="empty-state">
        <Sparkles size={24} class="empty-icon" />
        <p>Выделите текст или сделайте скриншот (Win+Shift+S) и нажмите горячую клавишу</p>
        <div class="shortcuts-row">
          <span class="pill">Alt+T Перевод</span>
          <span class="pill">Alt+E Объяснить</span>
          <span class="pill">Alt+G Стиль</span>
          <span class="pill">Alt+S Тезисы</span>
        </div>
      </div>
    {/if}
  </section>

  <!-- Footer Status Bar -->
  <footer class="hud-footer">
    <div class="status-indicator">
      {#if status === 'streaming'}
        <span class="dot streaming"></span>
        <span class="status-text">{isImage ? 'Скриншот • Обработка' : 'Стриминг...'}</span>
      {:else if status === 'done'}
        <span class="dot done"></span>
        <span class="status-text">Готово</span>
      {:else if status === 'error'}
        <span class="dot error"></span>
        <span class="status-text">Сбой</span>
      {:else}
        <span class="dot idle"></span>
        <span class="status-text">Ожидание</span>
      {/if}
    </div>

    <div class="footer-actions">
      <span class="hint-key">Esc чтобы скрыть</span>
    </div>
  </footer>
</main>

<style>
  .hud-container {
    width: 100vw;
    height: 100vh;
    display: flex;
    flex-direction: column;
    background: rgba(11, 17, 32, 0.88);
    backdrop-filter: blur(28px) saturate(190%);
    -webkit-backdrop-filter: blur(28px) saturate(190%);
    border: 1px solid rgba(59, 130, 246, 0.28);
    border-radius: 18px;
    box-shadow: 0 20px 45px -10px rgba(0, 0, 0, 0.75), 0 0 30px rgba(59, 130, 246, 0.18);
    overflow: hidden;
  }

  .hud-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 14px;
    background: rgba(15, 23, 42, 0.65);
    border-bottom: 1px solid rgba(148, 163, 184, 0.1);
    cursor: grab;
    user-select: none;
    -webkit-user-select: none;
  }

  .hud-header:active {
    cursor: grabbing;
  }

  .hud-header-left {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: grab;
  }

  .app-icon-badge {
    width: 24px;
    height: 24px;
    border-radius: 6px;
    background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    box-shadow: 0 2px 8px rgba(59, 130, 246, 0.4);
  }

  .title-wrap {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .hud-title {
    font-size: 13px;
    font-weight: 700;
    color: #F8FAFC;
    letter-spacing: 0.2px;
  }

  .hud-badge {
    font-size: 11px;
    font-weight: 600;
    padding: 1px 7px;
    border-radius: 9999px;
    background: rgba(59, 130, 246, 0.2);
    border: 1px solid rgba(59, 130, 246, 0.4);
    color: #93C5FD;
    font-family: 'JetBrains Mono', monospace;
  }

  .image-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    background: rgba(16, 185, 129, 0.18);
    border-color: rgba(16, 185, 129, 0.45);
    color: #6EE7B7;
  }

  :global(.badge-icon) {
    display: inline-block;
  }

  .hud-header-actions {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .icon-btn {
    width: 26px;
    height: 26px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    border: 1px solid transparent;
    border-radius: 6px;
    color: #94A3B8;
    cursor: pointer;
    transition: all 0.15s ease;
  }

  .icon-btn:hover {
    background: rgba(255, 255, 255, 0.08);
    color: #FFFFFF;
    border-color: rgba(148, 163, 184, 0.2);
  }

  .icon-btn.copied {
    background: rgba(16, 185, 129, 0.15);
    border-color: rgba(16, 185, 129, 0.4);
  }

  .close-btn:hover {
    background: rgba(239, 68, 68, 0.2);
    color: #FCA5A5;
    border-color: rgba(239, 68, 68, 0.35);
  }

  /* Source snippet preview */
  .source-preview {
    padding: 6px 14px;
    background: rgba(15, 23, 42, 0.4);
    border-bottom: 1px solid rgba(148, 163, 184, 0.08);
  }

  .image-source-preview {
    border-bottom: 1px solid rgba(16, 185, 129, 0.25);
    background: rgba(15, 23, 42, 0.6);
  }

  .source-toggle {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 6px;
    background: none;
    border: none;
    color: #94A3B8;
    font-size: 11.5px;
    cursor: pointer;
    text-align: left;
  }

  .source-label {
    font-weight: 600;
    color: #64748B;
    display: inline-flex;
    align-items: center;
    gap: 4px;
  }

  :global(.source-icon) {
    color: #6EE7B7;
  }

  .source-snippet {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: #CBD5E1;
  }

  .image-snippet-hint {
    color: #93C5FD;
    font-size: 11px;
    font-style: italic;
  }

  .source-full-box {
    margin-top: 6px;
    padding: 8px 10px;
    background: rgba(6, 11, 20, 0.6);
    border: 1px solid rgba(148, 163, 184, 0.12);
    border-radius: 8px;
    font-size: 12px;
    line-height: 1.5;
    color: #94A3B8;
    max-height: 90px;
    overflow-y: auto;
    user-select: text;
    -webkit-user-select: text;
  }

  .image-preview-container {
    margin-top: 6px;
    padding: 6px;
    background: rgba(6, 11, 20, 0.7);
    border: 1px solid rgba(148, 163, 184, 0.15);
    border-radius: 8px;
    display: flex;
    justify-content: center;
    align-items: center;
    max-height: 160px;
    overflow: hidden;
  }

  .screenshot-img {
    max-width: 100%;
    max-height: 148px;
    object-fit: contain;
    border-radius: 6px;
    border: 1px solid rgba(59, 130, 246, 0.25);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.35);
  }

  /* Body */
  .hud-body {
    flex: 1;
    overflow-y: auto;
    padding: 12px 14px;
  }

  .markdown-wrapper {
    position: relative;
  }

  .streaming-cursor {
    display: inline-block;
    width: 7px;
    height: 14px;
    background: #3B82F6;
    margin-left: 3px;
    border-radius: 2px;
    animation: pulseGlow 0.8s infinite;
    vertical-align: middle;
  }

  .loading-state {
    display: flex;
    align-items: center;
    gap: 10px;
    color: #94A3B8;
    font-size: 13px;
    padding: 18px 0;
  }

  .pulsing-orb {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: #3B82F6;
    box-shadow: 0 0 12px #3B82F6;
    animation: pulseOrb 1.4s ease-in-out infinite;
  }

  .error-state {
    display: flex;
    gap: 12px;
    padding: 12px;
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.25);
    border-radius: 10px;
    color: #FCA5A5;
  }

  :global(.error-icon) {
    color: #EF4444;
    flex-shrink: 0;
    margin-top: 2px;
  }

  .error-title {
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 2px;
    color: #F87171;
  }

  .error-desc {
    font-size: 12px;
    line-height: 1.4;
    color: #FCA5A5;
  }

  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    gap: 12px;
    color: #64748B;
    text-align: center;
    padding: 20px;
  }

  :global(.empty-icon) {
    color: #3B82F6;
    opacity: 0.7;
  }

  .shortcuts-row {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 8px;
  }

  .pill {
    font-size: 11px;
    padding: 3px 8px;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 6px;
    color: #94A3B8;
  }

  /* Footer */
  .hud-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 7px 14px;
    background: rgba(15, 23, 42, 0.5);
    border-top: 1px solid rgba(148, 163, 184, 0.08);
    font-size: 11px;
    user-select: none;
    -webkit-user-select: none;
  }

  .status-indicator {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
  }

  .dot.streaming {
    background: #3B82F6;
    box-shadow: 0 0 8px #3B82F6;
    animation: pulseDot 1s infinite;
  }

  .dot.done {
    background: #10B981;
    box-shadow: 0 0 6px rgba(16, 185, 129, 0.6);
  }

  .dot.error {
    background: #EF4444;
    box-shadow: 0 0 6px rgba(239, 68, 68, 0.6);
  }

  .dot.idle {
    background: #64748B;
  }

  .status-text {
    color: #94A3B8;
    font-size: 11px;
  }

  .footer-actions {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .hint-key {
    color: #64748B;
    font-size: 10.5px;
    font-family: 'JetBrains Mono', monospace;
  }

  /* Markdown Styles inside HUD */
  :global(.markdown-body) {
    font-size: 13.5px;
    line-height: 1.6;
    color: #E2E8F0;
    user-select: text;
    -webkit-user-select: text;
  }

  :global(.markdown-body p) {
    margin-bottom: 8px;
  }

  :global(.markdown-body p:last-child) {
    margin-bottom: 0;
  }

  :global(.markdown-body pre) {
    background: rgba(15, 23, 42, 0.85);
    border: 1px solid rgba(148, 163, 184, 0.15);
    border-radius: 8px;
    padding: 10px 12px;
    overflow-x: auto;
    margin: 8px 0;
  }

  :global(.markdown-body code) {
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    color: #93C5FD;
    background: rgba(59, 130, 246, 0.12);
    padding: 2px 5px;
    border-radius: 4px;
  }

  :global(.markdown-body pre code) {
    background: transparent;
    padding: 0;
    color: #E2E8F0;
  }

  :global(.markdown-body ul, .markdown-body ol) {
    padding-left: 18px;
    margin: 6px 0;
  }

  :global(.markdown-body li) {
    margin-bottom: 4px;
  }

  :global(.markdown-body strong) {
    color: #FFFFFF;
    font-weight: 600;
  }

  /* Animations */
  @keyframes pulseOrb {
    0%, 100% { transform: scale(1); opacity: 0.8; }
    50% { transform: scale(1.3); opacity: 1; }
  }

  @keyframes pulseGlow {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.2; }
  }

  @keyframes pulseDot {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.5; transform: scale(0.8); }
  }

  .animate-fade-in {
    animation: fadeIn 0.2s cubic-bezier(0.16, 1, 0.3, 1);
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(4px); }
    to { opacity: 1; transform: translateY(0); }
  }
</style>
