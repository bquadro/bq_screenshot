import 'dart:io';

// import 'flutter_flow_model.dart' as model;
import '/models/flutter_flow_model.dart' as model;
import 'package:flutter/services.dart';

// import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '/pages/Settings.dart';
import '/utils/ColorsUtil.dart';
import '/utils/SettingsStorage.dart';
import '/utils/EditorEvents.dart';

import 'package:flutter/material.dart' hide MenuItem;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../models/homepage_model.dart';
import 'flutter_flow_button.dart';
export '../models/homepage_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with EditorEventsState<HomePageWidget>, TrayListener, WindowListener {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  CapturedData? _lastCapturedData;

  var _settingsStorage;

  @override
  void initState() {
    super.initState();
    _model = model.createModel(context, () => HomePageModel());

    _settingsStorage = Settingstorage();

    _settingsStorage.loadSettings();

    registerHotKeys();

    trayManager.addListener(this);

    windowManager.addListener(this);


    initTray();
    _init();
  }

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void dispose() async {
    await hotKeyManager.unregisterAll();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    _model.dispose();
    super.dispose();
  }

  void initTray() async {
    await trayManager.setIcon(
      Platform.isWindows ? 'images/tray_icon.ico' : 'images/tray_icon.png',
    );

    Menu menu = Menu(items: [
      MenuItem(
        key: 'window_hide',
        label: 'Скрыть',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'capture_area',
        label: 'Область',
      ),
      MenuItem(
        key: 'capture_window',
        label: 'Окно',
      ),
      MenuItem(
        key: 'capture_screen',
        label: 'Экран',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: 'Выйти',
      ),
    ]);
    await trayManager.setContextMenu(menu);
  }

  void registerHotKeys() async {
    HotKey _hotKeyArea = HotKey(
      key: PhysicalKeyboardKey.digit4,
      modifiers: [HotKeyModifier.alt],
      // Set hotkey scope (default is HotKeyScope.system)
      scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
    );

    HotKey _hotKeyWindow = HotKey(
      key: PhysicalKeyboardKey.digit5,
      modifiers: [HotKeyModifier.alt],
      // Set hotkey scope (default is HotKeyScope.system)
      scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
    );

    HotKey _hotKeyScreen = HotKey(
      key: PhysicalKeyboardKey.digit6,
      modifiers: [HotKeyModifier.alt],
      // Set hotkey scope (default is HotKeyScope.system)
      scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
    );

    await hotKeyManager.register(_hotKeyArea, keyDownHandler: (hotKey) {
      _handleClickCapture(CaptureMode.region);
    });
    await hotKeyManager.register(_hotKeyWindow, keyDownHandler: (hotKey) {
      _handleClickCapture(CaptureMode.window);
    });
    await hotKeyManager.register(_hotKeyScreen, keyDownHandler: (hotKey) {
      _handleClickCapture(CaptureMode.screen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: ColorsUtil.secondaryBackground,
        appBar: AppBar(
          backgroundColor: ColorsUtil.primary,
          automaticallyImplyLeading: false,
          title: Text(
            'BqScreenshot',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
              child: FFButtonWidget(
                onPressed: () {
                  _handleClickCapture(CaptureMode.region);
                },
                text: 'Область',
                icon: Icon(
                  Icons.crop,
                  size: 15,
                ),
                options: FFButtonOptions(
                  height: 40,
                  padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: ColorsUtil.success,
                  textStyle: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                  elevation: 3,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
              child: FFButtonWidget(
                onPressed: () {
                  _handleClickCapture(CaptureMode.window);
                },
                text: 'Окно',
                icon: Icon(
                  Icons.window,
                  size: 15,
                ),
                options: FFButtonOptions(
                  height: 40,
                  padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: ColorsUtil.success,
                  textStyle: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                  elevation: 3,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
              child: FFButtonWidget(
                onPressed: () {
                  _handleClickCapture(CaptureMode.screen);
                },
                text: 'Экран',
                icon: Icon(
                  Icons.desktop_windows_sharp,
                  size: 15,
                ),
                options: FFButtonOptions(
                  height: 40,
                  padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: ColorsUtil.success,
                  textStyle: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                  elevation: 3,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(30, 5, 5, 5),
              child: FFButtonWidget(
                onPressed: () async {
                  // OpenSettings
                  print('Open Settings');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsWidget()));
                },
                text: 'Настройки',
                icon: Icon(
                  Icons.settings_outlined,
                  size: 15,
                ),
                options: FFButtonOptions(
                  height: 40,
                  padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: ColorsUtil.error,
                  textStyle: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                  elevation: 3,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2,
        ),
      ),
    );
  }

  /// Событие создания скриншота
  Future<void> _handleClickCapture(CaptureMode mode) async {
    Settingstorage settings = await Settingstorage().loadSettings();

    Settingstorage.ImageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';

    String imagePath =
        '${settings.Settings.saveDirectoryPath}/${Settingstorage.ImageName}';
        // '${settings.Settings.saveDirectoryPath}/Screenshot-1726466762983.png';
    //
    //  File? file1 = File(imagePath);
    //
    // // Создаем директорию, если она не существует
    // await file1.create(recursive: true);
    //
    // file1 = null;

    _lastCapturedData = await screenCapturer.capture(
      mode: mode,
      imagePath: imagePath,
      copyToClipboard: true,
      silent: false,
    );

    if (_lastCapturedData != null) {
      File file = File(_lastCapturedData!.imagePath!);
      await precacheImage(FileImage(file), context);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => _buildFileEditor(file)),
      );
    } else {
      // ignore: avoid_print
      print('User canceled capture');
    }
    setState(() {});
  }

  /// Редктор
  Widget _buildFileEditor(File file) {
    setRawImagePath(_lastCapturedData?.imagePath);
    return ProImageEditor.file(
      file,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          customWidgets: ImageEditorCustomWidgets(
            mainEditor: CustomWidgetsMainEditor(
              appBar: (editor, rebuildStream) => editor.selectedLayerIndex < 0
                  ? ReactiveCustomAppbar(
                      stream: rebuildStream,
                      builder: (_) =>
                          _buildAppBar(editor, _lastCapturedData?.imagePath))
                  : null,
            ),
          )),
    );
  }

  /// Кастомный appBar для редактора
  AppBar _buildAppBar(ProImageEditorState editor, String? imagePath) {
    return AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          tooltip: 'Поделиться',
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.share,
            color: Colors.amber,
          ),
          onPressed: () async {
            if (imagePath != null) {
              File file = File(imagePath);
              Uint8List? bytes = await editor.captureEditorImage();
              file.writeAsBytesSync(bytes);
              await uploadToS3(Settingstorage.ImageName, imagePath);
            }
          },
        ),
        IconButton(
          tooltip: 'Копировать',
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.copy,
            color: Colors.amber,
          ),
          onPressed: () async {
            if (imagePath != null) {
              File file = File(imagePath);
              Uint8List? bytes = await editor.captureEditorImage();
              file.writeAsBytesSync(bytes);
              await Pasteboard.writeFiles([imagePath]);
            }
          },
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Undo',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.undo,
            color: editor.canUndo == true
                ? Colors.white
                : Colors.white.withAlpha(80),
          ),
          onPressed: editor.undoAction,
        ),
        IconButton(
          tooltip: 'Redo',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.redo,
            color: editor.canRedo == true
                ? Colors.white
                : Colors.white.withAlpha(80),
          ),
          onPressed: editor.redoAction,
        ),
        IconButton(
          tooltip: 'Done',
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.done),
          iconSize: 28,
          onPressed: () async {
            if (imagePath != null) {
              File file = File(imagePath);
              Uint8List? bytes = await editor.captureEditorImage();
              file.writeAsBytesSync(bytes);
              await uploadToS3(Settingstorage.ImageName, imagePath);
            }
            editor.doneEditing();
          },
        ),
      ],
    );
  }

  // События трея
  @override
  void onTrayIconMouseDown() {
    // do something, for example pop up the menu
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'window_show':
        windowManager.show();
        break;
      case 'window_hide':
        windowManager.hide();
        break;
      case 'capture_area':
        _handleClickCapture(CaptureMode.region);
        break;
      case 'capture_window':
        _handleClickCapture(CaptureMode.window);
        break;
      case 'capture_screen':
        _handleClickCapture(CaptureMode.screen);
        break;
      case 'exit_app':
        windowManager.destroy();
        break;
    }
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      windowManager.hide();
    }
  }
}
