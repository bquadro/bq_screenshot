Вынес классы `LocalizationService`, `SettingsService` и `CaptureService` в отдельные файлы под `src/classes/` и подключил их из `renderer.js` как ES-модули через `type="module"`.
Это делает архитектуру более модульной и облегчает тестирование/расширение каждой подсистемы.
