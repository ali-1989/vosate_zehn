import 'dart:async';

import 'package:vosate_zehn/constants.dart';
import 'package:vosate_zehn/models/versionModel.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/tools/app/appDb.dart';
import '/managers/settingsManager.dart';

class VersionManager {
  VersionManager._();

  static Future<void> onFirstInstall() async {
    SettingsManager.settingsModel.currentVersion = Constants.appVersionCode;

    await AppDB.firstDatabasePrepare();
    SettingsManager.saveSettings();
  }

  static Future<void> onUpdateInstall() async {
    SettingsManager.settingsModel.currentVersion = Constants.appVersionCode;
    // ignore: unawaited_futures
    SettingsManager.saveSettings();
  }

  static Future<VersionModel?> checkVersion(Map data) async {
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
