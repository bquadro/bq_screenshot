Добавил глобальные горячие клавиши:

- `mg/src/classes/GlobalHotkeyController.js` регистрирует комбинации через `globalShortcut` и отправляет `tray-action` в renderer, даже когда приложение свернуто.
- В `main.js` создаётся контроллер, добавлен IPC `register-global-hotkeys`, и при выходе происходит `dispose`.
- `App.vue` после каждого вызова `registerHotkeys` шлёт актуальные биндинги в main через `window.electronAPI.registerGlobalHotkeys`, так что и локальные, и глобальные регистры синхронизированы.
