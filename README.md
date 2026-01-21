# bq_screenshot

Проект — кроссплатформенное (Windows, macOS, Linux) Electron-приложение на Vue 3 для создания скриншотов, захвата видео и загрузки материалов в S3.

## Ключевые особенности
- полноэкранные и региональные скриншоты;
- запись видео и минимизация в трей;
- настройка горячих клавиш и загрузка в S3 (Minio);
- менеджмент настроек через `SettingsStorage` с JSON в `app.getPath('userData')`;
- интерфейсный стек: Electron + Vite + Vue 3 + Bootstrap.

## Структура проекта

```
bq_screenshot/
├── AGENTS.md                  # локальные инструкции и требования
├── README.md                  # этот файл
├── .memory_bank/              # лог саммари с датами
└── app/
    ├── package.json           # npm-скрипты и зависимости для renderer/main
    ├── forge.config.js        # конфигурация electron-forge
    ├── src/
    │   ├── App.vue            # корневой Vue-компонент (+ страницы и состояния)
    │   ├── main.js            # главный процесс Electron (скриншоты, сохранение)
    │   ├── preload.js         # безопасное API между renderer и main
    │   ├── renderer.js        # точка входа Vite для renderer (Vue)
    │   ├── classes/           # сервисы: локализация, настройки, захват
    │   ├── components/        # Vue-компоненты UI (хедер, домашняя панель и т. д.)
    │   ├── config/            # UI-конфигурация и константы
    │   ├── lang/              # локализации (ru, en)
    │   ├── assets/            # шрифты, иконки и прочие ресурсы
    │   ├── index.css          # глобальные стили
    │   └── window/            # (по требованию) сюда помещаются снимки экранов
    ├── node_modules/          # зависимости (не коммитятся)
    └── vite.*.config.mjs      # конфигурации для renderer, preload, main
```

Все экраны/снимки логически должны сохраняться в `app/src/window` — если папка отсутствует, создавайте её вручную или программно перед сохранением.

## Предварительные требования
1. Установлен `nvm`.
2. Выполните `nvm use stable`, чтобы активировать Node.js 25 (соответствует требованию AGENTS.md).
3. На машине должны быть доступны инструменты сборки для Electron (например, `make` на Linux/macOS).

## Установка

```bash
cd app
npm install
```

## Команды сборки и разработки

```bash
npm run start    # запуск приложения в режиме разработки (electron-forge start)
npm run package  # упаковка приложения в дистрибутивы (без создания инсталляторов)
npm run make     # сборка нативных пакетов (deb/rpm/squirrel/zip по конфигу forge)
npm run publish  # публикация через electron-forge (настройки нужно задать вручную)
npm run lint     # заглушка, возвращает "No linting configured"
```

## Сборка macOS пакета (dmg) для публикации в App Store

1. Установите нужную версию Node.js (последняя LTS на момент разработки — Node 25) через `nvm`:
   ```bash
   nvm install stable
   nvm use stable
   ```
   Убедитесь, что в `node --version` и `npm --version` отображаются совместимые значения.
2. Перейдите в каталог `app` и установите зависимости:
   ```bash
   cd app
   npm install
   ```
3. Проверьте, что `forge.config.js` содержит `makеrs` для macOS (например, `@electron-forge/maker-zip`/`@electron-forge/maker-dmg`) и что у вас есть подписанная Developer ID Application и Installer (понадобятся сертификаты Apple).
4. Запустите сборку DMG для macOS (должен быть установлен `electron-osx-sign` через forge/plugins):
   ```bash
   npm run make
   ```
   В результате появится архив `out/make/dmg/src-<версия>.dmg`.
5. Перед публикацией в App Store:
   - Подпишите приложение (обычно Electron Forge делает подпись автоматически, если задана конфигурация `osxSign` в `forge.config.js` и экспортированы сертификаты `APPLE_ID` и `APPLE_ID_APPLICATION_PASSWORD`).
   - Проверьте, что `Info.plist` правильно настроен (bundle identifier, версии, `LSApplicationCategoryType` и т.д.).
   - Используйте `notarize` (плагин `@electron-forge/plugin-auto-unpack-natives` или `electron-notarize`) для загрузки приложения в Apple.
   - Убедитесь, что `.dmg` соответствует требованиям App Store (приложение в папке Applications, отсутствуют неавторизованные ресурсы, подпись действительна).
6. Опционально: для публикации в App Store используйте `xcrun altool --upload-app` или Transporter, указав `dmg`, созданный на шаге 4, и предоставив действительные Apple ID credentials.

## Скрипт автоматической сборки и публикации macOS

В корне репозитория есть `scripts/build_publish_mac.sh`, который выполняет набор команд для сборки и публикации:

```bash
./scripts/build_publish_mac.sh
```

Скрипт:

1. Проверку, что `node --version` совпадает с Node.js 25 (в противном случае скрипт завершится ошибкой).
2. Установку зависимостей (`npm install`).
3. Сборку `make` для генерации `.dmg`.
4. Вызов `npm run publish` (предварительно убедитесь, что экспортированы Apple credentials и настроены подписанные сертификаты).
5. `electron-forge make` теперь собирает только `.app/` без `.dmg`, поэтому запуск `node scripts/create_dmg.js` вручную (или через `scripts/build_publish_mac.sh`) превращает `.app` в `.dmg` с помощью `electron-installer-dmg`, обходя `macos-alias`.

Перед запуском скрипта необходимо:

- настроить `APPLE_ID`, `APPLE_ID_PASSWORD` и другие переменные (например, `CSC_LINK`, `CSC_KEY_PASSWORD`) для `electron-forge`.
- следить, чтобы `forge.config.js` был корректно сконфигурирован для macOS (подпись, notarize).
- убедиться, что локально установлена Node.js 25 (например, через `nvm use stable`), иначе скрипт выдаст ошибку.

## Скрипт сборки Windows-пакета

Для генерации Windows-инсталлятора (Squirrel/ZIP) используйте PowerShell-скрипт:

```powershell
./scripts/build_publish_windows.ps1
```

Он проверяет `node --version` (требуется 25.x), запускает `npm install` и `npm run make -- --platform=win32 --arch=x64`. После успешного выполнения установщик/ZIP окажутся в `app/out/make/win32-x64`.

Перед запуском убедитесь, что:

- установлены Windows Build Tools (Visual Studio Build Tools, Python 3) для `node-gyp`.
- заданы `CSC_LINK`, `CSC_KEY_PASSWORD` и `CSC_NAME`, если вы подписываете MSI/EXE.
- переменные `GITHUB_OWNER`/`GITHUB_REPO` настроены, если будете использовать GitHub publisher.

## Подготовка к публикации в App Store (сертификаты и идентификация)

Перед запуском `npm run publish` или скрипта `scripts/build_publish_mac.sh` нужно подготовить инфраструктуру Apple:

1. **Apple Developer Program:** зарегистрируйтесь или войдите в [Apple Developer](https://developer.apple.com). Для публикации в Mac App Store обязательно иметь активную платную подписку.
2. **Получение сертификатов:**
   - В разделе **Certificates, Identifiers & Profiles** создайте сертификаты:
     * `Developer ID Application` – для подписи `.app`.
     * `Developer ID Installer` – если вы подписываете `.pkg` (не обязательно для App Store).
     * Для App Store нужен `Mac App Distribution`. При создании сертификата экспортируйте `.cer` и `.p12`.
   - Установите эти сертификаты в **Keychain Access** на macOS (двойной клик по `.cer`, импортируйте `.p12`).
   - Создайте **App ID** (bundle identifier) и привяжите его к вашему приложению.
3. **Notarization:** Apple требует notarize для всех дистрибутивов:
   - Установите [`notarytool`](https://developer.apple.com/documentation/security/notarytool) или используйте `xcrun altool`.
   - При публикации через `electron-forge` настройте `forge.config.js`:
     ```js
     module.exports = {
       packagerConfig: {
         osxSign: { identity: 'Mac Developer: ...' },
         osxNotarize: { appleId: process.env.APPLE_ID, appleIdPassword: process.env.APPLE_ID_PASSWORD },
       },
     };
     ```
4. **Набор переменных окружения и GitHub-публикация** (эти же переменные захватываются в `forge.config.js`):
   - `APPLE_ID` – ваш Apple ID (почта) для notarize.
   - `APPLE_ID_PASSWORD` – пароль-ключ (Application-specific password) или `@keychain:name`.
   - `ASC_PROVIDER` – идентификатор команды (если требуется) для notarize.
   - `CSC_NAME` – имя сертификата (например, `Mac Developer: John Doe` или `Developer ID Application:...`).
   - `CSC_KEY_PASSWORD` – пароль от экспортированного `.p12`.
   - `GITHUB_OWNER`/`GITHUB_REPO` – репозиторий, в который Forge публикует релизы (`@electron-forge/publisher-github`).
5. **Publishers в `forge.config.js`:** теперь конфиг подставляет эти переменные и автоматически подключает GitHub-паблишер. Если их нет, добавьте вручную, чтобы `npm run publish` не выдавал `No publishers configured`.
   ```js
   publishers: [
     {
       name: '@electron-forge/publisher-github',
       config: {
         repository: {
           owner: 'your-github',
           name: 'your-repo',
         },
         prerelease: false,
         draft: true,
       },
     },
   ],
   ```
   Или альтернативный publisher для подписи/загрузки (например, `@electron-forge/publisher-zip`).
6. **Сборка и загрузка:** после настройки сертификатов выполните `npm run make` → `npm run publish`. Forge зафиксирует `.dmg`, подпишет, нотаризирует и отправит в App Store Connect.

При ошибках `No publishers configured` добавьте нужный publisher и проверьте `forge.config.js`. Если публикация должна идти в App Store, используйте `electron-notarize`/`notarytool` через `osxNotarize`.

## Важные модули
- [`node-screenshots`](https://github.com/nashaofu/node-screenshots) — нативная библиотека, которая предоставляет список мониторов/окон и возвращает PNG без сторонних зависимостей.
- [`hotkeys-js`](https://github.com/jaywcjlove/hotkeys-js) — глобальные горячие клавиши (интеграция через класс).
- [`tui-image-editor`](https://github.com/nhn/tui.image-editor) — встроенный редактор для правки снимков.

## Работа с настройками
Настройки сохраняются/загружаются через `classes/SettingsStorage.js`. Значения объединяются с дефолтами, включая:
- горячие клавиши (CmdOrCtrl+Shift+1..4);
- путь хранения в `~/Pictures/bq-screenshots` по умолчанию;
- параметры S3 (endpoint, bucket, ключи, SSL).

## Локализация и UI
- Словари хранятся в `src/lang/ru.js` и `src/lang/en.js`, переключение происходит через `LocalizationService`.
- UI-конфигурация (название, логотип и т.п.) — `src/config/ui.js`.

## Полезные советы
- Всегда проверяйте, что `window.electronAPI` доступно в renderer перед вызовами (см. `App.vue`).
- Для добавления новых экранов следуйте архитектуре классов и обновляйте `HomeActions`/соответствующие страницы.
- После каждого значимого изменения сохраняйте саммари с текущей датой в `.memory_bank`.
