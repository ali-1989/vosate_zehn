import 'package:flutter/foundation.dart';

import 'package:app/tools/app/app_broadcast.dart';

class SplashManager {
  SplashManager._();

  static int splashWaitingMil = 4000;
  static bool isFullInitialOk = false;
  static bool mustWaitToSplashTimer = true;
  static bool callLazyInit = false;
  static bool isFirstInitOk = false;
  static bool isInLoadingSettings = true;
  static bool isConnectToServer = true;

  static bool mustWaitInSplash(){
    return !kIsWeb && (mustWaitToSplashTimer || isInLoadingSettings || !isConnectToServer);
  }

  static void gotoSplash() {
    mustWaitToSplashTimer = true;
    AppBroadcast.reBuildMaterial();
  }
}

