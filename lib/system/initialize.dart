import 'dart:async';

import 'package:app/services/cronTask.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appThemes.dart';
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
import 'package:app/services/downloadUpload.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/websocketService.dart';
import 'package:app/system/lifeCycleApplication.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/netListenerTools.dart';
import 'package:app/tools/userLoginTools.dart';

class InitialApplication {
  InitialApplication._();

  static bool _importantInit = false;
  static bool _callLaunchUpInit = false;
  static bool _isInitialOk = false;
  static bool _callLazyInit = false;

  static bool isInit() {
    return _isInitialOk;
  }

  static Future<bool> importantInit() async {
    if (_importantInit) {
      return true;
    }

    try {
      await AppDirectories.prepareStoragePaths(Constants.appName);

      PublicAccess.logger = Logger('${AppDirectories.getTempDir$ex()}/logs');

      if (!kIsWeb) {
        PublicAccess.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
      }

      _importantInit = true;
      return true;
    }
    catch (e){
      return false;
    }
  }

  static Future<void> launchUpInit() async {
    if (_callLaunchUpInit) {
      return;
    }

    try {
      _callLaunchUpInit = true;
      await AppDB.init();
      AppThemes.initial();

      if (!kIsWeb) {
        await AppNotification.initial();
        AppNotification.startListenTap();
      }

      TrustSsl.acceptBadCertificate();
      await DeviceInfoTools.prepareDeviceInfo();
      await DeviceInfoTools.prepareDeviceId();

      await AppLocale.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'EE'));

      _isInitialOk = true;
    }
    catch (e){
      PublicAccess.logger.logToAll('error in launchUpInit >> $e');
    }

    return;
  }

  static Future<void> launchUpInitWithContext(BuildContext context) async {
    AppRoute.init();
    AppCache.screenBack = const AssetImage(AppImages.background);
    await precacheImage(AppCache.screenBack!, context);
  }

  static Future<void> appLazyInit() {
    // error if main() not called: WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
      //CronTask.init();

      /// net & websocket
      NetManager.addChangeListener(NetListenerTools.onNetListener);
      WebsocketService.prepareWebSocket(SettingsManager.settingsModel.wsAddress);
      //await PublicAccess.logger.logToAll('@@@@@@@ prepareWebSocket'); //todo
      /// life cycle
      final eventListener = AppEventListener();
      eventListener.addResumeListener(LifeCycleApplication.onResume);
      eventListener.addPauseListener(LifeCycleApplication.onPause);
      eventListener.addDetachListener(LifeCycleApplication.onDetach);
      WidgetsBinding.instance.addObserver(eventListener);

      /// downloader
      DownloadUploadService.downloadManager = DownloadManager('${Constants.appName}DownloadManager');
      DownloadUploadService.uploadManager = UploadManager('${Constants.appName}UploadManager');
      DownloadUploadService.downloadManager.addListener(DownloadUploadService.commonDownloadListener);
      DownloadUploadService.uploadManager.addListener(DownloadUploadService.commonUploadListener);

      /// login & logoff
      Session.addLoginListener(UserLoginTools.onLogin);
      Session.addLogoffListener(UserLoginTools.onLogoff);
      Session.addProfileChangeListener(UserLoginTools.onProfileChange);

      if (System.isWeb()) {
        void onSizeCheng(oldW, oldH, newW, newH) {
          AppDialogIris.prepareDialogDecoration();
        }

        AppSizes.instance.addMetricListener(onSizeCheng);
      }

      MediaManager.loadAllRecords();
      FireBaseService.getToken().then((value) {
        FireBaseService.subscribeToTopic(PublicAccess.fcmTopic);
      });

      if(AppRoute.materialContext != null) {
        AdvertisingManager.init();
        AidService.checkShowDialog();

        VersionManager.checkAppHasNewVersion(AppRoute.getContext()!);
      }

      //DailyTextService.checkShowDialog();
    }
    catch (e){
      _callLazyInit = false;
      PublicAccess.logger.logToAll('error in lazyInitCommands >> $e');
    }
  }
}
