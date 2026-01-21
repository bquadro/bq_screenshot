import { clipboard } from 'electron';
import path from 'node:path';
import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { lookup } from 'mime-types';
import { S3Client, HeadBucketCommand } from '@aws-sdk/client-s3';
import { Upload } from '@aws-sdk/lib-storage';

export default class UploadController {
  constructor(settingsStorage) {
    this.settingsStorage = settingsStorage;
  }

  async upload(filePath, { contentType } = {}, onProgress) {
    if (!filePath) {
      return { url: null };
    }
    const config = await this.loadConfig({ requireEnabled: false });
    if (!config) {
      return { url: null };
    }
    try {
      const client = this.createClient(config);
      const key = path.basename(filePath);
      const resolvedType = contentType || lookup(filePath) || 'application/octet-stream';
      const fileStats = await stat(filePath);
      const totalBytes = fileStats?.size || 0;
      const stream = createReadStream(filePath);

      const upload = new Upload({
        client,
        params: {
          Bucket: config.bucket,
          Key: key,
          Body: stream,
          ContentType: resolvedType,
          ContentLength: totalBytes,
        },
      });

      let uploadedBytes = 0;
      let lastPercent = -1;

      const notifyProgress = (payload) => {
        if (typeof onProgress === 'function') {
          onProgress(payload);
        }
      };

      const notifyPercent = (percent) => {
        if (typeof percent !== 'number') {
          return;
        }
        const normalized = Math.min(100, Math.max(0, Math.round(percent)));
        if (normalized === lastPercent) {
          return;
        }
        lastPercent = normalized;
        notifyProgress({ percent: normalized });
      };

      stream.on('data', (chunk) => {
        uploadedBytes += chunk.length;
        if (totalBytes > 0) {
          const percent = (uploadedBytes / totalBytes) * 100;
          notifyPercent(percent);
        }
      });

      stream.on('error', (error) => {
        notifyProgress({ error: error?.message || error });
      });

      upload.on('httpUploadProgress', (progress) => {
        if (typeof progress?.loaded === 'number') {
          let percent;
          if (typeof progress?.total === 'number' && progress.total > 0) {
            percent = (progress.loaded / progress.total) * 100;
          } else if (totalBytes > 0) {
            percent = (progress.loaded / totalBytes) * 100;
          }
          notifyPercent(percent);
        }
      });

      await upload.done();
      notifyPercent(100);
      const url = this.buildUrl(config, key);
      clipboard.writeText(url);
      return { url };
    } catch (error) {
      console.error('upload screenshot', error);
      if (typeof onProgress === 'function') {
        onProgress({ error: error?.message || error });
      }
      return { url: null, error: error.message };
    }
  }

  async checkConnection() {
    const config = await this.loadConfig();
    console.log(config);
    if (!config) {
      return { success: false, errorCode: 'NOT_CONFIGURED', error: 'S3/Minio не настроен.' };
    }
    try {
      const client = this.createClient(config);
      await client.send(new HeadBucketCommand({ Bucket: config.bucket }));
      return { success: true };
    } catch (error) {
      console.error('check s3 connection', error);
      return { success: false, errorCode: 'HEAD_BUCKET_FAILED', error: error.message };
    }
  }

  async loadConfig({ requireEnabled = true } = {}) {
    const settings = await this.settingsStorage.load();
    const config = settings.s3 || {};
    const endpoint = (config.endpoint || '').trim();
    const bucket = (config.bucket || '').trim();
    const accessKey = (config.accessKey || '').trim();
    const secretKey = (config.secretKey || '').trim();
    if ((requireEnabled && !config.enabled) || !endpoint || !bucket || !accessKey || !secretKey) {
      return null;
    }
    return {
      endpoint,
      bucket,
      accessKey,
      secretKey,
      region: config.region || 'us-east-1',
      useSsl: config.useSsl !== false,
    };
  }

  buildEndpointUrl(config) {
    const host = this.normalizeHost(config.endpoint);
    const scheme = config.useSsl ? 'https' : 'http';
    return `${scheme}://${host}`;
  }

  normalizeHost(value = '') {
    const cleaned = (value || '').trim().replace(/^[a-z]+:\/\//i, '');
    return cleaned.replace(/\/.*$/, '');
  }

  createClient(config) {
    return new S3Client({
      endpoint: this.buildEndpointUrl(config),
      region: config.region,
      credentials: {
        accessKeyId: config.accessKey,
        secretAccessKey: config.secretKey,
      },
      forcePathStyle: true,
      tls: config.useSsl,
    });
  }

  buildUrl(config, key) {
    const base = this.buildEndpointUrl(config);
    const encodedKey = encodeURIComponent(key);
    return `${base}/${config.bucket}/${encodedKey}`;
  }
}
