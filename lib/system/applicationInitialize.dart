import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_tools/api/appEventListener.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/net/netManager.dart';
import 'package:iris_tools/net/trustSsl.dart';

import 'package:app/constants.dart';
import 'package:app/managers/advertisingManager.dart';
import 'package:app/managers/mediaManager.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/services/aidService.dart';
import 'package:app/services/cron_task.dart';
import 'package:app/services/download_upload_service.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/websocket_service.dart';
import 'package:app/system/applicationLifeCycle.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/netListenerTools.dart';
import 'package:app/tools/userLoginTools.dart';

class ApplicationInitial {
  ApplicationInitial._();

  static bool _importantInit = false;
  static bool _callInSplashInit = false;
  static bool _isInitialOk = false;
  static bool _callLazyInit = false;

  static bool isInit() {
    return _isInitialOk;
  }

  static Future<bool> prepareDirectoriesAndLogger() async {
    if (_importantInit) {
      return true;
    }

    try {
      _importantInit = true;
      await AppDirectories.prepareStoragePaths(Constants.appName);
      PublicAccess.logger = Logger('${AppDirectories.getTempDir$ex()}/logs');

      if (!kIsWeb) {
        PublicAccess.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
      }

      return true;
    }
    catch (e){
      _importantInit = false;
      return false;
    }
  }

  static Future<void> inSplashInit() async {
    if (_callInSplashInit) {
      return;
    }

    try {
      _callInSplashInit = true;
      await AppDB.init();
      AppThemes.initial();
      TrustSsl.acceptBadCertificate();
      await AppLocale.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'EE'));
      await DeviceInfoTools.prepareDeviceInfo();
      await DeviceInfoTools.prepareDeviceId();

      if (!kIsWeb) {
        await AppNotification.initial();
        AppNotification.startListenTap();
      }

      _isInitialOk = true;
    }
    catch (e){
      PublicAccess.logger.logToAll('error in launchUpInit >> $e');
    }

    return;
  }

  static Future<void> inSplashInitWithContext(BuildContext context) async {
    AppRoute.init();
    AppCache.screenBack = const AssetImage(AppImages.background);
    await precacheImage(AppCache.screenBack!, context);
  }

  static Future<void> appLazyInit() {
    final c = Completer<void>();

    if (!_callLazyInit) {
      Timer.periodic(const Duration(milliseconds: 50), (Timer timer) async {
        if (_isInitialOk) {
          timer.cancel();
          await _lazyInitCommands();
          c.complete();
        }
      });
    }
    else {
      c.complete();
    }

    return c.future;
  }

  static Future<void> _lazyInitCommands() async {
    if (_callLazyInit) {
      return;
    }

    try {
      _callLazyInit = true;
      CronTask.init();

      /// net & websocket
      NetManager.addChangeListener(NetListenerTools.onNetListener);
      WebsocketService.prepareWebSocket(SettingsManager.settingsModel.wsAddress);
      //await PublicAccess.logger.logToAll('@@@@@@@ prepared WebSocket'); //todo
      /// life cycle
      ApplicationLifeCycle.init();

      /// downloader
      DownloadUploadService.init();

      /// login & logoff
      UserLoginTools.init();

      if (System.isWeb()) {
        void onSizeCheng(oldW, oldH, newW, newH) {
          AppDialogIris.prepareDialogDecoration();
        }

        AppSizes.instance.addMetricListener(onSizeCheng);
      }

      await FireBaseService.init();
      FireBaseService.getToken().then((value) {
        FireBaseService.subscribeToTopic(PublicAccess.fcmTopic);
      });

      MediaManager.loadAllRecords();

      if(AppRoute.materialContext != null) {
        AdvertisingManager.init();
        AidService.checkShowDialog();

        VersionManager.checkAppHasNewVersion(AppRoute.getLastContext()!);
      }

      //DailyTextService.checkShowDialog();
    }
    catch (e){
      _callLazyInit = false;
      PublicAccess.logger.logToAll('error in lazyInitCommands >> $e');
    }
  }
}
