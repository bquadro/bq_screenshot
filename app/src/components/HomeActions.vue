<template>
  <section class="flex-fill d-flex flex-column justify-content-center py-5">
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
          @click="$emit('copy-link')"
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
  captureStatus = '',
  previewUrl = '',
  uploadedLink = '',
  linkStatus = '',
  copyLinkLabel = '',
} = defineProps({
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

const emit = defineEmits(['copy-link']);
</script>
