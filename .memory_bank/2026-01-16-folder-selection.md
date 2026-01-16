# Выбор папки сохранения 2026-01-16
- Добавил в `SettingsForm` кнопку выбора папки, которая эмитит `select-save-folder` вместо ручного ввода (`app/src/components/SettingsForm.vue`).
- Реализовал IPC `choose-save-folder` в `main.js`, возвращающий директорию через `dialog.showOpenDialog`, и передал в `preload`/`SettingsService`, чтобы `App.vue` мог выставить `settingsForm.saveFolder` и показать сообщение.
- Поправил переводы `settings.chooseFolderButton`, `settings.folderSelect*` в `lang/ru.js` и `lang/en.js`, чтобы уведомить пользователя об успешном выборе или ошибке.
