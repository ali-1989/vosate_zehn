import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/net/netManager.dart';
import 'package:iris_tools/net/trustSsl.dart';

import 'package:app/constants.dart';
import 'package:app/managers/advertisingManager.dart';
import 'package:app/managers/mediaManager.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/systemParameterManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/services/aidService.dart';
import 'package:app/services/cron_task.dart';
import 'package:app/services/download_upload_service.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/services/websocket_service.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/system/applicationLifeCycle.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/netListenerTools.dart';
import 'package:app/tools/routeTools.dart';

class ApplicationInitial {
  ApplicationInitial._();

  static bool _importantInit = false;
  static bool _callInSplashInit = false;
  static bool _isInitialOk = false;
  static bool _callLazyInit = false;
  static String errorInInit = '';

  static bool isInit() {
    return _isInitialOk;
  }

  static Future<bool> prepareDirectoriesAndLogger() async {
    if (_importantInit) {
      return true;
    }

    try {
      _importantInit = true;

      if (!kIsWeb) {
        await AppDirectories.prepareStoragePaths(Constants.appName);
        PublicAccess.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
      }

      PublicAccess.logger = Logger('${AppDirectories.getTempDir$ex()}/logs');

      return true;
    }
    catch (e){
      _importantInit = false;
      errorInInit = '$e\n\n${StackTrace.current}';
      log('$e\n\n${StackTrace.current}');
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
      //AudioPlayerService.init();

      if (!kIsWeb) {
        await AppNotification.initial();
        AppNotification.startListenTap();
      }

      _isInitialOk = true;
    }
    catch (e){
      PublicAccess.logger.logToAll('error in inSplashInit >> $e');
    }

    return;
  }

  static Future<void> inSplashInitWithContext(BuildContext context) async {
    RouteTools.prepareWebRoute();
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

      /// life cycle
      ApplicationLifeCycle.init();

      /// downloader
      DownloadUploadService.init();

      /// login & logoff
      EventNotifierService.addListener(AppEvents.userLogin, LoginService.onLoginObservable);
      EventNotifierService.addListener(AppEvents.userLogoff, LoginService.onLogoffObservable);

      /*if (System.isWeb()) {
        void onSizeCheng(oldW, oldH, newW, newH) {
          AppDialogIris.prepareDialogDecoration();
        }

        AppSizes.instance.addMetricListener(onSizeCheng);
      }*/

      SystemParameterManager.requestParameters();
      MediaManager.loadAllRecords();
      AdvertisingManager.init();
      AdvertisingManager.check();

      if(RouteTools.materialContext != null) {
        AidService.checkShowDialog();
        VersionManager.checkAppHasNewVersion(RouteTools.getBaseContext()!);
      }

      EventNotifierService.addListener(AppEvents.firebaseTokenReceived, ({data}) {
        FireBaseService.subscribeToTopic(PublicAccess.fcmTopic);
      });

      await FireBaseService.prepare();

      Future.delayed(Duration(seconds: 3), (){
        FireBaseService.getToken();
      });
    }
    catch (e){
      _callLazyInit = false;
      PublicAccess.logger.logToAll('error in lazyInitCommands >> $e');
    }
  }
}
