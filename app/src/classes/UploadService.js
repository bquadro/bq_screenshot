export default class UploadService {
  async upload(filePath, options = {}) {
    if (!window.electronAPI?.uploadFile) {
      return { url: null };
    }
    return window.electronAPI.uploadFile({ filePath, ...options });
  }
}
