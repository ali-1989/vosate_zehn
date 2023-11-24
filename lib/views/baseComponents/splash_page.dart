import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/managers/splash_manager.dart';
import 'package:app/managers/version_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_locale.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/views/baseComponents/route_dispatcher.dart';
import 'package:app/views/baseComponents/splash_widget.dart';
import 'package:app/views/states/wait_to_load.dart';

class SplashPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}
///=============================================================================
class SplashPageState extends StateSuper<SplashPage> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    splashWaitTimer();
    startInit();

    if (SplashManager.mustWaitInSplash()) {
      //System.hideBothStatusBarOnce();
      return getSplashView();
    }
    else {
      return getRoutePage();
    }
  }

  Widget getSplashView() {
    if(kIsWeb){
      return const WaitToLoad();
    }

    return const SplashView();
  }

  Widget getRoutePage(){
    if(kIsWeb && !SplashManager.isFullInitialOk){
      return const SizedBox();
    }

    return RouteDispatcher.dispatch();
  }

  void splashWaitTimer() async {
    final dur = Duration(milliseconds: SplashManager.splashWaitingMil);

    if(SplashManager.mustWaitToSplashTimer && timer == null){
      timer = Timer(dur, (){
        SplashManager.mustWaitToSplashTimer = false;
        timer = null;

        if(mounted){
          callState();
        }
      });
    }
  }

  void startInit() async {
    if (SplashManager.isFirstInitOk) {
      return;
    }

    SplashManager.isFirstInitOk = true;

    await SplashManager.appInitial(context);
    SettingsManager.init();
    SplashManager.appLazyInit();
    await SessionService.fetchLoginUsers();
    await VersionManager.checkVersionOnLaunch();
    connectToServer();

    SplashManager.isInLoadingSettings = false;
    AppThemes.instance.textDirection = AppLocale.detectLocaleDirection(SettingsManager.localSettings.appLocale);

    AppBroadcast.reBuildMaterialBySetTheme();
  }

  void connectToServer() async {
    /*final serverData = await SettingsManager.requestGlobalSettings();

    if (serverData == null) {
      AppSheet.showSheetOneAction(
        RouteTools.materialContext!,
        AppMessages.errorCommunicatingServer,
        onButton: () {
          SplashManager.gotoSplash();
          connectToServer();
        },
        buttonText: AppMessages.tryAgain,
        isDismissible: false,
      );
    }
    else {
      SplashManager.isConnectToServer = true;

      SessionService.fetchLoginUsers();

      if(context.mounted){
        callState();
      }
    }*/
  }
}
