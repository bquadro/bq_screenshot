export default class VideoRecorder {
  constructor() {
    this.mediaRecorder = null;
    this.stream = null;
    this.chunks = [];
  }

  get isRecording() {
    return this.mediaRecorder && this.mediaRecorder.state !== 'inactive';
  }

  async start() {
    if (!navigator.mediaDevices?.getDisplayMedia) {
      throw new Error('display-media-not-supported');
    }
    if (this.isRecording) {
      throw new Error('already-recording');
    }

    this.stream = await navigator.mediaDevices.getDisplayMedia({
      video: { frameRate: 30 },
      audio: false,
    });
    this.mediaRecorder = this.createMediaRecorder([
      'video/webm;codecs=vp9',
      'video/webm;codecs=vp8',
      'video/webm',
    ]);
    this.chunks = [];

    this.mediaRecorder.ondataavailable = (event) => {
      if (event.data && event.data.size > 0) {
        this.chunks.push(event.data);
      }
    };

    this.mediaRecorder.onerror = (event) => {
      console.error('mediaRecorder error', event.error);
    };

    this.mediaRecorder.start(1000);
  }

  createMediaRecorder(candidates = []) {
    for (const mimeType of candidates) {
      try {
        if (mimeType && !MediaRecorder.isTypeSupported(mimeType)) {
          continue;
        }
        return new MediaRecorder(this.stream, mimeType ? { mimeType } : undefined);
      } catch (error) {
        console.warn('mediaRecorder unsupported mime type', mimeType, error?.message);
      }
    }
    try {
      return new MediaRecorder(this.stream);
    } catch (error) {
      console.error('mediaRecorder initialization failed', error);
      throw new Error('media-recorder-not-supported');
    }
  }

  stop() {
    if (!this.isRecording) {
      return Promise.resolve(null);
    }

    return new Promise((resolve) => {
      this.mediaRecorder.onstop = () => {
        const blob = new Blob(this.chunks, { type: this.mediaRecorder.mimeType || 'video/webm' });
        this.stream?.getTracks().forEach((track) => track.stop());
        this.stream = null;
        this.mediaRecorder = null;
        resolve(blob);
      };
      this.mediaRecorder.stop();
    });
  }
}
