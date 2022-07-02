import 'dart:async';

import 'package:vosate_zehn/models/holders/versionUpdateHolder.dart';
import 'package:vosate_zehn/models/versionModel.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/tools/app/appDb.dart';

import '/managers/settingsManager.dart';

class VersionManager {
  VersionManager._();

  static Future<void> onFirstInstall() async {
    // ignore: unawaited_futures
    SettingsManager.saveSettings();
    await AppDB.firstDatabasePrepare();
  }

  static Future<void> onUpdateVersion() async {
    // ignore: unawaited_futures
    SettingsManager.saveSettings();
  }

  static Future<VersionModel?> checkVersion(VersionUpdateHolder holder) async {
    final res = Completer<VersionModel?>();

    final requester = Requester();
    //requester.httpItem.pathSection = 'CheckUpdate?VersionCode=';

    requester.httpRequestEvents.onFailState = (req) async {
      res.complete(null);
      return true;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final version = VersionModel.fromMap(data);

      res.complete(version);
    };

    requester.request();
    return res.future;
  }
}