import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/views/states/waitToLoad.dart';

bool _isInit = false;
bool _isInLoadingSettings = true;
bool _isConnectToServer = true;
bool isInSplashTimer = true;
int splashWaitingMil = 4000;

class SplashPage extends StatefulWidget {
  final Widget? firstPage;

  SplashPage({this.firstPage, super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}
///======================================================================================================
class SplashScreenState extends StateBase<SplashPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    splashWaitTimer();
    init();

    if (waitInSplash()) {
      //System.hideBothStatusBarOnce();
      return getSplashView();
    }
    else {
      return getFirstPage();
    }
  }
  ///==================================================================================================
  Widget getSplashView() {
    if(kIsWeb){
      return const WaitToLoad();
    }

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.logoSplash),
            fit: BoxFit.fill,
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset(
              AppImages.loadingLottie,
              width: 300,
              height: 300,
              reverse: false,
              animate: true,
              fit: BoxFit.fill,
            ),

            FadeIn(
              duration: const Duration(milliseconds: 700),
              child: Image.asset(AppImages.appIcon,
              width: 100,
              height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
  ///==================================================================================================
  Widget getFirstPage(){
    return Builder(
      builder: (ctx){
         return widget.firstPage?? LayoutPage(key: AppBroadcast.layoutPageKey);
      },
    );
  }

  bool waitInSplash(){
    return !kIsWeb && (isInSplashTimer || _isInLoadingSettings || !_isConnectToServer);
  }

  void splashWaitTimer() async {
    if(splashWaitingMil > 0){
      Timer(Duration(milliseconds: splashWaitingMil), (){
        isInSplashTimer = false;
        AppBroadcast.reBuildMaterial();
      });

      splashWaitingMil = 0;
    }
  }

  void init() async {
    if (_isInit) {
      return;
    }

    _isInit = true;

    await InitialApplication.launchUpInit();
    await InitialApplication.launchUpInitWithContext(AppRoute.getLastContext()!);
    final settingsLoad = SettingsManager.loadSettings();

    if (settingsLoad) {
      await Session.fetchLoginUsers();
      await VersionManager.checkInstallVersion();
      connectToServer();

      InitialApplication.appLazyInit();
      _isInLoadingSettings = false;

      AppBroadcast.reBuildMaterialBySetTheme();
    }
  }

  void connectToServer() async {
    /*final serverData = await LoginService.requestOnSplash();

    if(serverData == null){
      AppSheet.showSheetOneAction(
        AppRoute.materialContext,
        AppMessages.errorCommunicatingServer, (){
        AppBroadcast.gotoSplash(2000);
        connectToServer();
      },
          buttonText: AppMessages.tryAgain,
          isDismissible: false,
      );
    }
    else {
      _isConnectToServer = true;
      AppBroadcast.reBuildMaterial();
    }*/
  }
}
