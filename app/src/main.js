import { app, BrowserWindow } from 'electron';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import SettingsStorage from './classes/SettingsStorage.js';
import IpcHandlers from './classes/IpcHandlers.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Создаёт главное окно и загружает туда рендерерный контент.
const createMainWindow = () => {
  const mainWindow = new BrowserWindow({
    width: 1280,
    height: 720,
    webPreferences: {
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  if (MAIN_WINDOW_VITE_DEV_SERVER_URL) {
    mainWindow.loadURL(MAIN_WINDOW_VITE_DEV_SERVER_URL);
  } else {
    mainWindow.loadFile(path.join(__dirname, `../renderer/${MAIN_WINDOW_VITE_NAME}/index.html`));
  }

  mainWindow.setMenu(null);
};

const settingsStorage = new SettingsStorage(app);
const ipcHandlers = new IpcHandlers(app, settingsStorage);
ipcHandlers.register();

// Инициализация приложения: открываем окно и настраиваем поведение активации.
app.whenReady().then(() => {
  createMainWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
    }
  });
});

// Завершаем приложение на не-macOS после закрытия всех окон.
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
