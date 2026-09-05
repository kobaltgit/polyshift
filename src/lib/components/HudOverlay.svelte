<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { marked } from 'marked';
  import { invoke } from '@tauri-apps/api/core';
  import { 
    Copy, 
    Check, 
    X, 
    Sparkles, 
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

  <!-- Collapsible Original Source Preview -->
  {#if sourceText}
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
        <span>Генерирую ответ через Gemini...</span>
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
        <p>Выделите любой текст в Windows и нажмите горячую клавишу</p>
        <div class="shortcuts-row">
          <span class="pill">Alt+T Перевод</span>
          <span class="pill">Alt+G Стиль</span>
          <span class="pill">Alt+S Суммаризация</span>
        </div>
      </div>
    {/if}
  </section>

  <!-- Footer Status Bar -->
  <footer class="hud-footer">
    <div class="status-indicator">
      {#if status === 'streaming'}
        <span class="dot streaming"></span>
        <span class="status-text">Стриминг...</span>
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
  }

  .source-snippet {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: #CBD5E1;
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
    animation: pulseGlow 1.2s infinite ease-in-out;
  }

  .error-state {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 12px;
    background: rgba(239, 68, 68, 0.12);
    border: 1px solid rgba(239, 68, 68, 0.3);
    border-radius: 10px;
  }

  :global(.error-icon) {
    color: #F87171;
    flex-shrink: 0;
    margin-top: 2px;
  }

  .error-title {
    font-size: 12.5px;
    font-weight: 700;
    color: #FCA5A5;
    margin-bottom: 2px;
  }

  .error-desc {
    font-size: 12px;
    color: #FECACA;
    line-height: 1.4;
  }

  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 24px 10px;
    color: #94A3B8;
  }

  :global(.empty-icon) {
    color: #3B82F6;
    margin-bottom: 10px;
    opacity: 0.8;
  }

  .empty-state p {
    font-size: 13px;
    margin-bottom: 12px;
  }

  .shortcuts-row {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
    justify-content: center;
  }

  .pill {
    font-size: 11px;
    padding: 3px 8px;
    background: rgba(30, 41, 59, 0.7);
    border: 1px solid rgba(148, 163, 184, 0.15);
    border-radius: 9999px;
    color: #93C5FD;
    font-family: 'JetBrains Mono', monospace;
  }

  /* Footer */
  .hud-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 6px 14px;
    background: rgba(15, 23, 42, 0.5);
    border-top: 1px solid rgba(148, 163, 184, 0.08);
    font-size: 11px;
  }

  .status-indicator {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
  }

  .dot.streaming {
    background: #3B82F6;
    box-shadow: 0 0 8px #3B82F6;
    animation: pulseGlow 1s infinite;
  }

  .dot.done {
    background: #10B981;
    box-shadow: 0 0 6px #10B981;
  }

  .dot.error {
    background: #EF4444;
    box-shadow: 0 0 6px #EF4444;
  }

  .dot.idle {
    background: #64748B;
  }

  .status-text {
    color: #94A3B8;
  }

  .hint-key {
    color: #64748B;
    font-family: 'JetBrains Mono', monospace;
  }
</style>
