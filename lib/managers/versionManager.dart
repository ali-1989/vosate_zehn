import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/versionModel.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/deviceInfoTools.dart';

class VersionManager {
  VersionManager._();

  static Future<void> onFirstInstall() async {
    SettingsManager.settingsModel.currentVersion = Constants.appVersionCode;

    await AppDB.firstLaunch();
    AppThemes.prepareFonts(SettingsManager.settingsModel.appLocale.languageCode);
    SettingsManager.saveSettings();
  }

  static Future<void> onUpdateInstall() async {
    SettingsManager.settingsModel.currentVersion = Constants.appVersionCode;
    SettingsManager.saveSettings();
  }

  static Future<void> checkInstallVersion() async {
    final oldVersion = SettingsManager.settingsModel.currentVersion;

    if (oldVersion == null) {
      onFirstInstall();
    }
    else if (oldVersion < Constants.appVersionCode) {
      onUpdateInstall();
    }
  }

  static Future<VersionModel?> requestCheckVersion(BuildContext context, Map<String, dynamic> data) async {
    final res = Completer<VersionModel?>();

    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final version = VersionModel.fromMap(data);

      res.complete(version);
    };

    requester.bodyJson = data;
    requester.prepareUrl();
    requester.request(context, false);
    return res.future;
  }

  static void checkAppHasNewVersion(BuildContext context) async {
    final deviceInfo = DeviceInfoTools.getDeviceInfo();

    final vm = await requestCheckVersion(context, deviceInfo);

    if(vm != null){
      if(vm.newVersionCode > Constants.appVersionCode){
        showUpdateDialog(context, vm);
      }
    }
  }

  /*static void checkAppHasNewVersion(BuildContext context, VersionModel serverVersion) async {
    var v = serverVersion.newVersionName;
    v = v.replaceAll('.', '');

    if(MathHelper.toInt(v) > Constants.appVersionCode){
      showUpdateDialog(context, serverVersion);
    }
  }*/

  static void showUpdateDialog(BuildContext context, VersionModel vm) {
    final msg = vm.description?? AppMessages.newAppVersionIsOk;

    void closeApp(){
      System.exitApp();
    }

    final decoration = AppDialogIris.instance.dialogDecoration.copy();
    decoration.positiveButtonBackColor = Colors.blue;

    AppDialogIris.instance.showYesNoDialog(
      context,
      desc: msg,
      decoration: decoration,
      yesText: AppMessages.update,
      noText: vm.restricted ? AppMessages.exit : AppMessages.later,
      yesFn: (){
        UrlHelper.launchLink(vm.link?? '');
      },
      noFn: vm.restricted ? closeApp: null,
    );
  }
}
