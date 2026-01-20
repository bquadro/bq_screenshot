export const createDefaultForm = () => ({
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

export const applyLoadedSettings = (loaded, settingsForm) => {
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
};

export const gatherSettingsPayload = (settingsForm, language) => ({
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
  language,
});

export const buildHotkeyBindings = (settingsForm) => {
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
