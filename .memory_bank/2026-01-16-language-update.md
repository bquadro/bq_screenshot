# Язык настроек 2026-01-16
- В `App.vue` заменил inline-обработчик `@update:language`, который пытался обратиться к `language.value` из шаблона (в шаблонах Vue 3 `ref` развертывается и это было строкой), на метод `handleLanguageUpdate`, где `language` остаётся `ref` и можно безопасно обновлять `language.value`.
- Это устраняет ошибку `Cannot create property 'value' on string 'ru'`, сохраняя существующие `watch` и локализацию, и теперь переключение языка работает до сохранения настроек.
