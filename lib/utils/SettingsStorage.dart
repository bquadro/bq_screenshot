import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Settingstorage{
  Directory? saveDirectoryPath;

  // Settingstorage() {
  //   _init();
  // }

  Future<void> _init() async {
    saveDirectoryPath = await getApplicationDocumentsDirectory();
  }

  String? getSaveDirectoryPath(){
    return saveDirectoryPath?.path;
  }

}