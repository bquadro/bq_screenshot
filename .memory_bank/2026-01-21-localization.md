## Локализация прогресса
- расширил `LocalizationService.t` так, чтобы он принимал объект замен и заменял `{placeholders}` в строках (`app/src/classes/LocalizationService.js:1-24`), благодаря чему `%` из `capture.uploadProgress` теперь подставляется корректно;
- повторная генерация сообщений не нужна, так что `App.vue` продолжает использовать `t('capture.uploadProgress', { percent })`, а ссылки отображают настоящие значения процентов.
