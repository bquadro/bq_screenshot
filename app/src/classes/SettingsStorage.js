import path from 'node:path';
import { writeFile, readFile, mkdir } from 'node:fs/promises';

export default class SettingsStorage {
  constructor(appInstance) {
    // Храним ссылку на экземпляр app для доступа к путям.
    this.app = appInstance;
  }

  getFilePath() {
    // Возвращаем путь к файлу settings.json внутри userData.
    return path.join(this.app.getPath('userData'), 'settings.json');
  }

  createDefaultSettings() {
    // Отдаём полный набор стандартных значений настроек.
    return {
      screenshots: {
        fullScreen: true,
        area: true,
      },
      videoCapture: {
        enabled: false,
      },
      editor: {
        enabled: true,
      },
      tray: {
        minimizeToTray: true,
      },
      hotkeys: {
        captureFullScreen: 'CmdOrCtrl+Shift+1',
        captureArea: 'CmdOrCtrl+Shift+2',
        captureVideo: 'CmdOrCtrl+Shift+3',
        openEditor: 'CmdOrCtrl+Shift+4',
      },
      storage: {
        folder: path.join(this.app.getPath('pictures'), 'bq-screenshots'),
      },
      s3: {
        enabled: false,
        endpoint: '',
        bucket: '',
        accessKey: '',
        secretKey: '',
        region: 'us-east-1',
        useSsl: true,
        uploadOnCapture: false,
      },
      language: 'ru',
    };
  }

  mergeSettings(defaults, incoming = {}) {
    // Объединяем пользовательские значения с дефолтами рекурсивно.
    return {
      ...defaults,
      ...incoming,
      screenshots: { ...defaults.screenshots, ...(incoming.screenshots || {}) },
      videoCapture: { ...defaults.videoCapture, ...(incoming.videoCapture || {}) },
      editor: { ...defaults.editor, ...(incoming.editor || {}) },
      tray: { ...defaults.tray, ...(incoming.tray || {}) },
      hotkeys: { ...defaults.hotkeys, ...(incoming.hotkeys || {}) },
      storage: { ...defaults.storage, ...(incoming.storage || {}) },
      s3: { ...defaults.s3, ...(incoming.s3 || {}) },
      language: incoming.language || defaults.language,
    };
  }

  async load() {
    // Загружаем настройки из файла, если они есть, иначе возвращаем дефолты.
    const defaults = this.createDefaultSettings();
    try {
      const raw = await readFile(this.getFilePath(), 'utf8');
      const parsed = JSON.parse(raw);
      return this.mergeSettings(defaults, parsed);
    } catch (error) {
      return defaults;
    }
  }

  async save(payload) {
    // Сохраняем нормализованные настройки в файл settings.json.
    const normalized = this.mergeSettings(this.createDefaultSettings(), payload);
    await mkdir(path.dirname(this.getFilePath()), { recursive: true });
    await writeFile(this.getFilePath(), JSON.stringify(normalized, null, 2), 'utf8');
    return normalized;
  }
}
