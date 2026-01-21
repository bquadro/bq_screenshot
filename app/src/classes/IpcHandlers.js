import { dialog, desktopCapturer, ipcMain } from 'electron';
import path from 'node:path';
import { writeFile, mkdir } from 'node:fs/promises';
import screenshot from 'screenshot-desktop';

export default class IpcHandlers {
  constructor(appInstance, settingsStorage, uploadController) {
    // Сохраняем зависимости и рассчитываем дефолтную папку сразу.
    this.app = appInstance;
    this.settingsStorage = settingsStorage;
    this.uploadController = uploadController;
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
    ipcMain.handle('save-video', (_event, payload) => this.handleSaveVideo(payload));
    ipcMain.handle('upload-file', (event, payload) => this.handleUploadFile(payload, event));
    ipcMain.handle('check-s3-connection', () => this.handleCheckS3Connection());
    ipcMain.handle('get-desktop-source', () => this.handleGetDesktopSource());
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
    let filePath = payload.filePath?.trim();
    if (!filePath) {
      const fileName = `bq-screenshot-${Date.now()}.png`;
      filePath = path.join(targetFolder, fileName);
    }

    await mkdir(path.dirname(filePath), { recursive: true });
    await writeFile(filePath, screenshotBuffer);

    return { canceled: false, filePath };
  }

  async handleSaveVideo(payload = {}) {
    const { data } = payload;
    if (!data) {
      throw new Error('Отсутствуют данные видео');
    }

    const videoBuffer = Buffer.from(data, 'base64');
    const settings = await this.settingsStorage.load();
    const configuredFolder = settings.storage?.folder?.trim() || this.fallbackFolder;
    const targetFolder = path.resolve(configuredFolder);
    const fileName = `bq-video-${Date.now()}.webm`;
    const filePath = path.join(targetFolder, fileName);

    await mkdir(path.dirname(filePath), { recursive: true });
    await writeFile(filePath, videoBuffer);

    return { canceled: false, filePath };
  }

  async handleUploadFile(payload = {}, event) {
    if (!this.uploadController) {
      return { url: null };
    }
    const { filePath, contentType, uploadId } = payload || {};
    if (!filePath) {
      return { url: null };
    }

    const progressCallback = (progress) => {
      if (!uploadId || !event?.sender) {
        return;
      }
      const percent = typeof progress?.percent === 'number' ? progress.percent : undefined;
      event.sender.send('upload-progress', {
        uploadId,
        percent,
        error: progress?.error,
      });
    };

    return this.uploadController.upload(filePath, { contentType }, progressCallback);
  }

  async handleCheckS3Connection() {
    if (!this.uploadController) {
      return { success: false, errorCode: 'MISSING_CONTROLLER', error: 'Upload controller unavailable.' };
    }
    return this.uploadController.checkConnection();
  }

  async handleGetDesktopSource() {
    const sources = await desktopCapturer.getSources({
      types: ['screen'],
      thumbnailSize: { width: 0, height: 0 },
    });
    if (!sources?.length) {
      throw new Error('desktop-source-unavailable');
    }
    return sources[0].id;
  }
}
