import RecordRTC from 'recordrtc';

export default class VideoRecorder {
  constructor() {
    this.recorder = null;
    this.stream = null;
    this.recording = false;
  }

  get isRecording() {
    return this.recording;
  }

  async start() {
    if (this.isRecording) {
      throw new Error('already-recording');
    }

    this.stream = await this.acquireStream();
    try {
      this.recorder = this.createRecorder(this.stream);
      await this.recorder.startRecording();
      this.recording = true;
    } catch (error) {
      this.cleanup();
      throw error;
    }
  }

  async stop() {
    if (!this.isRecording || !this.recorder) {
      return null;
    }

    try {
      await this.recorder.stopRecording();
      const blob = await this.recorder.getBlob();
      return blob;
    } finally {
      this.cleanup();
    }
  }

  cleanup() {
    this.stream?.getTracks().forEach((track) => {
      track.stop();
    });
    this.stream = null;

    if (this.recorder) {
      if (typeof this.recorder.destroy === 'function') {
        this.recorder.destroy();
      } else if (typeof this.recorder.reset === 'function') {
        this.recorder.reset();
      }
    }
    this.recorder = null;
    this.recording = false;
  }

  async acquireStream() {
    const mediaDevices = navigator.mediaDevices;
    if (!mediaDevices) {
      throw new Error('media-devices-unavailable');
    }

    if (typeof mediaDevices.getDisplayMedia === 'function') {
      try {
        return await mediaDevices.getDisplayMedia({
          video: { frameRate: 30 },
          audio: false,
        });
      } catch (error) {
        if (!this.isDisplayMediaUnsupportedError(error)) {
          throw error;
        }
        console.warn('display media unsupported, falling back to desktop capture', error?.message);
      }
    }

    return this.acquireDesktopCaptureStream(mediaDevices);
  }

  isDisplayMediaUnsupportedError(error) {
    const reason = `${error?.name || ''} ${error?.message || ''}`.toLowerCase();
    return reason.includes('not supported') || reason.includes('notsupported') || reason.includes('unsupported');
  }

  async acquireDesktopCaptureStream(mediaDevices) {
    if (typeof mediaDevices.getUserMedia !== 'function') {
      throw new Error('media-devices-not-supported');
    }

    const sourceGetter = window?.electronAPI?.getPrimaryScreenSourceId;
    if (typeof sourceGetter !== 'function') {
      throw new Error('desktop-capture-unavailable');
    }

    const sourceId = await sourceGetter();
    if (!sourceId) {
      throw new Error('desktop-source-unavailable');
    }

    return mediaDevices.getUserMedia({
      audio: false,
      video: {
        mandatory: {
          chromeMediaSource: 'desktop',
          chromeMediaSourceId: sourceId,
          frameRate: 30,
        },
        cursor: 'always',
      },
    });
  }

  createRecorder(stream) {
    const handler = RecordRTC?.RecordRTCPromisesHandler;
    if (typeof handler !== 'function') {
      throw new Error('recordrtc-handler-unavailable');
    }

    const options = {
      type: 'video',
      disableLogs: true,
      timeSlice: 0,
      bitsPerSecond: 2500000,
      videoBitsPerSecond: 2500000,
      frameRate: 30,
    };

    const mimeType = this.selectSupportedMimeType([
      'video/webm;codecs=vp9',
      'video/webm;codecs=vp8',
      'video/webm',
    ]);

    if (mimeType) {
      options.mimeType = mimeType;
    }

    return new handler(stream, options);
  }

  selectSupportedMimeType(candidates = []) {
    if (typeof MediaRecorder === 'undefined' || typeof MediaRecorder.isTypeSupported !== 'function') {
      return candidates[0] || '';
    }

    for (const candidate of candidates) {
      if (!candidate) {
        continue;
      }
      try {
        if (MediaRecorder.isTypeSupported(candidate)) {
          return candidate;
        }
      } catch (error) {
        console.warn('Error checking support for mime type', candidate, error?.message);
      }
    }

    return candidates[0] || '';
  }
}
