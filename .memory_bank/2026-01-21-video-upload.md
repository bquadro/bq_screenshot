## Видео загрузка
- добавил зависимость `mime-types` и заставил `UploadController` определять Content-Type по расширению, теперь `uploadVideo` может отправлять `video/webm` (`app/src/classes/UploadController.js:1-37`);
- унифицировал загрузку через новый IPC `upload-file`/`uploadFile`, `UploadService` передаёт `filePath` + опциональный `contentType`, `preload.js` вызывает `ipcRenderer.invoke('upload-file', payload)` (`app/src/preload.js:39-53`, `app/src/classes/UploadService.js:1-10`, `app/src/classes/IpcHandlers.js:25-110`);
- после записи видео (`app/src/App.vue:295-320`) теперь `updateUploadLink` вызывается для результата, чтобы автоматически отправлять видео в S3 при включённой загрузке и показывать ссылку в UI.
