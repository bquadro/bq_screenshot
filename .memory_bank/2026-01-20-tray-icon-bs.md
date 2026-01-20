Создал видимую иконку для трея:

- Сгенерировал `app/src/assets/tray-icon-bs.png` (32×32, красный фон, чёрные буквы BS) без сторонних зависимостей.
- TrayController теперь загружает иконку из этого файла (`app/src/classes/TrayController.js`) и лишь при отсутствии — использует встроенную data URL.
- `npm run lint` (скрипт всё ещё «No linting configured»).
