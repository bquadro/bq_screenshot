// Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minio/io.dart';
import 'package:minio/minio.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

import '../main.dart';
import 'SettingsStorage.dart';

// Project imports:

mixin EditorEventsState<T extends StatefulWidget> on State<T> {
  final editorKey = GlobalKey<ProImageEditorState>();
  Uint8List? editedBytes;
  double? _generationTime;
  DateTime? startEditingTime;
  String? _rawImagePath;

  Future<void> onImageEditingStarted() async {
    startEditingTime = DateTime.now();
  }

  Future<void> onImageEditingComplete(bytes) async {
    editedBytes = bytes;
    setGenerationTime();
  }

  void setRawImagePath(String? imagePath) {
    _rawImagePath = imagePath;
  }

  void setGenerationTime() {
    if (startEditingTime != null) {
      _generationTime = DateTime.now()
          .difference(startEditingTime!)
          .inMilliseconds
          .toDouble();
    }
  }

  void onCloseEditor({
    required EditorMode editorMode,
    bool enablePop = true,
    bool showThumbnail = false,
    ui.Image? rawOriginalImage,
    final ImageGenerationConfigs? generationConfigs,
  }) async {
    if (editorMode != EditorMode.main) return Navigator.pop(context);

    if (editedBytes != null) {
      // Pre-cache the edited image to improve display performance.
      await precacheImage(MemoryImage(editedBytes!), context);
      if (!mounted) return;

      // Navigate to the preview page to display the edited image.
      editorKey.currentState?.isPopScopeDisabled = true;
    }

    if (mounted && enablePop) {
      Navigator.pop(context);
    }
  }

  Future<void> uploadToS3(String fileName, String filePath) async {
    Settingstorage _settings = await Settingstorage().loadSettings();

    if (_settings.Settings.s3_endPoint.isNotEmpty &&
        _settings.Settings.s3_secretKey.isNotEmpty &&
        _settings.Settings.s3_accessKey.isNotEmpty &&
        _settings.Settings.s3_bucket.isNotEmpty) {
      final minio = Minio(
        endPoint: _settings.Settings.s3_endPoint,
        accessKey: _settings.Settings.s3_accessKey,
        secretKey: _settings.Settings.s3_secretKey,
        enableTrace: true,
      );

      var result = await minio.fPutObject(
          _settings.Settings.s3_bucket, fileName, filePath);

      talker.debug("minio result after putObject = ${result}");

      if (result.isNotEmpty) {
        Clipboard.setData(ClipboardData(
            text:
                "https://${_settings.Settings.s3_endPoint}/${_settings.Settings.s3_bucket}/$fileName"));
      }
    }
  }
}

extension on ProImageEditorState? {
  set disablePopScope(bool disablePopScope) {}
}

Future<String?> checkS3Connection() async {
  Settingstorage _settings = await Settingstorage().loadSettings();

  if (_settings.Settings.s3_endPoint.isNotEmpty &&
      _settings.Settings.s3_secretKey.isNotEmpty &&
      _settings.Settings.s3_accessKey.isNotEmpty &&
      _settings.Settings.s3_bucket.isNotEmpty) {
    final minio = Minio(
      endPoint: _settings.Settings.s3_endPoint,
      accessKey: _settings.Settings.s3_accessKey,
      secretKey: _settings.Settings.s3_secretKey,
      enableTrace: true,
    );

    var listBuckets;

    listBuckets = await minio.listBuckets();

    bool isBucketExist = await minio.bucketExists(_settings.Settings.s3_bucket);

    if (!isBucketExist) {
      throw 'Error, check your settings';
    }

    talker.debug("listBuckets = $listBuckets");
    return listBuckets.toString();
  } else {
    throw 'Error, check your settings';
  }
}
