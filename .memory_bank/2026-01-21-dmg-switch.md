## Переключение на electron-installer-dmg
- убрал `@electron-forge/maker-dmg`/`appdmg`, вернув `electron-installer-dmg` как единственный источник сборки `.dmg`, и добавил скрипт `scripts/create_dmg.js`, который упаковывает `.app` из `out/make` без `macos-alias` (`app/package.json`, `scripts/create_dmg.js`);
- изменил `scripts/build_publish_mac.sh` так, чтобы после `npm run make` он запускал `node scripts/create_dmg.js`, поэтому публикация больше не зависит от проблемной сборки native-модуля `volume.node`.
