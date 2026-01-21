## Подготовка публикации
- описал шаги получения Apple сертификатов (Developer ID Application/Installer, Mac App Distribution), установки в Keychain и создания App ID, которые нужны перед `npm run publish` (`README.md:110-146`);
- указал обязательные переменные окружения (`APPLE_ID`, `APPLE_ID_PASSWORD`, `CSC_LINK`, `CSC_KEY_PASSWORD`, `ASC_PROVIDER`) и необходимость настройки `forge.config.js` с `osxSign/osxNotarize` и `publishers` (`README.md:110-146`).
