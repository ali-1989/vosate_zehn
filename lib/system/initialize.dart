import 'dart:async';

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

      if (!kIsWeb) {
        PublicAccess.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
      }

      PublicAccess.logger = Logger('${AppDirectories.getTempDir$ex()}/logs');

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

    _callLaunchUpInit = true;
    await AppDB.init();
    AppThemes.initial();

    TrustSsl.acceptBadCertificate();
    await DeviceInfoTools.prepareDeviceInfo();
    await DeviceInfoTools.prepareDeviceId();

    await AppLocale.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'EE'));

    //PlayerTools.init();

    if (!kIsWeb) {
      await AppNotification.initial();
      AppNotification.startListenTap();
    }

    _isInitialOk = true;
    return;
  }

  static Future<void> launchUpInitWithContext(BuildContext context) async {
    AppRoute.init();
    AppCache.screenBack = const AssetImage(AppImages.background);
    await precacheImage(AppCache.screenBack!, context);
  }

  static void appLazyInit() {
    if (!_callLazyInit) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
          if (_isInitialOk) {
            timer.cancel();

            _lazyInitCommands();
          }
        });
      });
    }
  }

  static void _lazyInitCommands() async {
    if (_callLazyInit) {
      return;
    }

    try {
      _callLazyInit = true;

      /// net & websocket
      await PublicAccess.logger.logToAll('---> 1 wsAddress: ${SettingsManager.settingsModel.wsAddress}');//todo

      WebsocketService.prepareWebSocket(SettingsManager.settingsModel.wsAddress);
      NetManager.addChangeListener(NetListenerTools.onNetListener);
      await PublicAccess.logger.logToAll('---> 2');//todo

      /// life cycle
      final eventListener = AppEventListener();
      eventListener.addResumeListener(LifeCycleApplication.onResume);
      eventListener.addPauseListener(LifeCycleApplication.onPause);
      eventListener.addDetachListener(LifeCycleApplication.onDetach);
      WidgetsBinding.instance.addObserver(eventListener);
      await PublicAccess.logger.logToAll('---> 3');//todo

      /// downloader
      DownloadUploadService.downloadManager = DownloadManager('${Constants.appName}DownloadManager');
      DownloadUploadService.uploadManager = UploadManager('${Constants.appName}UploadManager');
      DownloadUploadService.downloadManager.addListener(DownloadUploadService.commonDownloadListener);
      DownloadUploadService.uploadManager.addListener(DownloadUploadService.commonUploadListener);
      await PublicAccess.logger.logToAll('---> 4');//todo

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
        FireBaseService.subscribeToTopic('daily_text');
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
      await PublicAccess.logger.logToAll('---> e: $e');//todo

    }
  }
}
