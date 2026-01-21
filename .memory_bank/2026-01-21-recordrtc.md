## RecordRTC для видео
- переписал `VideoRecorder` на `RecordRTCPromisesHandler` из `recordrtc`, чтобы убрать прямую работу с `MediaRecorder` и обеспечить гибкий выбор кодека (`app/src/modules/videoRecorder.js:1-110`);
- добавил в `preload.js:13-53` API `electronAPI.getPrimaryScreenSourceId`, который возвращает id первого экрана и используется при fallbackе через `getUserMedia`;
- теперь при стартовом запуске выбирается подходящий MIME (`video/webm;codecs=vp9/8`) через `selectSupportedMimeType`, а `cleanup()` гарантирует остановку дорожек и уничтожение рекордера;
- в случае падения `RecordRTC` бросает читабельные ошибки (`recordrtc-handler-unavailable`, `desktop-capture-unavailable`), чтобы UI смог показать полезное сообщение.
