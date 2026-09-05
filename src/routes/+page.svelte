<script lang="ts">
  import { onMount } from 'svelte';
  import HudOverlay from '$lib/components/HudOverlay.svelte';
  import SettingsFlyout from '$lib/components/SettingsFlyout.svelte';

  let currentWindow = $state<'hud' | 'settings'>('hud');
  let isTauriEnv = $state(false);

  onMount(async () => {
    try {
      const { getCurrentWebviewWindow } = await import('@tauri-apps/api/webviewWindow');
      const win = getCurrentWebviewWindow();
      isTauriEnv = true;
      if (win.label === 'settings') {
        currentWindow = 'settings';
      } else {
        currentWindow = 'hud';
      }
    } catch {
      // In standard browser development preview mode
      isTauriEnv = false;
      const params = new URLSearchParams(window.location.search);
      if (params.get('view') === 'settings') {
        currentWindow = 'settings';
      } else {
        currentWindow = 'hud';
      }
    }
  });
</script>

{#if !isTauriEnv}
  <!-- Dev mode preview switcher when viewed in web browser -->
  <aside class="dev-preview-bar">
    <span class="preview-tag">Preview Mode:</span>
    <button 
      class="preview-btn {currentWindow === 'hud' ? 'active' : ''}" 
      onclick={() => currentWindow = 'hud'}
    >
      HUD Overlay (Alt+T)
    </button>
    <button 
      class="preview-btn {currentWindow === 'settings' ? 'active' : ''}" 
      onclick={() => currentWindow = 'settings'}
    >
      Settings Window
    </button>
  </aside>
{/if}

{#if currentWindow === 'settings'}
  <SettingsFlyout />
{:else}
  <HudOverlay />
{/if}

<style>
  .dev-preview-bar {
    position: fixed;
    top: 8px;
    right: 8px;
    z-index: 9999;
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 4px 8px;
    background: rgba(15, 23, 42, 0.9);
    border: 1px solid rgba(148, 163, 184, 0.2);
    border-radius: 9999px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
    font-size: 11px;
  }

  .preview-tag {
    color: #64748B;
    font-weight: 600;
  }

  .preview-btn {
    padding: 3px 8px;
    border-radius: 9999px;
    background: transparent;
    border: 1px solid transparent;
    color: #94A3B8;
    cursor: pointer;
    font-size: 11px;
    transition: all 0.15s;
  }

  .preview-btn:hover {
    color: #F8FAFC;
  }

  .preview-btn.active {
    background: #3B82F6;
    color: #FFFFFF;
    font-weight: 600;
  }
</style>
