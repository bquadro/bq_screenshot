## Фикс потока при загрузке
- Подставил `ContentLength` в `PutObjectCommand` и отправляю поток прямо в `Body`, т.е. сначала создаю stream и вычисляю размер, чтобы AWS SDK перестал ругаться на `Unable to calculate hash for flowing readable stream` (`app/src/classes/UploadController.js:18-45`).
- Прогресс остаётся актуальным за счёт `stream.on('data')`, `stream.on('error')`, и в случае ошибки всё ещё отправляется пуш с описанием (`app/src/classes/UploadController.js:32-53`), поэтому UI получает корректный статус и утечек нет.
