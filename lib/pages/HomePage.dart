import 'dart:io';

import 'package:bq_screenshot/pages/Settings.dart';
import 'package:bq_screenshot/utils/ColorsUtil.dart';
import 'package:bq_screenshot/utils/SettingsStorage.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import '../models/homepage_model.dart';
export '../models/homepage_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  CapturedData? _lastCapturedData;
  Uint8List? _imageBytesFromClipboard;

  var _settingsStorage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _settingsStorage = Settingstorage();
    _settingsStorage.loadSettings();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
                     MaterialPageRoute(builder: (context) => const SettingsWidget())
                  );
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
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_lastCapturedData != null &&
                  _lastCapturedData?.imagePath != null)
                Container(
                  width: 100,
                  height: 0,
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.sizeOf(context).width,
                    minHeight: MediaQuery.sizeOf(context).height * 0.7,
                    maxWidth: MediaQuery.sizeOf(context).width,
                    maxHeight: MediaQuery.sizeOf(context).height * 1,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsUtil.secondaryBackground,
                  ),
                  alignment: AlignmentDirectional(0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_lastCapturedData!.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleClickCapture(CaptureMode mode) async {
    Directory? saveDirectoryPath = await getApplicationDocumentsDirectory();

    String imageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    String imagePath =
        '${saveDirectoryPath.path}/screen_capturer_example/Screenshots/$imageName';
    print(imagePath);

    _lastCapturedData = await screenCapturer.capture(
      mode: mode,
      imagePath: imagePath,
      copyToClipboard: true,
      silent: true,
    );

    if (_lastCapturedData != null) {
      print('Screenshot Complete');
    } else {
      // ignore: avoid_print
      print('User canceled capture');
    }
    setState(() {});
  }
}
