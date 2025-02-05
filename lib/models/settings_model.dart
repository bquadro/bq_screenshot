// import 'package:flutterflow_ui/flutterflow_ui.dart';
import '../pages/Settings.dart' show SettingsWidget;
import 'package:flutter/material.dart';

import 'flutter_flow_model.dart';

class SettingsModel extends FlutterFlowModel<SettingsWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? s3EndpointFocusNode;
  TextEditingController? s3Endpoint;
  String? Function(BuildContext, String?)? s3EndpointValidator;
  // State field(s) for TextField widget.
  FocusNode? s3AccessKeyFocusNode;
  TextEditingController? s3AccessKey;
  String? Function(BuildContext, String?)? s3AccessKeyValidator;
  // State field(s) for TextField widget.
  FocusNode? s3SecretKeyFocusNode;
  TextEditingController? s3SecretKey;
  String? Function(BuildContext, String?)? s3SecretKeyValidator;

  FocusNode? s3BucketFocusNode;
  TextEditingController? s3Bucket;
  String? Function(BuildContext, String?)? s3BucketValidator;

  // State field(s) for TextField widget.
  FocusNode? saveDirectoryPathFocusNode;
  TextEditingController? saveDirectoryPath;
  String? Function(BuildContext, String?)? saveDirectoryPathValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    s3EndpointFocusNode?.dispose();
    s3Endpoint?.dispose();

    s3AccessKeyFocusNode?.dispose();
    s3AccessKey?.dispose();

    s3SecretKeyFocusNode?.dispose();
    s3SecretKey?.dispose();

    saveDirectoryPathFocusNode?.dispose();
    saveDirectoryPath?.dispose();
  }
}
