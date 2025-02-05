import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:developer';

import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

final talker = TalkerFlutter.init();

void main() async {
  log('Start');

  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    talker.handle(details);
    talker.error('Caught a Flutter error: ${details.exception}');
  };

  WidgetsFlutterBinding.ensureInitialized();

  await hotKeyManager.unregisterAll();

  await windowManager.ensureInitialized();

  log('Window Options');
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

  log('Silent Instance');
  if (await FlutterSingleInstance.platform.isFirstInstance()) {
    log('Run App');
    runApp(MyApp());
  } else {
    talker.debug("App is already running");

    exit(0);
  }

  runZonedGuarded(
    () async {},
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
    log('Init State');
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
