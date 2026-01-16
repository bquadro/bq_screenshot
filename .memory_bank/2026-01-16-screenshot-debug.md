Обработал ошибку `desktopCapturer` в preload: теперь модуль подгружается в момент вызова, проверяется доступность `desktopCapturer.getSources`, и при отсутствии выбрасывается понятная ошибка.
Это исправляет `Cannot read properties of undefined (reading 'getSources')` и позволяет корректно захватывать скриншоты без ранних обращений к модулю.
