## Скрипт сборки Windows
- добавлен PowerShell-скрипт `scripts/build_publish_windows.ps1`, который проверяет Node.js 25, запускает `npm install` и `npm run make` с таргетом `win32/x64`, чтобы собрать Windows дистрибутив (`scripts/build_publish_windows.ps1:1-14`);
- обновлён `README.md` разделом, объясняющим как запускать скрипт, какие переменные окружения нужны для подписи и куда смотреть результат (`README.md:88-140`);
