import { Menu, Tray, nativeImage } from 'electron';
import path from 'node:path';
import { existsSync } from 'node:fs';

const PLATFORM_DIRECTION = {
  darwin: 'tray-mac.png',
  win32: 'tray-windows.png',
  linux: 'tray-linux.png',
};

const FALLBACK_BASE_PATHS = [
  path.join(__dirname, '..', '..', '.vite', 'build', 'assets'),
  path.join(__dirname, '..', '..', '.vite', 'assets'),
  path.join(__dirname, '..', 'assets'),
];

const TRAY_ICON_DATA_URL =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAACTSURBVHgBpZKBCYAgEEV/TeAIjuIIbdQIuUGt0CS1gW1iZ2jIVaTnhw+Cvs8/OYDJA4Y8kR3ZR2/kmazxJbpUEfQ/Dm/UG7wVwHkjlQdMFfDdJMFaACebnjJGyDWgcnZu1/lrCrl6NCoEHJBrDwEr5NrT6ko/UV8xdLAC2N49mlc5CylpYh8wCwqrvbBGLoKGvz8Bfq0QPWEUo/EAAAAASUVORK5CYII=';
export default class TrayController {
  constructor(appInstance, getWindow) {
    this.app = appInstance;
    this.getWindow = getWindow;
    this.tray = null;
    const iconPath = this.resolveAssetPath(PLATFORM_DIRECTION[process.platform] || PLATFORM_DIRECTION.linux);
    this.icon = iconPath ? nativeImage.createFromPath(iconPath) : nativeImage.createFromDataURL(TRAY_ICON_DATA_URL);
    if (this.icon.isEmpty()) {
      this.icon = nativeImage.createFromDataURL(TRAY_ICON_DATA_URL);
    }
    if (process.platform === 'darwin') {
      this.icon.setTemplateImage(true);
    }
  }

  ensure() {
    if (this.tray) {
      return;
    }

    this.tray = new Tray(this.icon);
    this.tray.setToolTip('bq screenshot');
    this.tray.setContextMenu(this.buildMenu());
    this.tray.on('double-click', () => this.showWindow());
  }

  buildMenu() {
    return Menu.buildFromTemplate([
      {
        label: 'Скриншот экрана',
        click: () => {
          this.showWindow();
          this.sendAction('fullscreen');
        },
      },
      {
        label: 'Скриншот области',
        click: () => {
          this.showWindow();
          this.sendAction('area');
        },
      },
      {
        label: 'Запись видео',
        click: () => {
          this.showWindow();
          this.sendAction('record');
        },
      },
      { type: 'separator' },
      {
        label: 'Настройки',
        click: () => {
          this.showWindow();
          this.sendAction('settings');
        },
      },
      { type: 'separator' },
      {
        label: 'Закрыть приложение',
        click: () => {
          this.app.quit();
        },
      },
    ]);
  }

  showWindow() {
    const win = this.getWindow();
    if (!win) {
      return;
    }
    this.showDock();
    if (win.isMinimized()) {
      win.restore();
    }
    win.show();
    win.focus();
  }

  showDock() {
    if (process.platform === 'darwin' && this.app?.dock) {
      this.app.dock.show();
    }
  }

  hideDock() {
    if (process.platform === 'darwin' && this.app?.dock) {
      this.app.dock.hide();
    }
  }

  sendAction(action) {
    const win = this.getWindow();
    if (!win?.webContents) {
      return;
    }
    win.webContents.send('tray-action', action);
  }

  destroy() {
    if (!this.tray) {
      return;
    }
    this.tray.destroy();
    this.tray = null;
  }

  resolveAssetPath(filename) {
    if (!filename) {
      return null;
    }
    for (const base of FALLBACK_BASE_PATHS) {
      const candidate = path.join(base, filename);
      if (existsSync(candidate)) {
        return candidate;
      }
    }
    return null;
  }

  setDockIcon() {
    if (process.platform !== 'darwin' || !this.app?.dock) {
      return;
    }
    const iconPath = this.resolveAssetPath('app-icon.png');
    if (iconPath) {
      this.app.dock.setIcon(nativeImage.createFromPath(iconPath));
    }
  }
}
