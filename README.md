# bq_screenshot

Программа для создания скриншотов с загрузкой в s3 хранилище на базе Minio

## Горячие клавиши
Alt+4 - область
Alt+5 - Окно
Alt+6 - Экран

# Сборка приложения

## MacOs
```
flutter doctor -v 
flutter create --platforms=macos . 
flutter run --release 
```  

Список  зависимых файлов swift для  работы
```
Путь до файлов /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.0/macosx
libswiftAppKit.dylib
libswiftCore.dylib
libswiftCoreAudio.dylib
libswiftCoreData.dylib
libswiftCoreFoundation.dylib
libswiftCoreGraphics.dylib
libswiftCoreImage.dylib
libswiftCoreMedia.dylib
libswiftDarwin.dylib
libswiftDispatch.dylib
libswiftFoundation.dylib
libswiftIOKit.dylib
libswiftMetal.dylib
libswiftObjectiveC.dylib
libswiftQuartzCore.dylib
libswiftXPC.dylib
libswiftos.dylib
```


## Windows

```
flutter create --platforms=windows .  
flutter doctor -v 
flutter run --release
```

## статья по созданию инсталлера

https://dev.to/hahouari/creating-easy-windows-installer-for-flutter-apps-using-inno-bundle-5df3

## Сборка dmg пакета для MacOs

в терминале в папке relese
`hdiutil create -srcfolder bq_screenshot.app bq_screenshot.dmg`

## Если сборка не запускается  на других  MacOs  устройствах.
1. Проверить  что  в  XCode  в  секции Runpath Search Paths добавлена папка  /usr/lib/swift и @loader_path/Frameworks
2. Проверить что сборка подписывается сертификатом компании
3. После сборки в пакете программы  в папке Framevirks должнны  появиться файлы libswift*