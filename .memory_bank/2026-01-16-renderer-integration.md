## Перенос renderer
- переписал `app/src/App.vue` под Vue 3 Composition API, импортировал `LocalizationService`, `SettingsService`, `CaptureService` и словари из `app/src/lang`, восстановил весь UI/логику из `src_old/renderer.js` (статусы, формы, методы загрузки/сохранения настроек, захвата скрина)
- перенёс визуальную структуру (карточки, секции, формы, кнопки) и стили из старого `index.html` в scoped CSS в `App.vue`, добавив глобальные стили для `body`/`main` в `app/src/index.css`
- оставил API для `electronAPI` без изменений и сохранил поддержку меток интерфейса, чтобы кнопки, статусы и поля текста были локализуемыми
