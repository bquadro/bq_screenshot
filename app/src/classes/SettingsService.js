export default class SettingsService {
  async load() {
    // Получаем настройки через IPC и возвращаем результат.
    return window.electronAPI.loadSettings();
  }

  async save(payload) {
    // Сохраняем настройки через IPC.
    return window.electronAPI.saveSettings(payload);
  }

  async selectFolder() {
    // Запускаем диалог выбора папки через IPC.
    return window.electronAPI.selectSaveFolder();
  }
}
