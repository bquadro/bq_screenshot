import { app, BrowserWindow, dialog, ipcMain } from 'electron';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { writeFile, mkdir } from 'node:fs/promises';
import screenshot from 'screenshot-desktop';
import SettingsStorage from './classes/SettingsStorage.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

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

const getFallbackFolder = () => path.join(app.getPath('pictures'), 'bq-screenshots');

ipcMain.handle('load-settings', () => settingsStorage.load());
ipcMain.handle('save-settings', (_event, payload) => settingsStorage.save(payload));

ipcMain.handle('capture-screenshot', async () => {
  const buffer = await screenshot({ format: 'png' });
  if (!buffer) {
    throw new Error('Не удалось создать скриншот');
  }
  return buffer;
});

ipcMain.handle('choose-save-folder', async () => {
  const settings = await settingsStorage.load();
  const defaultFolder = settings.storage?.folder?.trim() || getFallbackFolder();
  const { canceled, filePaths } = await dialog.showOpenDialog({
    title: 'Выберите папку сохранения скриншотов',
    defaultPath: path.resolve(defaultFolder),
    properties: ['openDirectory', 'createDirectory'],
  });
  if (canceled || !filePaths?.length) {
    return null;
  }
  return filePaths[0];
});

ipcMain.handle('save-screenshot', async (_event, { data }) => {
  if (!data) {
    throw new Error('Отсутствуют данные скриншота');
  }

  const screenshotBuffer = Buffer.from(data, 'base64');
  const settings = await settingsStorage.load();
  const configuredFolder = settings.storage?.folder?.trim() || getFallbackFolder();
  const targetFolder = path.resolve(configuredFolder);
  const fileName = `bq-screenshot-${Date.now()}.png`;
  const filePath = path.join(targetFolder, fileName);

  await mkdir(targetFolder, { recursive: true });
  await writeFile(filePath, screenshotBuffer);

  return { canceled: false, filePath };
});

app.whenReady().then(() => {
  createMainWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
