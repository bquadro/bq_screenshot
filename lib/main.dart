import 'dart:async';
import 'dart:io';
import 'dart:ui';
// import 'dart:io';

//import 'package:bq_screenshot/menu.dart';
//import 'package:bq_screenshot/tray.dart';

// import 'package:tray_manager/tray_manager.dart';

import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '/utils/functions.dart';

import '/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

//import 'app_window.dart';
//import 'constants.dart';
//import 'menu_item.dart';

// import 'package:system_tray/system_tray.dart';

// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:english_words/english_words.dart';
// import 'package:system_tray/system_tray.dart';

// import 'package:system_tray/system_tray.dart' ;

final talker = TalkerFlutter.init();

void main() async {
  // checkDateReturn();
  //q

  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  // runZonedGuarded(
  //   () async {


      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        talker.handle(details);
        talker.error('Caught a Flutter error: ${details.exception}');
      };

      // runZonedGuarded(() async {

      WidgetsFlutterBinding.ensureInitialized();

      await hotKeyManager.unregisterAll();

      await windowManager.ensureInitialized();









      WindowOptions windowOptions = const WindowOptions(
        size: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        windowButtonVisibility: true,
      );


      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        // windowManager.
      });


      if (await FlutterSingleInstance.platform.isFirstInstance()) {
        runApp(MyApp());
      } else {
        talker.debug("App is already running");

        exit(0);
      }

      runZonedGuarded(() async {},
    // },
    (error, stackTrace) {
      talker.handle(error, stackTrace);
      talker.debug(stackTrace);
      talker.error('Caught an error in zone: $error');
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        // Здесь мы можем изменить поведение функции print
        // parent.print(zone, 'Перехвачено: $line'); // Изменяем вывод
        talker.debug(line);
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final AppWindow _appWindow = AppWindow();
  // final SystemTray _systemTray = SystemTray();
  // final Menu _menuMain = Menu();
  // final Menu _menuSimple = Menu();

  // Timer? _timer;
  bool _toogleTrayIcon = true;

  bool _toogleMenu = true;

  @override
  void initState() {
    super.initState();
    // initSystemTray();
  }

  @override
  void dispose() {
    super.dispose();
    // _timer?.cancel();
  }



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BqScreenshot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePageWidget(),
    );
  }
}


