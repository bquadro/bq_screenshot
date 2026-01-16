## Перевод съёмки на screenshot-desktop
- прочитал README и примеры `app/node_modules/screenshot-desktop/README.md` и `examples`, чтобы понимать API
- добавил в `app/src/main.js` импорт `screenshot-desktop` и обработчик `capture-screenshot`, возвращающий PNG-буфер
- переписал `app/src/preload.js`, чтобы вызывать новый IPC, преобразовывать буфер в base64 и по-прежнему запрашивать сохранение и превью
