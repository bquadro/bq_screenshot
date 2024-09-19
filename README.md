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