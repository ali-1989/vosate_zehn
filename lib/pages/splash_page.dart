import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/views/progressView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appThemes.dart';

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
class SplashScreenState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    splashWaitTimer();
    init();

    if (waitInSplash()) {
      //System.hideBothStatusBar();
      return getSplashView();
    }
    else {
      //System.showBothStatusBar();
      return getFirstPage();
    }
  }
  ///==================================================================================================
  Widget getSplashView() {
    if(kIsWeb){
      return const ProgressView();
    }

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.logoSplash),
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

    await AppDB.init();
    AppThemes.initial();
    final settingsLoad = SettingsManager.loadSettings();

    if (settingsLoad) {
      await Session.fetchLoginUsers();
      await VersionManager.checkInstallVersion();
      await InitialApplication.launchUpInit();
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
        AppBroadcast.gotoSplash(2);
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
