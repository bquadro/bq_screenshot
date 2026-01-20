export default class VideoService {
  async save(data, filePath = '') {
    if (!window.electronAPI?.saveVideo) {
      throw new Error('video-save-unavailable');
    }
    return window.electronAPI.saveVideo({ data, filePath });
  }
}
