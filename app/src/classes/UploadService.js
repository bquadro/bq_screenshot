export default class UploadService {
  async upload(filePath) {
    if (!window.electronAPI?.uploadScreenshot) {
      return { url: null };
    }
    return window.electronAPI.uploadScreenshot(filePath);
  }
}
