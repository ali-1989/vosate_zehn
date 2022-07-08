import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:iris_tools/net/trustSsl.dart';
import 'package:lottie/lottie.dart';
import 'package:vosate_zehn/constants.dart';
import 'package:vosate_zehn/managers/settingsManager.dart';
import 'package:vosate_zehn/managers/versionManager.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appLocale.dart';
import 'package:vosate_zehn/tools/app/appManager.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';
import 'package:flutter/material.dart';
import 'package:vosate_zehn/system/initialize.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appDb.dart';
import 'package:vosate_zehn/tools/app/appDirectories.dart';
import 'package:vosate_zehn/tools/app/appSizes.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:vosate_zehn/tools/deviceInfoTools.dart';
import 'package:spring/spring.dart';

bool _isInit = false;
bool _isLoadingSettings = true;
bool mustShowSplash = false;
int splashWaitingMil = 5000;

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
          _checkTimer();
          init();

          if (_isLoadingSettings || mustShowSplash) {
            return getSplashView();
          }
          else {
            return getMaterialApp();
          }
        });
  }

  ///==================================================================================================
  Widget getSplashView() {
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

          Spring.fadeIn(
            animDuration: const Duration(milliseconds: 700),
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
        routeInformationProvider: routers.routeInformationProvider,
        routeInformationParser: routers.routeInformationParser,
        routerDelegate: routers.routerDelegate,
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
        builder: EasyLoading.init(
          builder: (context, home) {
            AppRoute.materialContext = context;
            final mediaQueryData = MediaQuery.of(context);

            /// detect orientation change and rotate screen
            return MediaQuery(
              data: mediaQueryData.copyWith(textScaleFactor: 1.0),
              child: OrientationBuilder(builder: (context, orientation) {
                //AppLocale.detectLocaleDirection(SettingsManager.settingsModel.appLocale); //Localizations.localeOf(context)
                testCodes(context);

                return Directionality(textDirection: AppThemes.instance.textDirection, child: home!);
              }),
            );
          },
        )
    );
  }

  void _checkTimer() async {
    if(splashWaitingMil > 0 && mustShowSplash){
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
    await prepareReporter();
    await prepareDatabase();

    AppSizes.initial();
    AppThemes.initial();
    TrustAllCertificates.acceptBadCertificate();
    _isLoadingSettings = !SettingsManager.loadSettings();

    if (!_isLoadingSettings) {
      await checkInstallVersion();
      await Session.fetchLoginUsers();

      await InitialApplication.onceInit(context);

      AppBroadcast.reBuildMaterialBySetTheme();
      asyncInitial(context);
    }
  }

  Future<bool> prepareReporter() async {
    AppManager.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');

    return true;
  }

  Future<DatabaseHelper> prepareDatabase() async {
    AppDB.db = DatabaseHelper();
    AppDB.db.setDatabasePath(await AppDirectories.getDatabasesDir());
    AppDB.db.setDebug(false);

    await AppDB.db.openTable(AppDB.tbKv);
    await AppDB.db.openTable(AppDB.tbLanguages);
    await AppDB.db.openTable(AppDB.tbUserModel);

    return AppDB.db;
  }

  Future<void> checkInstallVersion() async {
    final oldVersion = SettingsManager.settingsModel.currentVersion;

    if (oldVersion == null) {
      VersionManager.onFirstInstall();
    }
    else if (oldVersion < Constants.appVersionCode) {
      VersionManager.onUpdateInstall();
    }
  }

  void asyncInitial(BuildContext context) {
    if (!InitialApplication.isLaunchOk) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
          if (InitialApplication.isInitialOk) {
            timer.cancel();

            checkAppNewVersion(context);
            InitialApplication.callOnLaunchUp();
          }
        });
      });
    }
  }

  void checkAppNewVersion(BuildContext context) async {
    final holder = DeviceInfoTools.getDeviceInfo();

    //final version = await VersionManager.checkVersion(holder);
  }

  Future<void> testCodes(BuildContext context) async {
    //await DbCenter.db.clearTable(DbCenter.tbKv);
  }
}
