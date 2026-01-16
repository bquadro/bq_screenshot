<template>
  <header class="d-flex justify-content-between align-items-center py-4 border-bottom">
    <div class="d-flex align-items-center gap-3">
      <img v-if="logoPath" :src="logoPath" alt="logo" width="48" height="48" />
      <div>
        <h1 class="h4 mb-1">{{ title }}</h1>
        <p class="text-muted mb-0">{{ description }}</p>
      </div>
    </div>
    <div class="text-end">
      <button
        v-if="currentPage === 'home'"
        class="btn btn-outline-primary"
        type="button"
        @click="handleOpenSettings"
      >
        {{ settingsLabel }}
      </button>
      <button
        v-else
        class="btn btn-outline-secondary"
        type="button"
        @click="handleGoHome"
      >
        {{ backLabel }}
      </button>
      <p class="text-muted small mb-0">{{ status }}</p>
    </div>
  </header>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';

const {
  logoPath,
  title,
  description,
  currentPage,
  settingsLabel,
  backLabel,
  status,
} = defineProps({
  logoPath: String,
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  currentPage: {
    type: String,
    required: true,
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
    required: true,
  },
});

const emit = defineEmits(['open-settings', 'go-home']);

const handleOpenSettings = () => emit('open-settings');
const handleGoHome = () => emit('go-home');
</script>
