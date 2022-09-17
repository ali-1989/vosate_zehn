import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:app/views/progressView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';

bool _isInit = false;
bool _isInLoadingSettings = true;
bool mustShowSplash = true;
int splashWaitingMil = 4000;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

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
    /// ReBuild First Widgets tree, not call on Navigator pages
    return StreamBuilder<bool>(
        initialData: false,
        stream: AppBroadcast.materialUpdaterStream.stream,
        builder: (context, snapshot) {
          splashTimer();
          init();

          if (_isInLoadingSettings || canShowSplash()) {
            return getSplashView();
          }
          else {
            return getMaterialApp();
          }
        });
  }

  ///==================================================================================================
  Widget getSplashView() {
    if(kIsWeb){
      return const ProgressView();
    }

    return DecoratedBox(
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
    );
  }

  // MaterialApp/ CupertinoApp/ WidgetsApp
  Widget getMaterialApp() {
    return MaterialApp.router(
        key: AppBroadcast.materialAppKey,
        debugShowCheckedModeBanner: false,
        routeInformationProvider: mainRouter.routeInformationProvider,
        routeInformationParser: mainRouter.routeInformationParser,
        routerDelegate: mainRouter.routerDelegate,
        //navigatorObservers: [ClearFocusOnPush()],
        //scrollBehavior: MyCustomScrollBehavior(),
        title: Constants.appTitle,
        theme: AppThemes.instance.themeData,
        // ThemeData.light()
        //darkTheme: ThemeData.dark(),
        themeMode: AppThemes.instance.currentThemeMode,
        scaffoldMessengerKey: AppBroadcast.rootScaffoldMessengerKey,
        //navigatorKey: AppBroadcast.rootNavigatorStateKey,
        localizationsDelegates: AppLocale.getLocaleDelegates(),
        supportedLocales: AppLocale.getAssetSupportedLocales(),
        locale: SettingsManager.settingsModel.appLocale,
        /*localeResolutionCallback: (deviceLocale, supportedLocales) {
        return SettingsManager.settingsModel.appLocale;
      },*/
        //home: const HomePage(),
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
        builder: (context, home) {
          AppRoute.materialContext = context;
          final mediaQueryData = MediaQuery.of(context);

          /// detect orientation change and rotate screen
          return MediaQuery(
            data: mediaQueryData.copyWith(textScaleFactor: 1.0),
            child: OrientationBuilder(builder: (context, orientation) {
              //AppLocale.detectLocaleDirection(SettingsManager.settingsModel.appLocale); //Localizations.localeOf(context)
              testCodes(context);

                return Directionality(
                    textDirection: AppThemes.instance.textDirection,
                    child: Toaster(child: home!)
              );
            }),
          );
        },
    );
  }
  ///==================================================================================================
  bool canShowSplash(){
    return mustShowSplash && !kIsWeb;
  }

  void splashTimer() async {
    if(splashWaitingMil > 0 && canShowSplash()){
      Timer(Duration(milliseconds: splashWaitingMil), (){
        mustShowSplash = false;

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

    await InitialApplication.importantInit();
    await AppDB.init();

    AppThemes.initial();
    _isInLoadingSettings = !SettingsManager.loadSettings();

    if (!_isInLoadingSettings) {
      await Session.fetchLoginUsers();
      await VersionManager.checkInstallVersion();
      await InitialApplication.onceInit(context);

      AppBroadcast.reBuildMaterialBySetTheme();
      asyncInitial(context);
    }
  }

  void asyncInitial(BuildContext context) {
    if (!InitialApplication.isLaunchOk) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
          if (InitialApplication.isInitialOk) {
            timer.cancel();

            VersionManager.checkAppHasNewVersion(context);
            InitialApplication.callOnLaunchUp();
          }
        });
      });
    }
  }

  Future<void> testCodes(BuildContext context) async {
    //await AppDB.db.clearTable(AppDB.tbFavorites);
    //SettingsManager.settingsModel.httpAddress = 'http://192.168.43.140:7436'; //1.103, 43.140
    //SettingsManager.settingsModel.httpAddress = 'http://vosatezehn.com:7436';
  }
}
