import 'dart:convert';
import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/convert_patch.dart';

// import 'flutter_flow_model.dart' as model;
import 'package:talker_flutter/talker_flutter.dart';

import '../main.dart';
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

enum HotKeyName {
  region('Область'),
  window('Окно'),
  empty(''),
  screen('Экран');

  final String name;

  const HotKeyName(this.name);
}

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

  late HotKey _hotKeyArea, _hotKeyWindow, _hotKeyScreen, _hotKeyAreaNew;

  String _hotKeyAreaToolTip = 'alt + 8';
  String _hotKeyWindowToolTip = 'alt + 7';
  String _hotKeyScreenToolTip = 'alt + 6';

  HotKeyName hotKeyName = HotKeyName.empty;

  @override
  void initState() {
    super.initState();
    _model = model.createModel(context, () => HomePageModel());

    _settingsStorage = Settingstorage();

    _settingsStorage.loadSettings();

    // loadSettings();

    registerHotKeys();

    trayManager.addListener(this);

    windowManager.addListener(this);
    _init();

    initTray();

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
      MenuItem(
        key: 'window_show',
        label: 'Развернуть',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'capture_area',
        label: 'Область',
      ),
      if (Platform.isMacOS)
        MenuItem(
          key: 'capture_window',
          label: 'Окно',
        ),
      if (Platform.isMacOS)
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
    Settingstorage data = await _settingsStorage.loadSettings();

    getHotKeyFromSettingsOr(data);

    await hotKeyManager.register(_hotKeyScreen, keyDownHandler: (hotKey) {
      _handleClickCapture(CaptureMode.screen);
    });

    await hotKeyManager.register(_hotKeyArea, keyDownHandler: (hotKey) {
      _handleClickCapture(CaptureMode.region);
    });

    await hotKeyManager.register(_hotKeyWindow, keyDownHandler: (hotKey) {
      _handleClickCapture(CaptureMode.window);
    });
  }

  // void getHotKeyFromSettingsOr(Settingstorage data) {
  //   var ar = data.Settings.hotKeyArea;
  //
  //   if (ar == null || ar.isEmpty) {
  //     _hotKeyArea = HotKey(
  //       key: PhysicalKeyboardKey.digit8,
  //       identifier: '8',
  //       modifiers: [HotKeyModifier.alt],
  //       // Set hotkey scope (default is HotKeyScope.system)
  //       scope: HotKeyScope.system, // Set as inapp-wide hotkey.
  //     );
  //
  //   }else{
  //
  //     final json = jsonDecode(ar);
  //     _hotKeyArea = HotKey.fromJson(json);
  //   }
  //
  //   var ar2 = data.Settings.hotKeyWindow;
  //
  //   if (ar2 == null || ar2.isEmpty) {
  //     _hotKeyWindow = HotKey(
  //       key: PhysicalKeyboardKey.digit7,
  //       modifiers: [HotKeyModifier.alt],
  //       identifier: '7',
  //       scope: HotKeyScope.system,
  //     );
  //   }else{
  //     final json = jsonDecode(ar2);
  //     _hotKeyWindow = HotKey.fromJson(json);
  //   }
  //
  //
  //   var ar3 = data.Settings.hotKeyScreen;
  //
  //   if (ar3 == null || ar3.isEmpty) {
  //
  //     _hotKeyScreen = HotKey(
  //       key: PhysicalKeyboardKey.digit6,
  //       modifiers: [HotKeyModifier.alt],
  //       identifier: '6',
  //       scope: HotKeyScope.system,
  //     );
  //
  //   }else{
  //     final json = jsonDecode(ar3);
  //     _hotKeyScreen = HotKey.fromJson(json);
  //   }
  //
  //
  //
  //
  //
  //
  //
  //
  // }

  void getHotKeyFromSettingsOr(Settingstorage data) {



    _hotKeyArea = _getHotKey(data.Settings.hotKeyArea,
        PhysicalKeyboardKey.digit8, '8', [HotKeyModifier.alt]);

    _hotKeyWindow = _getHotKey(data.Settings.hotKeyWindow,
        PhysicalKeyboardKey.digit7, '7', [HotKeyModifier.alt]);

    _hotKeyScreen = _getHotKey(data.Settings.hotKeyScreen,
        PhysicalKeyboardKey.digit6, '6', [HotKeyModifier.alt]);


        _hotKeyScreenToolTip =
            makeStringTooltip(_hotKeyScreen);

        _hotKeyAreaToolTip =
            makeStringTooltip(_hotKeyArea);

        _hotKeyWindowToolTip =
            makeStringTooltip(_hotKeyWindow);

        setState(() {

        });

  }

  HotKey _getHotKey(String? hotKeyData, PhysicalKeyboardKey defaultKey,
      String identifier, List<HotKeyModifier> modifiers) {
    if (hotKeyData == null || hotKeyData.isEmpty) {
      return HotKey(
        key: defaultKey,
        identifier: identifier,
        modifiers: modifiers,
        scope: HotKeyScope.system,
      );
    } else {
      final json = jsonDecode(hotKeyData);
      return HotKey.fromJson(json);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: TalkerWrapper(
        talker: talker,
        options: TalkerWrapperOptions(
          enableErrorAlerts: true,
          enableExceptionAlerts: true
        ),
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
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Назначить hotkey',
                      child: InkWell(
                        child: Icon(Icons.settings),
                        onTap: () {
                          hotKeyName = HotKeyName.region;
                          setState(() {});
                        },
                      ),
                    ),
                    Tooltip(
                      message: _hotKeyAreaToolTip,
                      child: FFButtonWidget(
                        onPressed: () {
                          _handleClickCapture(CaptureMode.region);
                        },
                        text: HotKeyName.region.name,
                        icon: Icon(
                          Icons.crop,
                          size: 15,
                        ),
                        options: FFButtonOptions(
                          height: 40,
                          padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                  ],
                ),
              ),
              if (Platform.isMacOS)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Row(
                    children: [
                      Tooltip(
                        message: 'Назначить hotkey',
                        child: InkWell(
                          child: Icon(Icons.settings),
                          onTap: () {
                            hotKeyName = HotKeyName.window;
                            setState(() {});
                          },
                        ),
                      ),
                      Tooltip(
                        message: _hotKeyWindowToolTip,
                        child: FFButtonWidget(
                          onPressed: () {
                            _handleClickCapture(CaptureMode.window);
                          },
                          text: HotKeyName.window.name,
                          icon: Icon(
                            Icons.window,
                            size: 15,
                          ),
                          options: FFButtonOptions(
                            height: 40,
                            padding:
                                EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                            iconPadding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                    ],
                  ),
                ),
              if (Platform.isMacOS)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Row(
                    children: [
                      Tooltip(
                        message: 'Назначить hotkey',
                        child: InkWell(
                          child: Icon(Icons.settings),
                          onTap: () {
                            hotKeyName = HotKeyName.screen;
                            setState(() {});
                          },
                        ),
                      ),
                      Tooltip(
                        // message: _hotKeyScreen.modifiers?.fold<String>(
                        //     '', (previousValue, element) => previousValue + element.name),
                        message: _hotKeyScreenToolTip,
                        child: FFButtonWidget(
                          onPressed: () {
                            _handleClickCapture(CaptureMode.screen);
                          },
                          text: HotKeyName.screen.name,
                          icon: Icon(
                            Icons.desktop_windows_sharp,
                            size: 15,
                          ),
                          options: FFButtonOptions(
                            height: 40,
                            padding:
                                EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                            iconPadding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                    ],
                  ),
                ),
              if (!Platform.isMacOS)
                SizedBox(
                  width: 40,
                ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(30, 5, 5, 5),
                child: FFButtonWidget(
                  onPressed: () async {
                    // OpenSettings
                    talker.debug('Open Settings');
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
          body: (hotKeyName != HotKeyName.empty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                            'Нажмните сочетание клавиш для изменения hotkey "${hotKeyName.name}" и далее  на кнопку "Сохранить" '),
                      ),
                      SizedBox(
                        width: 80, // Установите ширину
                        height: 80,
                        child: FittedBox(
                          child: HotKeyRecorder(
                            onHotKeyRecorded: (hotKey) {
                              _hotKeyAreaNew = hotKey;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 40)),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.green)),
                          onPressed: () async {
                            await registerNewKey(hotKeyName, _hotKeyAreaNew);

                            switch (hotKeyName) {
                              case HotKeyName.screen:
                                _hotKeyScreenToolTip =
                                    makeStringTooltip(_hotKeyAreaNew);
                              case HotKeyName.region:
                                _hotKeyAreaToolTip =
                                    makeStringTooltip(_hotKeyAreaNew);
                              case HotKeyName.window:
                                _hotKeyWindowToolTip =
                                    makeStringTooltip(_hotKeyAreaNew);
                              case HotKeyName.empty:
                                break;
                            }

                            hotKeyName = HotKeyName.empty;
                            setState(() {});
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.save),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Сохранить',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          )),
                    ],
                  ),
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }

  String makeStringTooltip(HotKey _hotKeyAreaNew) {
    String _hotKeyScreenToolTip = _hotKeyAreaNew.modifiers?.fold<String>('',
            (previousValue, element) => previousValue + element.name + "+") ??
        '';
    _hotKeyScreenToolTip += _hotKeyAreaNew.key.keyLabel ?? '';

    return _hotKeyScreenToolTip;
  }

  Future<void> registerNewKey(
      HotKeyName hotKeyName, HotKey hotKeyAreaNew) async {
    HotKey hk = HotKey(
      key: hotKeyAreaNew.key,
      modifiers: hotKeyAreaNew.modifiers,
      scope: HotKeyScope.system,
    );

    // await hotKeyManager.register(
    //   hotKeyAreaNew,
    //   keyDownHandler: (hk){
    //     print('dfdff');
    //   },
    //   // keyUpHandler: _keyUpHandler,
    // );
    // return;

    switch (hotKeyName) {
      case HotKeyName.region:
        await hotKeyManager.unregister(_hotKeyArea);

        _hotKeyArea = hk;
        _settingsStorage.Settings.hotKeyArea = jsonEncode(_hotKeyArea.toJson());
        await _settingsStorage.saveSettings();

        await hotKeyManager.register(hotKeyAreaNew, keyDownHandler: (hotKey) {
          _handleClickCapture(CaptureMode.region);
          // print('dfdfdfdfdf');


        });

        // _settingsStorage.Settings.s3_endPoint = '';

      case HotKeyName.window:
        await hotKeyManager.unregister(_hotKeyWindow);

        _hotKeyWindow = hk;

        _settingsStorage.Settings.hotKeyWindow =
            jsonEncode(_hotKeyWindow.toJson());

        await _settingsStorage.saveSettings();

        await hotKeyManager.register(hk, keyDownHandler: (hotKey) {
          _handleClickCapture(CaptureMode.window);
        });
      case HotKeyName.screen:
        await hotKeyManager.unregister(_hotKeyScreen);

        _hotKeyScreen = hk;

        _settingsStorage.Settings.hotKeyScreen =
            jsonEncode(_hotKeyScreen.toJson());
        await _settingsStorage.saveSettings();

        await hotKeyManager.register(hk, keyDownHandler: (hotKey) {
          _handleClickCapture(CaptureMode.screen);
        });

      case HotKeyName.empty:
        break;
    }
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
      talker.debug('User canceled capture');
    }


    setState(() {});
  }

  /// Редктор
  Widget _buildFileEditor(File file) {
    setRawImagePath(_lastCapturedData?.imagePath);

    windowManager.show();
    windowManager.focus();

    return ProImageEditor.file(

      file,
      callbacks: ProImageEditorCallbacks(

        onThumbnailGenerated: (v,m){


          return Future.value();
        },
        onImageEditingStarted: (){
          onImageEditingStarted();



        },
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

              try {
                await uploadToS3(Settingstorage.ImageName, imagePath);
              } catch (e) {

                talker.handle(e);
              Future.delayed(Duration.zero,(){
                throw TalkerException(Exception(e));

              });




              }
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
        windowManager.minimize();
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
