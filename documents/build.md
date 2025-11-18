# Инструкции по сборке проекта `opencode`

## Общие требования
- Установленный Flutter SDK (минимум 3.4.3)
- Установленные платформенные SDK (Xcode, Android SDK, CMake и т.д.)

## Общие шаги
1. Обновите зависимости:
```bash
flutter pub get
```
2. Очистите проект:
```bash
flutter clean
```

## Сборка под macOS
1. Проверьте конфигурацию:
```bash
flutter doctor
```
2. Соберите релизную версию:
```bash
flutter build macos --release
```
3. Запустите приложение:
```bash
open build/macos/Build/Products/Release/<имя_приложения>.app
```

## Сборка под Windows
1. Проверьте конфигурацию:
```powershell
flutter doctor
```
2. Соберите релизную версию:
```powershell
flutter build windows --release
```
3. Запустите `.exe` из `build\windows\runner\release`

## Сборка под Linux
1. Проверьте конфигурацию:
```bash
flutter doctor
```
2. Соберите релиз:
```bash
flutter build linux --release
```
3. Запустите сгенерированный `.AppImage` или бинарник.

## Сборка под iOS
1. Проверьте конфигурацию:
```bash
flutter doctor
```
2. Соберите:
```bash
flutter build ios --release
```
3. Откройте проект в Xcode и запустите или создайте `.ipa` файл.

## Веб-сборка
1. Проверьте конфигурацию:
```bash
flutter doctor
```
2. Соберите:
```bash
flutter build web
```
3. Разверните содержимое папки `build/web` на сервере.

## Дополнительные рекомендации
- Перед сборкой убедитесь, что все платформенные SDK установлены.
- Используйте `flutter analyze` и `flutter test` для проверки кода.
- Для автоматизации используйте CI/CD системы.

Если нужно, я могу помочь с автоматизацией или подготовкой скриптов. 