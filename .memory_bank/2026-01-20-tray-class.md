Перенес работу с треем в отдельный класс:

- Создал `app/src/classes/TrayController.js`, который управляет `Tray`, контекстным меню (включая действия «Скриншот», «Область», «Запись», «Настройки», «Закрыть») и посылает команды в renderer через `tray-action`.
- Обновил `app/src/main.js`: инициируется `TrayController`, подписки на `minimize/close` скрывают окно и показывают трей, `before-quit` уничтожает его, `app.on('activate')` восстанавливает окно.
- Renderer (`preload.js` и `App.vue`) снова слушает `tray-action`, чтобы запускать нужные сценарии; `npm run lint` по-прежнему выводит «No linting configured».
