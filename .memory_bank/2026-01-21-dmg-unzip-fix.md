# Автозапуск DMG 2026-01-21

- `app/create_dmg.js` теперь фильтрует собраные `.app`, экстрагирует ZIP из `out/make/zip/...`, нормализует пути и вызывает `electron-installer-dmg` через `await installer(...)`, чтобы хендл был асинхронным без callback-ошибок.
- При запуске `node app/create_dmg.js` подтянули ZIP и успешно вычислили путь к `BqScreenshot.app`, но `electron-installer-dmg` снова падал в `hdiutil` с `create failed - Устройство не сконфигурировано` (проблема на текущей среде), поэтому сборка `.dmg` требует окружения с доступным `hdiutil`.
- Запуск `scripts/build_publish_mac.sh` после этих изменений должен работать точно так же, но ожидается, что тестирование/подпись будет проходить на машине macOS с доступным `hdiutil` и Node.js 25.
