## Быстрый захват комбинаций
- пересмотрел логику: теперь `handleHotkeyCapture` прикрепляет `keydown` только после `nextTick`, чтобы очередной Enter/Space от кнопки не становился частью комбинации
- `onHotkeyKeydown` проверяет `Escape` (отмена) и только при наличии полноценной комбинации сохраняет её и меняет статус на `settings.hotkeyCapturedStatus`, иначе остальное не блокируется
- добавил `cancelHotkeyCapture` и `onBeforeUnmount`, чтобы слушатель не оставался включённым между страницами или после нажатия действий; добавлены переводы для `hotkeyCapturedStatus` и `hotkeyCaptureCanceled`
