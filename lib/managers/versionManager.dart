import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/versionModel.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/deviceInfoTools.dart';

class VersionManager {
  VersionManager._();

  static bool existNewVersion = false;
  static VersionModel? newVersionModel;

  static Future<void> onFirstInstall() async {
    SettingsManager.settingsModel.currentVersion = Constants.appVersionCode;

    await AppDB.firstLaunch();
    AppThemes.prepareFonts(SettingsManager.settingsModel.appLocale.languageCode);
    SettingsManager.saveSettings();
  }

  static Future<void> onReInstall() async {
    SettingsManager.settingsModel.currentVersion = Constants.appVersionCode;
    SettingsManager.saveSettings();
  }

  static Future<void> checkVersionOnLaunch() async {
    final oldVersion = SettingsManager.settingsModel.currentVersion;

    if (oldVersion == null) {
      onFirstInstall();
    }
    else if (oldVersion < Constants.appVersionCode) {
      onReInstall();
    }
  }

  static Future<VersionModel?> requestGetLastVersion(BuildContext context, Map<String, dynamic> data) async {
    final res = Completer<VersionModel?>();
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, response) async {
      newVersionModel = VersionModel();
      newVersionModel!.directLink = 'www.google.com';
      newVersionModel!.description = 'نسخه ی جدید اپلیکیشن رسید. \n\n ویژگی ها:\n\n 1(پاهر جدید\n2( کلاس کلاس کلاس کلاس کلاس کلاس کلاس کلاس هست کلاس نیست دانلودپد لل\n یبل للا';
      newVersionModel!.newVersionCode = 100;
      newVersionModel!.newVersionName = '1.1.1';
      newVersionModel!.restricted = false;

      res.complete(newVersionModel);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      newVersionModel = VersionModel.fromMap(data);

      res.complete(newVersionModel);
    };

    requester.bodyJson = data;
    requester.prepareUrl();
    requester.request(context, false);
    return res.future;
  }

  static void checkAppHasNewVersion(BuildContext context) async {
    final deviceInfo = DeviceInfoTools.getDeviceInfo();

    final vm = await requestGetLastVersion(context, deviceInfo);

    if(vm != null){
      if(true/*vm.newVersionCode > Constants.appVersionCode*/){
        existNewVersion = true;

        await Future.delayed(Duration(seconds: 4));
        showUpdateDialog(context, vm);
      }
    }
  }

  /*static void checkAppHasNewVersion(BuildContext context, VersionModel serverVersion) async {
    var v = serverVersion.newVersionName;
    v = v.replaceAll('.', '');

    if(MathHelper.toInt(v) > Constants.appVersionCode){
      existNewVersion = true;
      showUpdateDialog(context, serverVersion);
    }
  }*/

  static void showUpdateDialog(BuildContext context, VersionModel vm) {
    
    void closeApp(){
      System.exitApp();
    }

    final decoration = AppDialogIris.instance.dialogDecoration.copy();
    decoration.positiveButtonBackColor = Colors.grey;

    AppDialogIris.instance.showIrisDialog(
      context,
      descView: _buildView(vm),
      decoration: decoration,
      yesText: vm.restricted ? AppMessages.exit : AppMessages.later,
      yesFn: vm.restricted ? closeApp: null,
    );
  }

  static Widget _buildView(VersionModel vm){
    final msg = vm.description?? AppMessages.newAppVersionIsOk;

    void onDirectClick(){
      UrlHelper.launchLink(vm.directLink?? '');
    }

    return Column(
      children: [
        Text(msg),
        SizedBox(height: 20),

        Builder(
            builder: (_){
              if(vm.directLink != null){
                return RichText(
                    text: TextSpan(
                      text: AppMessages.directDownload,
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = onDirectClick,
                    ),
                );
              }

              return SizedBox();
            }
        ),

        Builder(
            builder: (_){
              print('hhhhh B');
              if(vm.markets.isNotEmpty){
                print('hhhhh B2');
                final list = vm.markets.entries.toList();

                return Column(
                  children: List.generate(vm.markets.length, (index) {
                    final itm = list.elementAt(index);

                    return RichText(
                        text: TextSpan(
                        text: itm.key,
                        recognizer: TapGestureRecognizer()..onTap = (){UrlHelper.launchLink(itm.value);},
                      )
                    );
                  }),
                );
              }

              return SizedBox();
            }
        ),
      ],
    );
  }
}