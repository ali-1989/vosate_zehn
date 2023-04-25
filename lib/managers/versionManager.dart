import 'dart:async';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/routeTools.dart';
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
import 'package:iris_tools/widgets/customCard.dart';

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
      res.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      newVersionModel = VersionModel.fromMap(data);

      res.complete(newVersionModel);
    };

    data[Keys.requestZone] = 'last_version';

    requester.bodyJson = data;
    requester.prepareUrl();
    requester.request(context, false);

    return res.future;
  }

  static void checkAppHasNewVersion(BuildContext context) async {
    final deviceInfo = DeviceInfoTools.getDeviceInfo();

    final vm = await requestGetLastVersion(context, deviceInfo);

    if(vm != null){
      if(vm.newVersionCode > Constants.appVersionCode){
        if(!vm.restricted && AppDB.fetchKv('promptVersion_${vm.newVersionCode}') != null){
          return;
        }

        existNewVersion = true;
        AppDB.setReplaceKv('promptVersion_${vm.newVersionCode}', true);

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

    if(vm.restricted) {
      decoration.positiveButtonBackColor = Colors.orange;
    }
    else {
      decoration.positiveButtonBackColor = Colors.grey;
    }

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

      if(!vm.restricted){
        Navigator.of(RouteTools.getBaseContext()!).pop();
      }
    }

    final views = <Widget>[];

    views.add(
        Align(
          alignment: Alignment.topLeft,
          child: CustomCard(
            padding: EdgeInsets.symmetric(horizontal: 4),
            color: Colors.green,
            radius: 12,
            child: Text('version: ${vm.newVersionName}', style: TextStyle(color: Colors.white),),
          ),
        )
    );

    views.add(Text(msg));

    if (vm.directLink != null) {
      views.add(SizedBox(height: 20));

      views.add(
          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                    child: Icon(AppIcons.downloadFile, size: 20, color: Colors.red,)
                ),

                TextSpan(
                  text: AppMessages.directDownload,
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = onDirectClick,
                ),
              ],
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = onDirectClick,
            ),
          ),
      );
    }

    if (vm.directLink != null) {
      views.add(SizedBox(height: 5));

      for(final market in vm.markets.entries){
        views.add(
            RichText(
                text: TextSpan(
                  text: market.key,
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()..onTap = (){
                    UrlHelper.launchLink(market.value);

                    if(!vm.restricted){
                      Navigator.of(RouteTools.getBaseContext()!).pop();
                    }
                    },
                )
            )
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: views,
    );
  }
}

/*
newVersionModel = VersionModel();
      newVersionModel!.directLink = 'http://www.google.com';
      newVersionModel!.description = 'نسخه ی جدید اپلیکیشن رسید. \n\n ویژگی ها:\n\n 1(پاهر جدید\n2( کلاس کلاس کلاس کلاس کلاس کلاس کلاس کلاس هست کلاس نیست دانلودپد لل\n یبل للا';
      newVersionModel!.newVersionCode = 100;
      newVersionModel!.newVersionName = '1.1.1';
      newVersionModel!.restricted = true;
      newVersionModel!.markets = {'دانلود از مایکت':'http://x.com', 'دانلود از بازار':'http://y.com'};
 */