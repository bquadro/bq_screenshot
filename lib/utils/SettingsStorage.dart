import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SettingsstorageData {
  late String saveDirectoryPath;
  late String s3_endPoint;
  late String s3_accessKey;
  late String s3_secretKey;

  toJson() {
    return jsonEncode({
      "saveDirectoryPath": saveDirectoryPath,
      "s3_endPoint": s3_endPoint,
      "s3_accessKey": s3_accessKey,
      "s3_secretKey": s3_secretKey,
    });
  }

  fromJson(String json) {
    if (json.isEmpty == false) {
      Map parse = jsonDecode(json);
      saveDirectoryPath = parse['saveDirectoryPath'];
      s3_endPoint = parse['s3_endPoint'];
      s3_accessKey = parse['s3_accessKey'];
      s3_secretKey = parse['s3_secretKey'];
    }
  }
}

class Settingstorage {
  late SettingsstorageData Settings;

  static const String configFileName = "config.json";

  Settingstorage() {
    Settings = SettingsstorageData();
  }

  Future<Settingstorage> loadSettings() async {
    final configExist = await isConfigExist();
    if (configExist) {
      File settingsFile = await getConfigFile();
      final contents = await settingsFile.readAsString();
      Settings.fromJson(contents);
    }
    return this;
  }

  Future<void> saveSettings() async {
    File settingsFile = await getConfigFile();
    settingsFile.writeAsStringSync(Settings.toJson());
  }

  Future<bool> isConfigExist() async {
    File config = await getConfigFile();
    return config.existsSync();
  }

  Future<File> getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/${configFileName}');
  }

  Future<String> getDefaultSaveDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/Screenshots/";
  }
}
