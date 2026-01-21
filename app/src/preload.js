import { contextBridge, ipcRenderer } from 'electron';

// Делает скриншот используя main-процесс и возвращает base64.
const captureScreenshot = async () => {
  const buffer = await ipcRenderer.invoke('capture-screenshot');
  if (!buffer) {
    throw new Error('Не удалось получить снимок экрана');
  }

  return Buffer.from(buffer).toString('base64');
};

const getPrimaryScreenSourceId = async () => {
  return ipcRenderer.invoke('get-desktop-source');
};

const onTrayAction = (callback) => {
  if (typeof callback !== 'function') {
    return () => {};
  }

  const listener = (_event, action) => {
    callback(action);
  };

  ipcRenderer.on('tray-action', listener);
  return () => {
    ipcRenderer.removeListener('tray-action', listener);
  };
};

contextBridge.exposeInMainWorld('electronAPI', {
  getElectronVersion: () => process.versions.electron,
  captureScreenshot,
  saveScreenshot: ({ data, filePath }) => ipcRenderer.invoke('save-screenshot', { data, filePath }),
  loadSettings: () => ipcRenderer.invoke('load-settings'),
  saveSettings: (settings) => ipcRenderer.invoke('save-settings', settings),
  selectSaveFolder: () => ipcRenderer.invoke('choose-save-folder'),
  onTrayAction,
  registerGlobalHotkeys: (bindings) => ipcRenderer.invoke('register-global-hotkeys', bindings),
  showMainWindow: () => ipcRenderer.invoke('show-main-window'),
  uploadScreenshot: (filePath) => ipcRenderer.invoke('upload-screenshot', filePath),
  saveVideo: (payload) => ipcRenderer.invoke('save-video', payload),
  setTrayRecordingState: (isRecording) => ipcRenderer.invoke('set-tray-recording', isRecording),
  checkS3Connection: () => ipcRenderer.invoke('check-s3-connection'),
  getPrimaryScreenSourceId,
});
