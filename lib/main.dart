import 'dart:async';

import 'package:app/services/javaCallService.dart';
import 'package:app/services/cronTask.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:go_router/go_router.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/models/settingsModel.dart';
import 'package:app/pages/splash_page.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';

///================ call on any hot restart
Future<void> main() async {

  Future<void> mainInitialize() async {
    SchedulerBinding.instance.ensureVisualUpdate();
    SchedulerBinding.instance.window.scheduleFrame();

    FlutterError.onError = onErrorCatch;
    GoRouter.setUrlPathStrategy(UrlPathStrategy.path);

    FireBaseService.init();
    JavaCallService.init();
    CronTask.init();
  }

  WidgetsFlutterBinding.ensureInitialized();
  final initOk = await InitialApplication.importantInit();

  if(!initOk){
    runApp(const MyErrorApp());
  }
  else {
    runZonedGuarded(() async {
      await mainInitialize();
      runApp(const MyApp());
    }, zonedGuardedCatch);
  }
}
///==============================================================================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ///============ call on any hot reload
  @override
  Widget build(BuildContext context) {
    AppRoute.materialContext = context;

    /// ReBuild First Widgets tree, not call on Navigator pages
    return StreamBuilder<bool>(
        initialData: false,
        stream: AppBroadcast.viewUpdaterStream.stream,
        builder: (context, snapshot) {
        return MaterialApp.router(
          key: AppBroadcast.materialAppKey,
          scaffoldMessengerKey: AppBroadcast.rootScaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          routeInformationProvider: mainRouter.routeInformationProvider,
          routeInformationParser: mainRouter.routeInformationParser,
          routerDelegate: mainRouter.routerDelegate,
          title: Constants.appTitle,
          theme: AppThemes.instance.themeData,
          //darkTheme: ThemeData.dark(),
          themeMode: AppThemes.instance.currentThemeMode,
          //navigatorObservers: [ClearFocusOnPush()],
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
            },
          ),
          localizationsDelegates: AppLocale.getLocaleDelegates(),
          supportedLocales: AppLocale.getAssetSupportedLocales(),
          locale: InitialApplication.isInit()? SettingsManager.settingsModel.appLocale : SettingsModel.defaultAppLocale,
          /*localeResolutionCallback: (deviceLocale, supportedLocales) {
            return SettingsManager.settingsModel.appLocale;
          },*/
          //home: materialHomeBuilder(),
          builder: (subContext, home) {
            return Directionality(
                textDirection: AppThemes.instance.textDirection,
                child: materialHomeBuilder(home)
            );
          },
        );
      }
    );
  }

  Widget materialHomeBuilder(Widget? firstPage){
    return Builder(
      builder: (subContext){
        AppRoute.materialContext = subContext;
        final mediaQueryData = MediaQuery.of(subContext);

        /// detect orientation change and rotate screen
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaleFactor: 1.0),
          child: OrientationBuilder(builder: (context, orientation) {
            testCodes(context);

            return Toaster(child: SplashPage(firstPage: firstPage));
          }),
        );
      },
    );
  }

  Future<void> testCodes(BuildContext context) async {
    //await AppDB.db.clearTable(AppDB.tbKv);
  }
}
///==============================================================================================
class MyErrorApp extends StatelessWidget {
  const MyErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.expand(
          child: ColoredBox(
              color: Colors.brown,
            child: Center(child: Text('Error in init')),
          ),
        ),
      ),
    );
  }
}
///==============================================================================================
void onErrorCatch(FlutterErrorDetails errorDetails) {
  var data = 'on Error catch: ${errorDetails.exception.toString()}';

  if(!kIsWeb) {
    data += '\n stack: ${errorDetails.stack}';
  }

  data += '\n==========================================[Error catch]';

  PublicAccess.logger.logToAll(data);
}
///==============================================================================================
zonedGuardedCatch(error, sTrace) {
  var txt = 'on ZonedGuarded catch: ${error.toString()}';
  txt += '\n==========================================[ZonedGuarded]';
  PublicAccess.logger.logToAll(txt);

  if(kDebugMode) {
    throw error;
  }
}
