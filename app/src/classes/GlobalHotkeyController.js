import { app, globalShortcut } from 'electron';

export default class GlobalHotkeyController {
  // Конфигурируем контроллер: ссылка на окно, режим отладки и хранилище комбинаций.
  constructor(getWindow, { debug = false } = {}) {
    this.getWindow = getWindow;
    this.debug = debug;
    this.registered = new Map();
    this.readyPromise = null;
  }

  // Ожидаем готовности приложения перед работой с глобальными сочетаниями.
  async ensureReady() {
    if (!this.readyPromise) {
      this.readyPromise = app.whenReady();
    }
    await this.readyPromise;
  }

  // Регистрируем указанные сочетания и отправляем события в рендерер.
  async register(bindings = {}) {
    await this.ensureReady();
    this.unregisterAll();

    const combos = Object.entries(bindings)
      .map(([combo]) => combo?.trim())
      .filter(Boolean);

    if (this.debug) {
      console.log('Registering global hotkeys:', combos.join(', ') || 'none');
    }

    for (const [combo, action] of Object.entries(bindings)) {
      const accelerator = combo?.trim();
      if (!accelerator) {
        continue;
      }
      const handler = () => {
        const win = this.getWindow();
        if (!win?.webContents) {
          return;
        }
        console.log(`Global hotkey triggered: ${accelerator} -> ${action}`);
        win.webContents.send('tray-action', action);
      };
      const registered = globalShortcut.register(accelerator, handler);
      if (!registered) {
        console.warn(`Не удалось зарегистрировать глобальную комбинацию ${accelerator}`);
        continue;
      }
      this.registered.set(accelerator, handler);
    }
  }

  // Удаляем все глобальные сочетания в системе.
  unregisterAll() {
    if (!this.registered.size) {
      return;
    }
    globalShortcut.unregisterAll();
    this.registered.clear();
  }

  // Высвобождаем ресурсы, избавляясь от ранее зарегистрированных комбинаций.
  dispose() {
    this.unregisterAll();
  }

}
