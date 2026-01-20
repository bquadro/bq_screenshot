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
import translations from './lang/index.js';
import uiConfig from './config/ui.js';

const localizationService = new LocalizationService(translations);
const settingsService = new SettingsService();
const captureService = new CaptureService();
const uploadService = new UploadService();

// Возвращает шаблон структуры формы настроек.
const createDefaultForm = () => ({
  fullScreenCapture: true,
  areaCapture: true,
  videoCapture: false,
  screenshotEditor: true,
  minimizeToTray: true,
  hotkeyFullScreen: 'CmdOrCtrl+Shift+W',
  hotkeyArea: 'CmdOrCtrl+Shift+E',
  hotkeyVideo: 'CmdOrCtrl+Shift+R',
  hotkeyEditor: 'CmdOrCtrl+Shift+T',
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
let trayActionRemover = null;
const screenshotPath = ref('');
const uploadedLink = ref('');
const linkStatus = ref('');
const isS3Testing = ref(false);
const s3TestStatus = ref('');

const normalizeS3Endpoint = (value = '') => {
  const trimmed = (value || '').trim();
  if (!trimmed) {
    return '';
  }
  const withoutProtocol = trimmed.replace(/^[a-z]+:\/\//i, '');
  return withoutProtocol.replace(/\/.*$/, '');
};

const ensureDomainEndpoint = () => {
  const normalized = normalizeS3Endpoint(settingsForm.s3Endpoint);
  if (normalized !== settingsForm.s3Endpoint) {
    settingsForm.s3Endpoint = normalized;
  }
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
const t = (key) => localizationService.t(key);

const applyLoadedSettings = (loaded) => {
  // Применяем загруженные значения настроек к форме.
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
  registerHotkeys();
};

const registerHotkeys = () => {
  const bindings = buildHotkeyBindings();
  if (window.electronAPI?.registerGlobalHotkeys) {
    window.electronAPI.registerGlobalHotkeys(bindings);
  }
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

  ensureDomainEndpoint();

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

const captureFullScreen = async () => {
  // Делаем полноэкранный скриншот и открываем редактор.
  captureStatus.value = t('capture.statusSaving');
  isCapturing.value = true;
  previewUrl.value = '';

  try {
    const base64 = await captureService.capture();
    editorImage.value = `data:image/png;base64,${base64}`;
    currentPage.value = 'editor';
    captureStatus.value = t('capture.statusEditorOpen');

    const saved = await captureService.save(base64);
    if (saved?.filePath) {
      screenshotPath.value = saved.filePath;
      await updateUploadLink(saved.filePath);
    } else {
      captureStatus.value = t('capture.statusNoPath');
    }

    await showWindowAfterCapture();
  } catch (error) {
    console.error('capture', error);
    captureStatus.value = `${t('capture.statusError')} ${error?.message || t('capture.statusUnknownError')}`;
    previewUrl.value = '';
  } finally {
    isCapturing.value = false;
  }
};

const captureArea = async () => {
  // Захватываем скриншот области и показываем страницу выбора.
  captureStatus.value = t('capture.areaSelecting');
  isCapturing.value = true;
  previewUrl.value = '';

  try {
    const base64 = await captureService.capture();
    areaImage.value = `data:image/png;base64,${base64}`;
    currentPage.value = 'area';

    const saved = await captureService.save(base64);
    if (saved?.filePath) {
      screenshotPath.value = saved.filePath;
      await updateUploadLink(saved.filePath);
    } else {
      captureStatus.value = t('capture.statusNoPath');
    }

    await showWindowAfterCapture();
  } catch (error) {
    console.error('capture area', error);
    captureStatus.value = `${t('capture.statusError')} ${error?.message || t('capture.statusAreaError')}`;
  } finally {
    isCapturing.value = false;
  }
};

const showWindowAfterCapture = async () => {
  if (!window.electronAPI?.showMainWindow) {
    return;
  }
  try {
    await window.electronAPI.showMainWindow();
  } catch (error) {
    console.error('show window', error);
  }
};

const updateUploadLink = async (filePath) => {
  if (!filePath) {
    uploadedLink.value = '';
    linkStatus.value = '';
    return;
  }
  if (!settingsForm.uploadToS3) {
    uploadedLink.value = '';
    linkStatus.value = '';
    return;
  }

  try {
    const { url, error } = await uploadService.upload(filePath);
    if (url) {
      uploadedLink.value = url;
      linkStatus.value = t('capture.linkCopied');
    } else {
      uploadedLink.value = '';
      linkStatus.value = error ? `${t('capture.linkUploadError')} ${error}` : t('capture.linkUploadFailed');
    }
  } catch (uploadError) {
    uploadedLink.value = '';
    linkStatus.value = `${t('capture.linkUploadError')} ${uploadError?.message || ''}`;
  }
};

const copyUploadedLink = async () => {
  if (!uploadedLink.value) {
    return;
  }
  try {
    await navigator.clipboard.writeText(uploadedLink.value);
    linkStatus.value = t('capture.linkCopied');
  } catch (error) {
    console.error('clipboard copy', error);
    linkStatus.value = `${t('capture.linkUploadError')} ${error?.message || ''}`;
  }
};

const testS3Connection = async () => {
  if (!window.electronAPI?.checkS3Connection) {
    s3TestStatus.value = t('settings.s3TestUnavailable');
    return;
  }

  ensureDomainEndpoint();

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

const startRecording = () => {
  // Заглушка для записи видео (пока только отображение статуса).
  captureStatus.value = t('capture.recordingPlaceholder');
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
  },
]);

const actionHandlers = {
  fullscreen: captureFullScreen,
  area: captureArea,
  record: startRecording,
  settings: openSettings,
};

const buildHotkeyBindings = () => {
  const bindings = {};
  if (settingsForm.fullScreenCapture && settingsForm.hotkeyFullScreen?.trim()) {
    bindings[settingsForm.hotkeyFullScreen.trim()] = 'fullscreen';
  }
  if (settingsForm.areaCapture && settingsForm.hotkeyArea?.trim()) {
    bindings[settingsForm.hotkeyArea.trim()] = 'area';
  }
  if (settingsForm.videoCapture && settingsForm.hotkeyVideo?.trim()) {
    bindings[settingsForm.hotkeyVideo.trim()] = 'record';
  }
  if (settingsForm.screenshotEditor && settingsForm.hotkeyEditor?.trim()) {
    bindings[settingsForm.hotkeyEditor.trim()] = 'settings';
  }
  return bindings;
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

const handleEditorSave = async (dataUrl) => {
  // Сохраняем изображение из редактора и показываем превью.
  currentPage.value = 'home';
  isCapturing.value = true;
  captureStatus.value = t('capture.statusSaving');

  try {
    const base64Payload = dataUrl.split(',')[1];
    const result = await captureService.save(base64Payload, screenshotPath.value);
    if (result?.filePath) {
      screenshotPath.value = result.filePath;
      await updateUploadLink(result.filePath);
    }
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
  // Закрываем редактор без сохранения.
  currentPage.value = 'home';
  captureStatus.value = t('capture.statusEditorCanceled');
  isCapturing.value = false;
  editorImage.value = '';
};

onMounted(() => {
  loadSettings();
  if (window.electronAPI) {
    electronVersion.value = window.electronAPI.getElectronVersion();
    if (window.electronAPI.onTrayAction) {
      trayActionRemover = window.electronAPI.onTrayAction(handleAction);
    }
  }
});

onBeforeUnmount(() => {
  if (trayActionRemover) {
    trayActionRemover();
  }
});

</script>
