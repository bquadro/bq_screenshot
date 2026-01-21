## Исчез MakerDMG
- удалил `@electron-forge/maker-dmg` из `forge.config.js` и `app/package.json`, чтобы `npm run make` больше не пытался загрузить `macos-alias` и падал на Node 25, при этом `electron-installer-dmg` используется через `scripts/create_dmg.js` (`README.md:88-140`).
