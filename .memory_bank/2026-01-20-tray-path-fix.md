Поправил выбор файла иконки:

- `TrayController.resolveIconPath` теперь проверяет несколько расположений (`.vite/build/assets` и `.vite/assets`) и берёт первый существующий файл, чтобы runtime не жёстко привязывался к одному пути.
- Старый `console.log` удалён; fallback на data URL остался на случай, если копии ассетов нет.
