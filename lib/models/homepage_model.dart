// import 'package:flutterflow_ui/flutterflow_ui.dart';
import '../pages/HomePage.dart' show HomePageWidget;
import 'package:flutter/material.dart';

import 'flutter_flow_model.dart' as model;

class HomePageModel extends model.FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}