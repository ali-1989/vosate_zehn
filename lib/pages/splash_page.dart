import 'dart:async';

import 'package:vosate_zehn/constants.dart';
import 'package:vosate_zehn/managers/settingsManager.dart';
import 'package:vosate_zehn/managers/versionManager.dart';
import 'package:vosate_zehn/system/lifeCycleApplication.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appManager.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';
import 'package:flutter/material.dart';
import 'package:vosate_zehn/system/initialize.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appDb.dart';
import 'package:vosate_zehn/tools/app/appDirectories.dart';
import 'package:vosate_zehn/tools/app/appSizes.dart';
import 'package:iris_tools/dataBase/databaseHelper.dart';
import 'package:iris_tools/dataBase/reporter.dart';
import 'package:iris_tools/net/httpTools.dart';

bool _isInit = false;
bool _loadAppSettings = false;

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

    init();
  }

  @override
  Widget build(BuildContext context) {
    /// ReBuild First Widgets tree, not call on Navigator pages
    return StreamBuilder<bool>(
        initialData: false,
        stream: AppBroadcast.materialUpdaterStream.stream,
        builder: (context, snapshot) {
          if (!_loadAppSettings) {
            return getSplash();
          }
          else {
            return getMaterialApp();
          }
        }
        );
  }

  ///==================================================================================================
  Widget getSplash() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 100.0,
            decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(AppImages.logoSplash)
                )
            ),
          ),
          Container(
            height: 25.0,
            width: 200.0,
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AppImages.splashLoading), fit: BoxFit.cover)),
          ),
        ],
      ),
    );
  }

  // MaterialApp/ CupertinoApp/ WidgetsApp
  Widget getMaterialApp() {
    return MaterialApp(
      key: AppBroadcast.materialAppKey,
      debugShowCheckedModeBanner: false,
      //navigatorObservers: [ClearFocusOnPush()],
      //scrollBehavior: MyCustomScrollBehavior(),
      //onGenerateTitle: (ctx) => ,
      title: Constants.appTitle,
      theme: AppThemes.themeData,
      //or: ThemeData.light(),
      //darkTheme: ThemeData.dark(),
      themeMode: AppThemes.currentThemeMode,
      scaffoldMessengerKey: AppBroadcast.rootScaffoldMessengerKey,
      navigatorKey: AppBroadcast.rootNavigatorStateKey,
      //localizationsDelegates: AppLocale.getLocaleDelegates(),
      //supportedLocales: AppLocale.getAssetSupportedLocales(),
      //locale: SettingsManager.settingsModel.appLocale,
      /*localeResolutionCallback: (deviceLocale, supportedLocales) {
        return SettingsManager.settingsModel.appLocale;
      },*/
      home: RoutePage(),
      builder: (context, home) {
        AppRoute.materialContext = context;
        InitialApplication.oncePreparing(context);
        final mediaQueryData = MediaQuery.of(context);

        /// detect orientation change and rotate screen
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaleFactor: 1.0),
          child: OrientationBuilder(builder: (context, orientation) {
            //detectLocaleDirection(Localizations.localeOf(context));
            //AppLocale.detectLocaleDirection(SettingsManager.settingsModel.appLocale);
            testCodes(context);

            return Directionality(
                textDirection: AppThemes.instance.textDirection,
                child: home!
            );
          }),
        );
      },
    );
  }

  void init() async {
    if (_isInit) {
      return;
    }

    _isInit = true;

    await InitialApplication.waitForImportant();
    await prepareReporter();
    await prepareDatabase();

    AppSizes.initial();
    AppThemes.initial();
    HttpTools.ignoreSslBadHandshake();
    _loadAppSettings = SettingsManager.loadSettings();

    if (_loadAppSettings) {
      await checkAppVersion();
      await Session.fetchLoginUsers();

      AppBroadcast.reBuildMaterialBySetTheme();
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

  Future<void> checkAppVersion() async {
    final oldVersion = SettingsManager.settingsModel.appVersion;

    if (oldVersion == null) {
      VersionManager.onFirstInstall();
    } else if (oldVersion < Constants.appVersionCode) {
      VersionManager.onUpdateVersion();
    }
  }

  Future<void> testCodes(BuildContext context) async {
    //await DbCenter.db.clearTable(DbCenter.tbKv);
  }
}
///=============================================================================================================
void callOnBuild() {
  if (!SettingsManager.calledBootUp) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
        if (InitialApplication.isInitialOk) {
          timer.cancel();
          LifeCycleApplication.callOnLaunchUp();
        }
      });
    });
  }

  if (SettingsManager.settingsModel.currentRouteScreen == RoutesName.homePage) {
    AppDirectories.generateNoMediaFile();
  }
}

void checkAppNewVersion(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  final holder = VersionUpdateHolder();
  holder.version = int.parse(packageInfo.buildNumber);
  holder.pkgName = packageInfo.packageName;
  holder.os = 1;

  final version = await VersionManager.checkVersion(holder);

  if (version != null && (version.hasUpdate ?? false)) {
    final page = WebPageViewer(version.webPageUrl!, "آپدیت برنامه", update: true, force: version.isForce!,);

    AppNavigator.pushNextPage(
        context,
        page,
        name: 'FunPlaces'
    );
  }
}
