import { app, BrowserWindow } from 'electron';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import SettingsStorage from './classes/SettingsStorage.js';
import IpcHandlers from './classes/IpcHandlers.js';
import TrayController from './classes/TrayController.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

let mainWindow;
let quitRequested = false;
const trayController = new TrayController(app, () => mainWindow);

const createMainWindow = () => {
  mainWindow = new BrowserWindow({
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

  mainWindow.on('minimize', (event) => {
    event.preventDefault();
    trayController.ensure();
    trayController.hideDock();
    mainWindow.hide();
  });

  mainWindow.on('close', (event) => {
    if (quitRequested) {
      return;
    }
    event.preventDefault();
    trayController.ensure();
    trayController.hideDock();
    mainWindow.hide();
  });
  mainWindow.on('show', () => {
    trayController.showDock();
  });
};

const settingsStorage = new SettingsStorage(app);
const ipcHandlers = new IpcHandlers(app, settingsStorage);
ipcHandlers.register();

app.whenReady().then(() => {
  trayController.ensure();
  createMainWindow();
  trayController.setDockIcon();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
    } else if (mainWindow) {
      mainWindow.show();
      mainWindow.focus();
      trayController.showDock();
    }
  });
});

app.on('before-quit', () => {
  quitRequested = true;
  trayController.destroy();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
