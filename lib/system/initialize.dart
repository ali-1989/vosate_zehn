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

  static bool _callLaunchUpInit = false;
  static bool _isInitialOk = false;
  static bool _callLazyInit = false;

  static bool isInit() {
    return _isInitialOk;
  }

  static Future<bool> importantInit() async {
    try {
      await AppDirectories.prepareStoragePaths(Constants.appName);

      if (!kIsWeb) {
        PublicAccess.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
      }

      PublicAccess.logger = Logger('${AppDirectories.getTempDir$ex()}/logs');

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
    TrustSsl.acceptBadCertificate();
    await DeviceInfoTools.prepareDeviceInfo();
    await DeviceInfoTools.prepareDeviceId();

    AppRoute.init();
    await AppLocale.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'EE'));

    AppCache.screenBack = const AssetImage(AppImages.background);
    await precacheImage(AppCache.screenBack!, AppRoute.getContext());
    //PlayerTools.init();

    if (!kIsWeb) {
      await AppNotification.initial();
      AppNotification.startListenTap();
    }

    _isInitialOk = true;
    return;
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

  static void _lazyInitCommands() {
    if (_callLazyInit) {
      return;
    }

    _callLazyInit = true;

    VersionManager.checkAppHasNewVersion(AppRoute.getContext());
    final eventListener = AppEventListener();
    eventListener.addResumeListener(LifeCycleApplication.onResume);
    eventListener.addPauseListener(LifeCycleApplication.onPause);
    eventListener.addDetachListener(LifeCycleApplication.onDetach);
    WidgetsBinding.instance.addObserver(eventListener);

    WebsocketService.prepareWebSocket(SettingsManager.settingsModel.wsAddress);
    NetManager.addChangeListener(NetListenerTools.onNetListener);

    DownloadUploadService.downloadManager = DownloadManager('${Constants.appName}DownloadManager');
    DownloadUploadService.uploadManager = UploadManager('${Constants.appName}UploadManager');

    DownloadUploadService.downloadManager.addListener(DownloadUploadService.commonDownloadListener);
    DownloadUploadService.uploadManager.addListener(DownloadUploadService.commonUploadListener);

    if (System.isWeb()) {
      void onSizeCheng(oldW, oldH, newW, newH) {
        AppDialogIris.prepareDialogDecoration();
      }

      AppSizes.instance.addMetricListener(onSizeCheng);
    }

    Session.addLoginListener(UserLoginTools.onLogin);
    Session.addLogoffListener(UserLoginTools.onLogoff);
    Session.addProfileChangeListener(UserLoginTools.onProfileChange);

    MediaManager.loadAllRecords();
    AdvertisingManager.init();
    AidService.checkShowDialog();
    FireBaseService.getToken().then((value) {
      FireBaseService.subscribeToTopic('daily_text');
    });
    //DailyTextService.checkShowDialog();
  }
}
