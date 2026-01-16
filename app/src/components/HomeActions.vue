<template>
  <section class="flex-fill d-flex flex-column justify-content-center py-5">
    <div class="row w-100 row-cols-1 row-cols-md-3 g-3 mb-4">
      <div class="col" v-for="action in actions" :key="action.key">
        <div class="card h-100 shadow-sm">
          <div class="card-body d-flex flex-column justify-content-between">
            <div>
              <h3 class="h6">{{ action.title }}</h3>
              <p class="text-muted small mb-0">{{ action.subtitle }}</p>
            </div>
            <button
              class="btn btn-primary w-100 mt-3"
              :disabled="isCapturing || action.disabled"
              type="button"
              @click="() => emit('run-action', action.key)"
            >
              {{ action.buttonLabel }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="w-100 text-center">
      <p class="text-muted mb-2">{{ captureStatus }}</p>
      <img
        v-if="previewUrl"
        :src="previewUrl"
        class="img-fluid rounded border"
        alt="Preview screenshot"
      />
    </div>
  </section>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';

const {
  actions = [],
  isCapturing = false,
  captureStatus = '',
  previewUrl = '',
} = defineProps({
  actions: {
    type: Array,
    default: () => [],
  },
  isCapturing: {
    type: Boolean,
    default: false,
  },
  captureStatus: {
    type: String,
    default: '',
  },
  previewUrl: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['run-action']);
</script>
