Обновил сборку, чтобы ассеты копировались в `.vite`:

- Установил `vite-plugin-static-copy` и настроил `app/vite.main.config.mjs`, чтобы папка `src/assets` копировалась в `assets` внутри сборки main-процесса (`.vite/assets`), откуда её легко подхватывает `TrayController`.
- Теперь `TrayController` на момент вызова `nativeImage.createFromPath` находит `tray-icon-bs.png` внутри `.vite/assets`, а fallback data URL остаётся на случай непопадания файла.
- `npm run lint` (как и ранее, просто выводит «No linting configured», npm предупреждает про несовместимость версии).
