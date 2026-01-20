import { contextBridge, ipcRenderer } from 'electron';

// Делает скриншот используя main-процесс и возвращает base64.
const captureScreenshot = async () => {
  const buffer = await ipcRenderer.invoke('capture-screenshot');
  if (!buffer) {
    throw new Error('Не удалось получить снимок экрана');
  }

  return Buffer.from(buffer).toString('base64');
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
  saveScreenshot: (data) => ipcRenderer.invoke('save-screenshot', { data }),
  loadSettings: () => ipcRenderer.invoke('load-settings'),
  saveSettings: (settings) => ipcRenderer.invoke('save-settings', settings),
  selectSaveFolder: () => ipcRenderer.invoke('choose-save-folder'),
  onTrayAction,
});
