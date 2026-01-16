export default class SettingsService {
  async load() {
    return window.electronAPI.loadSettings();
  }

  async save(payload) {
    return window.electronAPI.saveSettings(payload);
  }

  async selectFolder() {
    return window.electronAPI.selectSaveFolder();
  }
}
