# Редактор на отдельной странице 2026-01-16
- Перевёл работу редактора скриншотов на отдельную вьюху `ImageEditorPage.vue`, где `tui-image-editor` инициализируется без кнопок Load/Download и загружает базовый скриншот из `captureService.capture`.
- `App.vue` теперь переключается между страницами (`home`, `settings`, `editor`), открывает редактор после съёмки и возвращает пользователя на главную при сохранении/отмене; передача Base64 идёт через `editorImage`, а сохранение происходит по `captureService.save`.
- Обновлены переводы (`editor.title/description`, статусы `capture.statusEditorOpen/Cancelled`), добавлена настройка `ImageEditorPage` без побочных кнопок, и `preload`/`CaptureService` теперь экспортируют `captureScreenshot`/`saveScreenshot` для цепочки.
