# Шарп и Vite 2026-01-16
- Упростил `vite.main.config.mjs`, чтобы `sharp` не бандлился, пометив его как `external`, а не пытаться подключать `.node` через `@rollup/plugin-commonjs`, что вызывало ошибку загрузки при старте (#выполняется at runtime). Теперь Electron использует ноду `require('sharp')` напрямую.
