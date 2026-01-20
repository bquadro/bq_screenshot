<template>
  <section class="flex-fill d-flex flex-column justify-content-between py-5">
    <div class="card shadow-sm">
      <div class="card-body">
        <h2 class="card-title h5 mb-3">{{ t('settings.title') }}</h2>
        <form @submit.prevent="$emit('save-settings')">
          <section class="mb-4">
            <h3 class="h6">{{ t('settings.languageSection') }}</h3>
            <div class="row g-3">
              <div class="col-12 col-md-6">
                <label class="form-label">{{ t('settings.languageLabel') }}</label>
                <select class="form-select" :value="language" @change="updateLanguage">
                  <option v-for="code in languageOptions" :key="code" :value="code">
                    {{ t('language.' + code) }}
                  </option>
                </select>
              </div>
            </div>
          </section>

          <!-- остальная форма так же, используя settingsForm поля -->
          <section class="mb-4">
            <h3 class="h6">{{ t('settings.traySection') }}</h3>
            <div>
              <div class="form-check">
                <input class="form-check-input" type="checkbox" v-model="settingsForm.minimizeToTray" />
                <label class="form-check-label">
                  {{ t('settings.minimizeToTray') }}
                </label>
              </div>
            </div>
          </section>

          <section class="mb-4">
            <h3 class="h6">{{ t('settings.hotkeysSection') }}</h3>
            <div class="d-grid gap-3">
              <div>
                <label class="form-label">{{ t('settings.hotkeyFullScreen') }}</label>
                <div class="input-group">
                  <input
                    class="form-control"
                    type="text"
                    v-model="settingsForm.hotkeyFullScreen"
                    :placeholder="t('settings.placeholderHotkeyFullScreen')"
                  />
                  <button class="btn btn-outline-secondary" type="button" @click="triggerHotkeyCapture('hotkeyFullScreen')">
                    {{ t('settings.hotkeyCaptureButton') }}
                  </button>
                </div>
              </div>
              <div>
                <label class="form-label">{{ t('settings.hotkeyArea') }}</label>
                <div class="input-group">
                  <input
                    class="form-control"
                    type="text"
                    v-model="settingsForm.hotkeyArea"
                    :placeholder="t('settings.placeholderHotkeyArea')"
                  />
                  <button class="btn btn-outline-secondary" type="button" @click="triggerHotkeyCapture('hotkeyArea')">
                    {{ t('settings.hotkeyCaptureButton') }}
                  </button>
                </div>
              </div>
              <div>
                <label class="form-label">{{ t('settings.hotkeyVideo') }}</label>
                <div class="input-group">
                  <input
                    class="form-control"
                    type="text"
                    v-model="settingsForm.hotkeyVideo"
                    :placeholder="t('settings.placeholderHotkeyVideo')"
                  />
                  <button class="btn btn-outline-secondary" type="button" @click="triggerHotkeyCapture('hotkeyVideo')">
                    {{ t('settings.hotkeyCaptureButton') }}
                  </button>
                </div>
              </div>
              <div>
                <label class="form-label">{{ t('settings.hotkeyEditor') }}</label>
                <div class="input-group">
                  <input
                    class="form-control"
                    type="text"
                    v-model="settingsForm.hotkeyEditor"
                    :placeholder="t('settings.placeholderHotkeyEditor')"
                  />
                  <button class="btn btn-outline-secondary" type="button" @click="triggerHotkeyCapture('hotkeyEditor')">
                    {{ t('settings.hotkeyCaptureButton') }}
                  </button>
                </div>
              </div>
            </div>
          </section>

          <section class="mb-4">
            <h3 class="h6">{{ t('settings.storageSection') }}</h3>
            <div class="row g-3 align-items-center">
              <div class="col-12 col-md-8">
                <label class="form-label">{{ t('settings.saveFolder') }}</label>
                <div class="input-group">
                  <input
                    class="form-control"
                    type="text"
                    v-model="settingsForm.saveFolder"
                    :placeholder="t('settings.placeholderSaveFolder')"
                  />
                  <button class="btn btn-outline-secondary" type="button" @click="emit('select-save-folder')">
                    {{ t('settings.chooseFolderButton') }}
                  </button>
                </div>
              </div>
              <div class="col-12 col-md-4">
                <div class="form-check mt-md-4">
                  <input class="form-check-input" type="checkbox" v-model="settingsForm.uploadToS3" />
                  <label class="form-check-label">
                    {{ t('settings.uploadToS3') }}
                  </label>
                </div>
              </div>
            </div>
          </section>

          <section class="mb-4">
            <h3 class="h6">{{ t('settings.s3Section') }}</h3>
            <div class="row g-3">
              <div class="col-12 col-md-6">
                <label class="form-label">{{ t('settings.s3Endpoint') }}</label>
                <input
                  class="form-control"
                  type="text"
                  v-model="settingsForm.s3Endpoint"
                  :placeholder="t('settings.placeholderS3Endpoint')"
                />
              </div>
              <div class="col-12 col-md-6">
                <label class="form-label">{{ t('settings.s3Region') }}</label>
                <input
                  class="form-control"
                  type="text"
                  v-model="settingsForm.s3Region"
                  :placeholder="t('settings.placeholderS3Region')"
                />
              </div>
              <div class="col-12 col-md-6">
                <label class="form-label">{{ t('settings.s3Bucket') }}</label>
                <input
                  class="form-control"
                  type="text"
                  v-model="settingsForm.s3Bucket"
                  :placeholder="t('settings.placeholderS3Bucket')"
                />
              </div>
              <div class="col-12 col-md-6">
                <label class="form-label">{{ t('settings.s3AccessKey') }}</label>
                <input
                  class="form-control"
                  type="text"
                  v-model="settingsForm.s3AccessKey"
                  :placeholder="t('settings.placeholderS3AccessKey')"
                />
              </div>
              <div class="col-12 col-md-6">
                <label class="form-label">{{ t('settings.s3SecretKey') }}</label>
                <input
                  class="form-control"
                  type="password"
                  v-model="settingsForm.s3SecretKey"
                  :placeholder="t('settings.placeholderS3SecretKey')"
                />
              </div>
            <div class="col-12 col-md-6">
              <div class="form-check mt-3">
                <input class="form-check-input" type="checkbox" v-model="settingsForm.s3UseSsl" />
                <label class="form-check-label">
                  {{ t('settings.s3UseSsl') }}
                </label>
              </div>
            </div>
          </div>
          <div class="d-flex flex-wrap gap-2 align-items-center mt-3">
            <button
              class="btn btn-outline-primary btn-sm"
              type="button"
              :disabled="isSaving || isS3Testing"
              @click="$emit('check-s3-connection')"
            >
              {{ t('settings.s3TestButton') }}
            </button>
            <span class="small text-muted">{{ s3TestStatus }}</span>
          </div>
        </section>

        <div class="d-flex flex-wrap align-items-center gap-3">
          <button class="btn btn-primary" type="submit" :disabled="isSaving">
            {{ t('settings.saveButton') }}
          </button>
            <p class="mb-0 text-muted small">{{ settingsStatus }}</p>
          </div>
        </form>
      </div>
    </div>
  </section>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';

const {
  settingsForm,
  language,
  languageOptions,
  isSaving,
  settingsStatus,
  t,
  isS3Testing,
  s3TestStatus,
} = defineProps({
  settingsForm: {
    type: Object,
    required: true,
  },
  language: {
    type: String,
    required: true,
  },
  languageOptions: {
    type: Array,
    default: () => ['ru', 'en'],
  },
  isSaving: {
    type: Boolean,
    default: false,
  },
  settingsStatus: {
    type: String,
    default: '',
  },
  t: {
    type: Function,
    required: true,
  },
  isS3Testing: {
    type: Boolean,
    default: false,
  },
  s3TestStatus: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['save-settings', 'update:language', 'capture-hotkey', 'select-save-folder', 'check-s3-connection']);

const updateLanguage = (event) => emit('update:language', event.target.value);
const triggerHotkeyCapture = (field) => emit('capture-hotkey', field);
</script>
