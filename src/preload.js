const { contextBridge } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  getElectronVersion: () => process.versions.electron,
});
