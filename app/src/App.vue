<template>
  <main class="container-xl d-flex flex-column min-vh-100">
    <AppHeader
      :logo-path="uiConfig.logoPath"
      :title="uiConfig.title"
      :description="t('app.description')"
      :current-page="currentPage"
      :settings-label="t('header.settingsButton')"
      :back-label="t('header.backButton')"
      :status="settingsStatus"
      @open-settings="openSettings"
      @go-home="goHome"
    />

    <HomeActions
      v-if="currentPage === 'home'"
      :actions="actions"
      :is-capturing="isCapturing"
      :capture-status="captureStatus"
      :preview-url="previewUrl"
      @run-action="handleAction"
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
      @save-settings="saveSettings"
      @update:language="handleLanguageUpdate"
      @capture-hotkey="handleHotkeyCapture"
      @select-save-folder="chooseSaveFolder"
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
import { reactive, ref, watch, onMounted, computed } from 'vue';
import AppHeader from './components/AppHeader.vue';
import HomeActions from './components/HomeActions.vue';
import SettingsForm from './components/SettingsForm.vue';
import AreaSelectionPage from './components/AreaSelectionPage.vue';
import ImageEditorPage from './components/ImageEditorPage.vue';
import LocalizationService from './classes/LocalizationService.js';
import SettingsService from './classes/SettingsService.js';
import CaptureService from './classes/CaptureService.js';
import translations from './lang/index.js';
import uiConfig from './config/ui.js';

const localizationService = new LocalizationService(translations);
const settingsService = new SettingsService();
const captureService = new CaptureService();

const createDefaultForm = () => ({
  fullScreenCapture: true,
  areaCapture: true,
  videoCapture: false,
  screenshotEditor: true,
  minimizeToTray: true,
  hotkeyFullScreen: 'CmdOrCtrl+Shift+1',
  hotkeyArea: 'CmdOrCtrl+Shift+2',
  hotkeyVideo: 'CmdOrCtrl+Shift+3',
  hotkeyEditor: 'CmdOrCtrl+Shift+4',
  saveFolder: '',
  uploadToS3: false,
  s3Endpoint: '',
  s3Region: 'us-east-1',
  s3Bucket: '',
  s3AccessKey: '',
  s3SecretKey: '',
  s3UseSsl: true,
});

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

watch(language, (value) => {
  localizationService.setLanguage(value);
  settingsStatus.value = localizationService.t('settings.statusLoaded');
  captureStatus.value = localizationService.t('capture.statusInitial');
});

const handleLanguageUpdate = (value) => {
  language.value = value;
};

const t = (key) => localizationService.t(key);

const applyLoadedSettings = (loaded) => {
  settingsForm.fullScreenCapture = Boolean(loaded.screenshots?.fullScreen);
  settingsForm.areaCapture = Boolean(loaded.screenshots?.area);
  settingsForm.videoCapture = Boolean(loaded.videoCapture?.enabled);
  settingsForm.screenshotEditor = Boolean(loaded.editor?.enabled);
  settingsForm.minimizeToTray = Boolean(loaded.tray?.minimizeToTray);
  settingsForm.hotkeyFullScreen = loaded.hotkeys?.captureFullScreen || settingsForm.hotkeyFullScreen;
  settingsForm.hotkeyArea = loaded.hotkeys?.captureArea || settingsForm.hotkeyArea;
  settingsForm.hotkeyVideo = loaded.hotkeys?.captureVideo || settingsForm.hotkeyVideo;
  settingsForm.hotkeyEditor = loaded.hotkeys?.openEditor || settingsForm.hotkeyEditor;
  settingsForm.saveFolder = loaded.storage?.folder || settingsForm.saveFolder;
  settingsForm.uploadToS3 = Boolean(loaded.s3?.uploadOnCapture || loaded.s3?.enabled);
  settingsForm.s3Endpoint = loaded.s3?.endpoint || settingsForm.s3Endpoint;
  settingsForm.s3Region = loaded.s3?.region || settingsForm.s3Region;
  settingsForm.s3Bucket = loaded.s3?.bucket || settingsForm.s3Bucket;
  settingsForm.s3AccessKey = loaded.s3?.accessKey || settingsForm.s3AccessKey;
  settingsForm.s3SecretKey = loaded.s3?.secretKey || settingsForm.s3SecretKey;
  settingsForm.s3UseSsl = Boolean(loaded.s3?.useSsl);
  language.value = loaded.language || language.value;
};

const gatherPayload = () => ({
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
  settingsStatus.value = t('settings.statusSaving');
  isSaving.value = true;

  try {
    await settingsService.save(gatherPayload());
    settingsStatus.value = t('settings.statusSaved');
  } catch (error) {
    console.error('settings save', error);
    settingsStatus.value = t('settings.statusSaveError');
  } finally {
    isSaving.value = false;
  }
};

const chooseSaveFolder = async () => {
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

const captureFullScreen = async () => {
  captureStatus.value = t('capture.statusSaving');
  isCapturing.value = true;
  previewUrl.value = '';

  try {
    const base64 = await captureService.capture();
    editorImage.value = `data:image/png;base64,${base64}`;
    currentPage.value = 'editor';
    captureStatus.value = t('capture.statusEditorOpen');
  } catch (error) {
    console.error('capture', error);
    captureStatus.value = `${t('capture.statusError')} ${error?.message || t('capture.statusUnknownError')}`;
    previewUrl.value = '';
  } finally {
    isCapturing.value = false;
  }
};

const captureArea = async () => {
  captureStatus.value = t('capture.areaSelecting');
  isCapturing.value = true;
  previewUrl.value = '';

  try {
    const base64 = await captureService.capture();
    areaImage.value = `data:image/png;base64,${base64}`;
    currentPage.value = 'area';
  } catch (error) {
    console.error('capture area', error);
    captureStatus.value = `${t('capture.statusError')} ${error?.message || t('capture.statusAreaError')}`;
  } finally {
    isCapturing.value = false;
  }
};

const startRecording = () => {
  captureStatus.value = t('capture.recordingPlaceholder');
};

const openSettings = () => {
  settingsStatus.value = t('settings.openingPanel');
  currentPage.value = 'settings';
};

const goHome = () => {
  currentPage.value = 'home';
};

const actions = computed(() => [
  {
    key: 'fullscreen',
    buttonLabel: t('capture.fullscreenButton'),
    title: t('capture.fullscreenButton'),
    subtitle: t('capture.cardSubtitle'),
  },
  {
    key: 'area',
    buttonLabel: t('actions.areaButton'),
    title: t('actions.areaButton'),
    subtitle: t('actions.areaSubtitle'),
  },
  {
    key: 'record',
    buttonLabel: t('actions.recordButton'),
    title: t('actions.recordButton'),
    subtitle: t('actions.recordSubtitle'),
  },
]);

const actionHandlers = {
  fullscreen: captureFullScreen,
  area: captureArea,
  record: startRecording,
};

const handleAction = (key) => {
  actionHandlers[key]?.();
};

const handleHotkeyCapture = () => {
  settingsStatus.value = t('settings.hotkeysDisabled');
};

const handleAreaCrop = (dataUrl) => {
  editorImage.value = dataUrl;
  areaImage.value = '';
  currentPage.value = 'editor';
  captureStatus.value = t('capture.statusEditorOpen');
};

const handleAreaCancel = () => {
  currentPage.value = 'home';
  areaImage.value = '';
  captureStatus.value = t('capture.statusAreaCanceled');
};

const handleEditorSave = async (dataUrl) => {
  currentPage.value = 'home';
  isCapturing.value = true;
  captureStatus.value = t('capture.statusSaving');

  try {
    const base64Payload = dataUrl.split(',')[1];
    const result = await captureService.save(base64Payload);
    previewUrl.value = dataUrl;
    captureStatus.value = `${t('capture.statusSaved')} ${result.filePath}`;
  } catch (error) {
    console.error('editor save', error);
    captureStatus.value = `${t('capture.statusError')} ${error?.message || t('capture.statusUnknownError')}`;
  } finally {
    isCapturing.value = false;
    editorImage.value = '';
  }
};

const handleEditorCancel = () => {
  currentPage.value = 'home';
  captureStatus.value = t('capture.statusEditorCanceled');
  isCapturing.value = false;
  editorImage.value = '';
};

onMounted(() => {
  loadSettings();
  if (window.electronAPI) {
    electronVersion.value = window.electronAPI.getElectronVersion();
  }
});

</script>
