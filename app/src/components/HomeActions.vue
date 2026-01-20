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
      <div v-if="uploadedLink" class="d-flex flex-column align-items-center gap-2 mt-3">
        <button
          class="btn btn-outline-secondary btn-sm"
          type="button"
          :disabled="!uploadedLink"
          @click="() => emit('copy-link')"
        >
          {{ copyLinkLabel }}
        </button>
        <p class="text-break small text-muted mb-0">{{ uploadedLink }}</p>
      </div>
      <p v-if="linkStatus" class="small text-muted mt-2">{{ linkStatus }}</p>
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
  uploadedLink = '',
  linkStatus = '',
  copyLinkLabel = '',
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
  uploadedLink: {
    type: String,
    default: '',
  },
  linkStatus: {
    type: String,
    default: '',
  },
  copyLinkLabel: {
    type: String,
    default: 'Copy link',
  },
});

const emit = defineEmits(['run-action', 'copy-link']);
</script>
