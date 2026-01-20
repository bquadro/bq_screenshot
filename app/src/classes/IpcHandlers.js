import { dialog, ipcMain } from 'electron';
import path from 'node:path';
import { writeFile, mkdir } from 'node:fs/promises';
import screenshot from 'screenshot-desktop';

export default class IpcHandlers {
  constructor(appInstance, settingsStorage) {
    // Сохраняем зависимости и рассчитываем дефолтную папку сразу.
    this.app = appInstance;
    this.settingsStorage = settingsStorage;
    this.fallbackFolder = this.getFallbackFolder();
  }

  getFallbackFolder() {
    // Формируем путь к папке скриншотов в Pictures.
    return path.join(this.app.getPath('pictures'), 'bq-screenshots');
  }

  register() {
    // Регистрируем все ipcMain-хендлеры централизованно.
    ipcMain.handle('load-settings', () => this.settingsStorage.load());
    ipcMain.handle('save-settings', (_event, payload) => this.settingsStorage.save(payload));
    ipcMain.handle('capture-screenshot', () => this.handleCaptureScreenshot());
    ipcMain.handle('choose-save-folder', () => this.handleChooseSaveFolder());
    ipcMain.handle('save-screenshot', (_event, payload) => this.handleSaveScreenshot(payload));
  }

  async handleCaptureScreenshot() {
    // Делаем скриншот с помощью screenshot-desktop и возвращаем буфер.
    const buffer = await screenshot({ format: 'png' });
    if (!buffer) {
      throw new Error('Не удалось создать скриншот');
    }
    return buffer;
  }

  async handleChooseSaveFolder() {
    // Вызываем диалог выбора папки и возвращаем путь, или null если отмена.
    const settings = await this.settingsStorage.load();
    const defaultFolder = settings.storage?.folder?.trim() || this.fallbackFolder;

    const { canceled, filePaths } = await dialog.showOpenDialog({
      title: 'Выберите папку сохранения скриншотов',
      defaultPath: path.resolve(defaultFolder),
      properties: ['openDirectory', 'createDirectory'],
    });

    if (canceled || !filePaths?.length) {
      return null;
    }

    return filePaths[0];
  }

  async handleSaveScreenshot(payload = {}) {
    // Сохраняем переданный base64-данные изображения в выбранную папку.
    const { data } = payload;
    if (!data) {
      throw new Error('Отсутствуют данные скриншота');
    }

    const screenshotBuffer = Buffer.from(data, 'base64');
    const settings = await this.settingsStorage.load();
    const configuredFolder = settings.storage?.folder?.trim() || this.fallbackFolder;
    const targetFolder = path.resolve(configuredFolder);
    const fileName = `bq-screenshot-${Date.now()}.png`;
    const filePath = path.join(targetFolder, fileName);

    await mkdir(targetFolder, { recursive: true });
    await writeFile(filePath, screenshotBuffer);

    return { canceled: false, filePath };
  }
}
