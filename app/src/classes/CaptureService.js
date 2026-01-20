export default class CaptureService {
  async capture() {
    // Делает скриншот через Electron API.
    return window.electronAPI.captureScreenshot();
  }

  async save(data, filePath = '') {
    // Просит main процесc сохранить base64-представление изображения.
    return window.electronAPI.saveScreenshot({ data, filePath });
  }
}
