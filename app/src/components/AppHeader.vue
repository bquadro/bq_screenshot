<template>
  <header class="d-flex justify-content-between align-items-center py-4 border-bottom">
    <div class="d-flex align-items-center gap-3">
      <img v-if="logoPath" :src="logoPath" alt="logo" width="48" height="48" />
      <div v-if="currentPage === 'home' && actions?.length" class="d-flex gap-2">
        <button
          v-for="action in actions"
          :key="action.key"
          class="btn btn-outline-secondary btn-icon"
          type="button"
          :title="action.title"
          @click="$emit('run-action', action.key)"
        >
          <span class="visually-hidden">{{ action.title }}</span>
          <svg v-if="action.icon === 'fullscreen'" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M4 4h6v2H6v4H4V4zm10 0h6v6h-2V6h-4V4zM4 14h2v4h4v2H4v-6zm16 0h2v6h-6v-2h4v-4z" />
          </svg>
          <svg v-else-if="action.icon === 'area'" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <rect x="5" y="5" width="14" height="14" rx="2" />
          </svg>
          <svg v-else-if="action.icon === 'record'" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <circle cx="12" cy="12" r="6" />
          </svg>
          <svg v-else viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M4 4h6v2H6v4H4V4zm10 0h6v6h-2V6h-4V4zM4 14h2v4h4v2H4v-6zm16 0h2v6h-6v-2h4v-4z" />
          </svg>
        </button>
      </div>
    </div>
    <div class="d-flex align-items-center gap-2">
      <button
        v-if="currentPage === 'home'"
        class="btn btn-outline-secondary btn-icon"
        type="button"
        :title="settingsLabel"
        @click="handleOpenSettings"
      >
        <span class="visually-hidden">{{ settingsLabel }}</span>
        <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
          <path d="M12 15.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z" />
          <path
            d="M19.43 12.98a1.75 1.75 0 0 0 0-1.98l2-3.46a0.5 0.5 0 0 0-.32-.74l-3.16-.5a1.5 1.5 0 0 0-1.12-.65l-.72-3.14a0.5 0.5 0 0 0-.49-.37h-4a0.5 0.5 0 0 0-.49.37l-.72 3.14a1.5 1.5 0 0 0-1.12.65l-3.16.5a0.5 0.5 0 0 0-.32.74l2 3.46a1.75 1.75 0 0 0 0 1.98l-2 3.46a0.5 0.5 0 0 0 .32.74l3.16.5a1.5 1.5 0 0 0 1.12.65l.72 3.14a0.5 0.5 0 0 0 .49.37h4a0.5 0.5 0 0 0 .49-.37l.72-3.14a1.5 1.5 0 0 0 1.12-.65l3.16-.5a0.5 0.5 0 0 0 .32-.74z"
          />
        </svg>
      </button>
      <button
        v-else
        class="btn btn-outline-secondary btn-icon"
        type="button"
        :title="backLabel"
        @click="handleGoHome"
      >
        <span class="visually-hidden">{{ backLabel }}</span>
        <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
          <path d="M15 6l-6 6 6 6" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </button>
      <p class="text-muted small mb-0">{{ status }}</p>
    </div>
  </header>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';

const {
  logoPath,
  currentPage,
  actions,
  settingsLabel,
  backLabel,
  status,
} = defineProps({
  logoPath: String,
  currentPage: {
    type: String,
    required: true,
  },
  actions: {
    type: Array,
    default: () => [],
  },
  settingsLabel: {
    type: String,
    required: true,
  },
  backLabel: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['open-settings', 'go-home', 'run-action']);

const handleOpenSettings = () => emit('open-settings');
const handleGoHome = () => emit('go-home');

</script>
