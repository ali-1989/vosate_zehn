import 'dart:async';

import 'package:app/services/vip_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/net/trustSsl.dart';

import 'package:app/managers/advertising_manager.dart';
import 'package:app/managers/font_manager.dart';
import 'package:app/managers/media_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/managers/version_manager.dart';
import 'package:app/services/aid_service.dart';
import 'package:app/services/cafe_bazar_service.dart';
import 'package:app/services/download_upload_service.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/services/native_call_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/services/wakeup_service.dart';
import 'package:app/services/websocket_service.dart';
import 'package:app/structures/models/settings_model.dart';
import 'package:app/system/application_signal.dart';
import 'package:app/system/build_flavor.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_locale.dart';
import 'package:app/tools/app/app_notification.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/error_page.dart';

class SplashManager {
  SplashManager._();

  static int splashWaitingMil = 3000;
  static bool mustWaitToSplashTimer = true;
  static bool mustWaitToLoadingSettings = true;
  static bool startInitOnSplash = false;
  static bool isConnectToServer = true;
  static bool isBaseInitialize = false;

  static bool mustWaitInSplash(){
    return mustWaitToSplashTimer || mustWaitToLoadingSettings || !isConnectToServer;
  }

  static void gotoSplash() {
    mustWaitToSplashTimer = true;
    AppBroadcast.reBuildApp();
  }

  static Future<Object?> beforeRunApp() async {
    try {
      await FireBaseService.initializeApp();
      usePathUrlStrategy();

      if(kIsWeb){
        splashWaitingMil = 0;
      }

      return null;
    }
    catch (e){
      LogTools.logToAll('error in beforeRunApp >> $e');
      return e;
    }
  }

  static Future<void> baseInitial() async {
    try {
      await AppDB.init();
      await AppLocale.setFallBack();
      FontManager.init(calcFontSize: true);
      AppThemes.init();
      SettingsManager.init();
      BuildFlavor.initial();

      if(BuildFlavor.connectToTest()){
        SettingsManager.localSettings.httpAddress = 'http://192.168.1.102:7436';
        SettingsManager.localSettings.wsAddress = 'ws://192.168.1.102:7436/ws';
      }
      else if(BuildFlavor.resetToRelease()) {
        SettingsManager.localSettings.httpAddress = SettingsModel.defaultHttpAddress;
      }

      if(kIsWeb){
        bool isSecure = IrisNavigatorObserver.appBaseUrl().contains('https');
        String httpUrl = SettingsManager.localSettings.httpAddress;
        String wsUrl = SettingsManager.localSettings.wsAddress;

        if(isSecure) {
          RegExp pattern = RegExp(r':(\d+)');

          Match? match = pattern.firstMatch(httpUrl);
          String? capturedNumber = match?.group(1);
          int? number = int.tryParse(capturedNumber!);
          int port = (number??0) + 1;
          httpUrl = httpUrl.replaceFirst(pattern, ':$port');

          match = pattern.firstMatch(wsUrl);
          capturedNumber = match?.group(1);
          number = int.tryParse(capturedNumber!);
          port = (number??0) + 1;
          wsUrl = wsUrl.replaceFirst(pattern, ':$port');

          if (!httpUrl.contains('https')) {
            httpUrl = httpUrl.replaceFirst('http:', 'https:');
            SettingsManager.localSettings.httpAddress = httpUrl;
          }

          if (!wsUrl.contains('wss')) {
            wsUrl = wsUrl.replaceFirst('ws:', 'wss:');
            SettingsManager.localSettings.wsAddress = wsUrl;
          }
        }
      }

      isBaseInitialize = true;
      AppBroadcast.reBuildAppBySetTheme();
    }
    catch (e){
      runApp(ErrorPage(errorLog: e.toString()));
      LogTools.logToAll('error in base Initial >> $e');
    }
  }

  static void initOnSplash(BuildContext? context) async {
    if (startInitOnSplash) {
      return;
    }

    startInitOnSplash = true;

    try {
      await DeviceInfoTools.prepareDeviceInfo();
      await DeviceInfoTools.prepareDeviceId();
      TrustSsl.acceptBadCertificate();
      await SessionService.fetchLoginUsers();
      await VersionManager.checkVersionOnLaunch();
      connectToServer();
      //AudioPlayerService.init();

      if (!kIsWeb) {
        await AppNotification.initial();
        AppNotification.startListenTap();
      }

      if(context != null && context.mounted){
        RouteTools.prepareRoutes();
        AppCache.preLoadImages();
      }

      AppThemes.instance.textDirection = AppLocale.detectLocaleDirection(SettingsManager.localSettings.appLocale);
    }
    catch (e){
      LogTools.logToAll('error in initOnSplash >> $e');
    }

    _lazyInitCommands();

    mustWaitToLoadingSettings = false;
    AppBroadcast.reBuildApp();
  }

  static Future<void> _lazyInitCommands() async {
    try {
      ApplicationSignal.start();
      WakeupService.init();
      NativeCallService.init();
      NativeCallService.assistanceBridge?.invokeMethod('setAppIsRun');

      /*print('@@@@@@@@@@@@@@ call');
      final rec = await NativeCallService.assistanceBridge?.invokeMethodByArgs('throw_error', [{'delay': 5000}]);
      print(rec?.$1);
      print(rec?.$2);
      print('@@@@@@@');*/

      WebsocketService.startWebSocket(SettingsManager.localSettings.wsAddress);
      LoginService.init();
      DownloadUploadService.init();
      SettingsManager.requestGlobalSettings();
      MediaManager.loadAllRecords();
      AdvertisingManager.init();
      AdvertisingManager.check();
      CafeBazarService().reSendFailed();
      VipService.checkAutoBazarPurchase();

      if (kIsWeb) {
        FireBaseService.start();

        /*void onSizeCheng(oldW, oldH, newW, newH) {
          AppDialogIris.prepareDialogDecoration();
        }

        AppSizes.instance.addMetricListener(onSizeCheng);*/
      }
      else {
        await FireBaseService.start();
      }

      if(RouteTools.materialContext != null) {
        AidService.checkShowDialog();
        VersionManager.checkAppHasNewVersion(RouteTools.materialContext!);
      }
    }
    catch (e){
      LogTools.logToAll('error in lazyInitCommands >> $e');
    }
  }

  static void connectToServer() async {
    /*final serverData = await SettingsManager.requestGlobalSettings();

    if (serverData == null) {
      AppSheet.showSheetOneAction(
        RouteTools.materialContext!,
        AppMessages.errorCommunicatingServer,
        onButton: () {
          gotoSplash();
          connectToServer();
        },
        buttonText: AppMessages.tryAgain,
        isDismissible: false,
      );
    }
    else {
      isConnectToServer = true;
      SessionService.fetchLoginUsers();
      AppBroadcast.reBuildApp();
    }
    }*/
  }
}
