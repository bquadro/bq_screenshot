## Интерфейс на Bootstrap
- подключил `bootstrap/dist/css/bootstrap.min.css` в `app/src/renderer.js` и оставил `index.css` для фоновых стилей, чтобы иметь доступ к утилитам Bootstrap
- переписал `App.vue`, превратив карточки и формы в компоненты Bootstrap (card, row, form-control, form-check и т.п.), убрав scoped CSS и перенравив UI в более структурированную сетку
- обновил глобальный `index.css` до минимального набора, чтобы Bootstrap управлял компоновкой, а фон оставался нейтральным
