## Desktop source через IPC
- удалил прямое использование `desktopCapturer` из `preload.js` и заменил его на `ipcRenderer.invoke('get-desktop-source')`, чтобы избежать ошибки `desktop-capturer-unavailable` (`app/src/preload.js:13-22`);
- добавил `ipcMain`-хендлер `get-desktop-source` в `classes/IpcHandlers` с использованием `desktopCapturer.getSources`, чтобы вызов всегда происходил из main-процесса и всегда возвращал рабочий `sourceId` для записи видео (`app/src/classes/IpcHandlers.js:25-92`).
