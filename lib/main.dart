import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/structures/models/settingsModel.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/baseComponents/splashPage.dart';

///================ call on any hot restart
Future<void> main() async {
  if (defaultTargetPlatform != TargetPlatform.linux && defaultTargetPlatform != TargetPlatform.windows) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  final initOk = await prepareDirectoriesAndLogger();

  if(!initOk.$1){
    runApp(MyErrorApp(errorLog: initOk.$2));
    return;
  }

  await mainInitialize();

  void zoneFn() {
    runApp(
        StreamBuilder<bool>(
            initialData: true,
            stream: AppBroadcast.viewUpdaterStream.stream,
            builder: (context, snapshot) {
              return MaxWidth(
                maxWidth: AppSizes.webMaxWidthSize,
                apply: kIsWeb,
                child: Directionality(
                  textDirection: AppThemes.instance.textDirection,
                  child: DefaultTextHeightBehavior(
                    textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                    child: DefaultTextStyle(
                      style: AppThemes.instance.themeData.textTheme.bodyMedium?? const TextStyle(),
                      child: OrientationBuilder( /// detect orientation change and rotate screen
                          builder: (context, orientation) {
                            return Toaster(
                              child: const MyApp(),
                            );
                          }
                      ),
                    ),
                  ),
                ),
              );
            }
        )
    );
  }

  //runZonedGuarded(zone, zonedGuardedCatch);
  zoneFn();
}

Future<void> mainInitialize() async {
  PlatformDispatcher.instance.onError = mainIsolateError;
  FlutterError.onError = onErrorCatch;
  await FireBaseService.initializeApp();

  usePathUrlStrategy();

  if(System.isAndroid()) {
  }
}

Future<(bool, String?)> prepareDirectoriesAndLogger() async {
  try {
    if (!kIsWeb) {
      await AppDirectories.prepareStoragePaths(Constants.appName);
    }

    LogTools.init();

    return (true, null);
  }
  catch (e){
    return (false, '$e\n\n${StackTrace.current}');
  }
}
///==============================================================================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ///============ call on any hot reload
  @override
  Widget build(BuildContext context) {
    RouteTools.materialContext = context;

    if(kIsWeb && !isInitialOk){
      return WidgetsApp(
        debugShowCheckedModeBanner: false,
        color: Colors.transparent,
        builder: (ctx, home){
            return const SplashPage();
        },
      );
    }

    return MaterialApp(
      key: AppBroadcast.materialAppKey,
      navigatorKey: AppBroadcast.rootNavigatorKey,
      scaffoldMessengerKey: AppBroadcast.rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: Constants.appTitle,
      themeMode: AppThemes.instance.currentThemeMode,
      theme: AppThemes.instance.themeData,
      //darkTheme: ThemeData.dark(),
      onGenerateRoute: IrisNavigatorObserver.onGenerateRoute,
      navigatorObservers: [IrisNavigatorObserver.instance()],
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      locale: isInitialOk? SettingsManager.localSettings.appLocale : SettingsModel.defaultAppLocale,
      supportedLocales: AppLocale.getAssetSupportedLocales(),
      localizationsDelegates: AppLocale.getLocaleDelegates(), // this do correct Rtl/Ltr
      /*localeResolutionCallback: (deviceLocale, supportedLocales) {
            return SettingsManager.settingsModel.appLocale;
          },*/

      home: materialHomeBuilder(),
    );
  }

  Widget materialHomeBuilder(){
    return Builder(
      builder: (localContext){
        RouteTools.materialContext = localContext;
        testCodes(localContext);

        return MediaQuery(
            data: MediaQuery.of(localContext).copyWith(textScaleFactor: 1),
            child: const SplashPage()
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
  final String? errorLog;

  const MyErrorApp({Key? key, this.errorLog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.expand(
          child: ColoredBox(
              color: Colors.brown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error in app initialization'),
                Text(errorLog?? ''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
///==============================================================================================
void onErrorCatch(FlutterErrorDetails errorDetails) {
  var txt = 'AN ERROR HAS OCCURRED:: ${errorDetails.exception.toString()}';

  if(!kIsWeb) {
    txt += '\n STACK TRACE:: ${errorDetails.stack}';
  }

  txt += '\n**************************************** [END CATCH]';

  LogTools.logger.logToAll(txt);
}
///==============================================================================================
bool mainIsolateError(error, sTrace) {
  var txt = 'main-isolate CAUGHT AN ERROR:: ${error.toString()}';

  if(!kDebugMode/* && !kIsWeb*/) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n**************************************** [END MAIN-ISOLATE]';
  LogTools.logger.logToAll(txt);

  if(kDebugMode) {
    return false;
  }

  return true;
}
///==============================================================================================
void zonedGuardedCatch(error, sTrace) {
  var txt = 'ZONED-GUARDED CAUGHT AN ERROR:: ${error.toString()}';

  if(!kDebugMode/* && !kIsWeb*/) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n**************************************** [END ZONED-GUARDED]';
  LogTools.logger.logToAll(txt);

  if(kDebugMode) {
    throw error;
  }
}
