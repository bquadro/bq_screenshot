export default class CaptureService {
  async capture() {
    return window.electronAPI.captureScreenshot();
  }

  async save(data) {
    return window.electronAPI.saveScreenshot(data);
  }
}
