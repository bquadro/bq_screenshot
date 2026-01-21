## Передача параметров в t()
- функция `t` в `App.vue` теперь пробрасывает параметр replacements в `LocalizationService.t`, поэтому вычисление `t('capture.uploadProgress', { percent })` вставляет настоящий процент в строку вместо `{percent}` (`app/src/App.vue:120-132`, `app/src/classes/LocalizationService.js:7-24`).
