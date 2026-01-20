import { clipboard } from 'electron';
import path from 'node:path';
import { readFile } from 'node:fs/promises';
import { S3Client, PutObjectCommand, HeadBucketCommand } from '@aws-sdk/client-s3';

export default class UploadController {
  constructor(settingsStorage) {
    this.settingsStorage = settingsStorage;
  }

  async upload(filePath) {
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
      const buffer = await readFile(filePath);
      const command = new PutObjectCommand({
        Bucket: config.bucket,
        Key: key,
        Body: buffer,
        ContentType: 'image/png',
      });
      await client.send(command);
      const url = this.buildUrl(config, key);
      clipboard.writeText(url);
      return { url };
    } catch (error) {
      console.error('upload screenshot', error);
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
