<template>
  <main class="container-xl d-flex flex-column min-vh-100">
    <AppHeader
      :logo-path="uiConfig.logoPath"
      :current-page="currentPage"
      :actions="actions"
      :settings-label="t('header.settingsButton')"
      :back-label="t('header.backButton')"
      :status="settingsStatus"
      @open-settings="openSettings"
      @go-home="goHome"
      @run-action="handleAction"
    />

    <HomeActions
      v-if="currentPage === 'home'"
      :capture-status="captureStatus"
      :preview-url="previewUrl"
      :uploaded-link="uploadedLink"
      :link-status="linkStatus"
      :upload-progress-label="uploadProgressLabel"
      :copy-link-label="t('capture.linkCopyButton')"
      @copy-link="copyUploadedLink"
    />

    <AreaSelectionPage
      v-else-if="currentPage === 'area'"
      :image-data="areaImage"
      :title="t('areaSelection.title')"
      :description="t('areaSelection.description')"
      :instructions="t('areaSelection.instructions')"
      :save-label="t('areaSelection.saveButton')"
      :cancel-label="t('areaSelection.cancelButton')"
      @crop="handleAreaCrop"
      @cancel="handleAreaCancel"
    />

  <SettingsForm
    v-else-if="currentPage === 'settings'"
    :settings-form="settingsForm"
    :language="language"
    :language-options="languageOptions"
    :is-saving="isSaving"
    :settings-status="settingsStatus"
    :t="t"
    :is-s3-testing="isS3Testing"
    :s3-test-status="s3TestStatus"
    @save-settings="saveSettings"
    @update:language="handleLanguageUpdate"
    @capture-hotkey="handleHotkeyCapture"
    @select-save-folder="chooseSaveFolder"
    @check-s3-connection="testS3Connection"
  />

    <ImageEditorPage
      v-else-if="currentPage === 'editor'"
      :image-data="editorImage"
      :title="t('editor.title')"
      :description="t('editor.description')"
      :save-label="t('editor.saveButton')"
      :cancel-label="t('editor.cancelButton')"
      @save="handleEditorSave"
      @cancel="handleEditorCancel"
    />

    <footer class="text-center py-3 border-top">
      <div class="d-flex justify-content-center gap-3 flex-wrap align-items-center">
        <small class="text-muted">{{ t('footer.copy') }}</small>
        <small class="text-muted">Electron {{ electronVersion }}</small>
      </div>
    </footer>
  </main>
</template>

<script setup>
import { reactive, ref, watch, onMounted, onBeforeUnmount, computed } from 'vue';
import AppHeader from './components/AppHeader.vue';
import HomeActions from './components/HomeActions.vue';
import SettingsForm from './components/SettingsForm.vue';
import AreaSelectionPage from './components/AreaSelectionPage.vue';
import ImageEditorPage from './components/ImageEditorPage.vue';
import LocalizationService from './classes/LocalizationService.js';
import SettingsService from './classes/SettingsService.js';
import CaptureService from './classes/CaptureService.js';
import UploadService from './classes/UploadService.js';
import VideoService from './classes/VideoService.js';
import translations from './lang/index.js';
import uiConfig from './config/ui.js';
import {
  createDefaultForm,
  applyLoadedSettings as applyLoadedSettingsHelper,
  gatherSettingsPayload,
  buildHotkeyBindings,
} from './modules/settingsUtils.js';
import { useUploadLink } from './modules/uploadLink.js';
import { createCaptureActions } from './modules/captureActions.js';
import { ensureDomainEndpoint } from './modules/s3Utils.js';
import VideoRecorder from './modules/videoRecorder.js';

const localizationService = new LocalizationService(translations);
const settingsService = new SettingsService();
const captureService = new CaptureService();
const uploadService = new UploadService();
const videoService = new VideoService();
const videoRecorder = new VideoRecorder();

const settingsForm = reactive(createDefaultForm());
const settingsStatus = ref(localizationService.t('settings.statusNotLoaded'));
const captureStatus = ref(localizationService.t('capture.statusInitial'));
const previewUrl = ref('');
const electronVersion = ref('?');
const isCapturing = ref(false);
const isSaving = ref(false);
const language = ref(localizationService.currentLanguage);
localizationService.setLanguage(language.value);
const languageOptions = ['ru', 'en'];
const currentPage = ref('home');
const editorImage = ref('');
const areaImage = ref('');
const isUploadingVideo = ref(false);
const uploadProgress = ref(0);
const currentUploadId = ref('');
let trayActionRemover = null;
let uploadProgressRemover = null;
const screenshotPath = ref('');
const uploadedLink = ref('');
const linkStatus = ref('');
const isS3Testing = ref(false);
const s3TestStatus = ref('');
const isRecording = ref(false);

const arrayBufferToBase64 = (buffer) => {
  let binary = '';
  const bytes = new Uint8Array(buffer);
  const chunkSize = 0x8000;
  for (let i = 0; i < bytes.length; i += chunkSize) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunkSize));
  }
  return window.btoa(binary);
};

// При смене языка обновляем словарь и статусы.
watch(language, (value) => {
  localizationService.setLanguage(value);
  settingsStatus.value = localizationService.t('settings.statusLoaded');
  captureStatus.value = localizationService.t('capture.statusInitial');
});

// Обновляет выбранный язык.
const handleLanguageUpdate = (value) => {
  language.value = value;
};

// Удобный доступ к переводу по ключу.
const t = (key, replacements = {}) => localizationService.t(key, replacements);

const uploadProgressLabel = computed(() => {
  if (!isUploadingVideo.value) {
    return '';
  }
  const percent = Math.max(0, Math.min(100, Math.round(uploadProgress.value)));
  return t('capture.uploadProgress', { percent });
});

const { updateUploadLink, copyUploadedLink } = useUploadLink({
  settingsForm,
  uploadService,
  uploadedLink,
  linkStatus,
  t,
});

const handleUploadProgress = (payload) => {
  if (!payload || payload.uploadId !== currentUploadId.value) {
    return;
  }
  if (typeof payload.percent === 'number') {
    uploadProgress.value = payload.percent;
  }
};

const {
  captureFullScreen,
  captureArea,
  handleEditorSave,
  handleEditorCancel,
} = createCaptureActions({
  captureService,
  settingsForm,
  captureStatus,
  previewUrl,
  editorImage,
  areaImage,
  currentPage,
  isCapturing,
  screenshotPath,
  updateUploadLink,
  t,
});

const registerHotkeys = () => {
  const bindings = buildHotkeyBindings(settingsForm);
  if (window.electronAPI?.registerGlobalHotkeys) {
    window.electronAPI.registerGlobalHotkeys(bindings);
  }
};

const applyLoadedSettings = (loaded) => {
  applyLoadedSettingsHelper(loaded, settingsForm);
  language.value = loaded.language || language.value;
  registerHotkeys();
};

const gatherPayload = () => ({
  // Собираем объект настроек для сохранения.
  screenshots: {
    fullScreen: settingsForm.fullScreenCapture,
    area: settingsForm.areaCapture,
  },
  videoCapture: {
    enabled: settingsForm.videoCapture,
  },
  editor: {
    enabled: settingsForm.screenshotEditor,
  },
  tray: {
    minimizeToTray: settingsForm.minimizeToTray,
  },
  hotkeys: {
    captureFullScreen: settingsForm.hotkeyFullScreen.trim(),
    captureArea: settingsForm.hotkeyArea.trim(),
    captureVideo: settingsForm.hotkeyVideo.trim(),
    openEditor: settingsForm.hotkeyEditor.trim(),
  },
  storage: {
    folder: settingsForm.saveFolder.trim(),
  },
  s3: {
    enabled: settingsForm.uploadToS3,
    uploadOnCapture: settingsForm.uploadToS3,
    endpoint: settingsForm.s3Endpoint.trim(),
    region: settingsForm.s3Region.trim(),
    bucket: settingsForm.s3Bucket.trim(),
    accessKey: settingsForm.s3AccessKey.trim(),
    secretKey: settingsForm.s3SecretKey.trim(),
    useSsl: settingsForm.s3UseSsl,
  },
  language: language.value,
});

const loadSettings = async () => {
  // Загружаем настройки из main-процесса и обновляем UI.
  settingsStatus.value = t('settings.statusLoading');

  try {
    const loaded = await settingsService.load();
    applyLoadedSettings(loaded);
    settingsStatus.value = t('settings.statusLoaded');
  } catch (error) {
    console.error('settings load', error);
    settingsStatus.value = t('settings.statusLoadError');
  }
};

const saveSettings = async () => {
  // Сохраняем текущие значения формы как настройки.
  settingsStatus.value = t('settings.statusSaving');
  isSaving.value = true;

  ensureDomainEndpoint(settingsForm);

  try {
    await settingsService.save(gatherPayload());
    settingsStatus.value = t('settings.statusSaved');
  } catch (error) {
    console.error('settings save', error);
    settingsStatus.value = t('settings.statusSaveError');
  } finally {
    isSaving.value = false;
    registerHotkeys();
  }
};

const chooseSaveFolder = async () => {
  // Открываем диалог выбора папки и записываем результат в форму.
  try {
    const folder = await settingsService.selectFolder();
    if (folder) {
      settingsForm.saveFolder = folder;
      settingsStatus.value = `${t('settings.folderSelectSuccess')} ${folder}`;
    } else {
      settingsStatus.value = t('settings.folderSelectCanceled');
    }
  } catch (error) {
    console.error('folder selection', error);
    settingsStatus.value = t('settings.folderSelectError');
  }
};

const updateTrayRecording = (value) => {
  if (window.electronAPI?.setTrayRecordingState) {
    window.electronAPI.setTrayRecordingState(value);
  }
};

const trackVideoUpload = async (filePath) => {
  const uploadId = `video-upload-${Date.now()}`;
  currentUploadId.value = uploadId;
  isUploadingVideo.value = true;
  uploadProgress.value = 0;
  try {
    await updateUploadLink(filePath, { contentType: 'video/webm', uploadId });
  } finally {
    isUploadingVideo.value = false;
    currentUploadId.value = '';
  }
};

const startVideoRecording = async () => {
  captureStatus.value = t('capture.statusRecording');
  try {
    await videoRecorder.start();
    isRecording.value = true;
    updateTrayRecording(true);
  } catch (error) {
    captureStatus.value = `${t('capture.videoSaveError')} ${error?.message || ''}`.trim();
    isRecording.value = false;
    updateTrayRecording(false);
  }
};

const stopVideoRecording = async () => {
  if (!isRecording.value) {
    return;
  }
  try {
    const blob = await videoRecorder.stop();
    if (!blob) {
      captureStatus.value = t('capture.videoSaveError');
      return;
    }
    const arrayBuffer = await blob.arrayBuffer();
    const base64 = arrayBufferToBase64(arrayBuffer);
    const result = await videoService.save(base64);
    if (result?.filePath) {
      captureStatus.value = `${t('capture.videoSaved')} ${result.filePath}`;
      isRecording.value = false;
      updateTrayRecording(false);
      await trackVideoUpload(result.filePath);
    } else {
      captureStatus.value = t('capture.videoSaveError');
    }
  } catch (error) {
    captureStatus.value = `${t('capture.videoSaveError')} ${error?.message || ''}`.trim();
  } finally {
    isRecording.value = false;
    updateTrayRecording(false);
  }
};

const toggleVideoRecording = () => {
  return isRecording.value ? stopVideoRecording() : startVideoRecording();
};

const testS3Connection = async () => {
  if (!window.electronAPI?.checkS3Connection) {
    s3TestStatus.value = t('settings.s3TestUnavailable');
    return;
  }

  ensureDomainEndpoint(settingsForm);

  isS3Testing.value = true;
  s3TestStatus.value = t('settings.s3TestInProgress');
  try {
    const result = await window.electronAPI.checkS3Connection();
    if (result?.success) {
      s3TestStatus.value = t('settings.s3TestSuccess');
    } else if (result?.errorCode === 'NOT_CONFIGURED') {
      s3TestStatus.value = t('settings.s3NotConfigured');
    } else {
      const errorMessage = (result?.error || '').trim();
      s3TestStatus.value = `${t('settings.s3TestFailed')} ${errorMessage}`.trim();
    }
  } catch (error) {
    s3TestStatus.value = `${t('settings.s3TestFailed')} ${error?.message || ''}`.trim();
  } finally {
    isS3Testing.value = false;
  }
};

const openSettings = () => {
  // Переходим на страницу настроек.
  settingsStatus.value = t('settings.openingPanel');
  currentPage.value = 'settings';
};

const goHome = () => {
  // Возвращаемся на главную страницу.
  currentPage.value = 'home';
};

const actions = computed(() => [
  // Список доступных действий на главной странице.
  {
    key: 'fullscreen',
    buttonLabel: t('capture.fullscreenButton'),
    title: t('capture.fullscreenButton'),
    subtitle: t('capture.cardSubtitle'),
    icon: 'fullscreen',
  },
  {
    key: 'area',
    buttonLabel: t('actions.areaButton'),
    title: t('actions.areaButton'),
    subtitle: t('actions.areaSubtitle'),
    icon: 'area',
  },
  {
    key: 'record',
    buttonLabel: t('actions.recordButton'),
    title: t('actions.recordButton'),
    subtitle: t('actions.recordSubtitle'),
    icon: 'record',
    active: isRecording.value,
  },
]);

const actionHandlers = {
  fullscreen: captureFullScreen,
  area: captureArea,
  record: toggleVideoRecording,
  'stop-recording': stopVideoRecording,
  settings: openSettings,
};

const handleAction = (key) => {
  // Вызываем обработчик для выбранного действия.
  actionHandlers[key]?.();
};

const handleHotkeyCapture = () => {
  // Уведомляем, что захват горячими клавишами недоступен.
  settingsStatus.value = t('settings.hotkeysDisabled');
};

const handleAreaCrop = (dataUrl) => {
  // Получили результат кадрирования и отправляем в редактор.
  editorImage.value = dataUrl;
  areaImage.value = '';
  currentPage.value = 'editor';
  captureStatus.value = t('capture.statusEditorOpen');
};

const handleAreaCancel = () => {
  // Отменили выделение области, возвращаемся домой.
  currentPage.value = 'home';
  areaImage.value = '';
  captureStatus.value = t('capture.statusAreaCanceled');
};

onMounted(() => {
  loadSettings();
  if (window.electronAPI) {
    electronVersion.value = window.electronAPI.getElectronVersion();
    if (window.electronAPI.onTrayAction) {
      trayActionRemover = window.electronAPI.onTrayAction(handleAction);
    }
    if (window.electronAPI.onUploadProgress) {
      uploadProgressRemover = window.electronAPI.onUploadProgress(handleUploadProgress);
    }
  }
});

onBeforeUnmount(() => {
  if (trayActionRemover) {
    trayActionRemover();
  }
  if (uploadProgressRemover) {
    uploadProgressRemover();
  }
});

</script>
