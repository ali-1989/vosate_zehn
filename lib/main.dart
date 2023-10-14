import 'dart:async';

import 'package:app/tools/app/app_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/managers/font_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/managers/splash_manager.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/native_call_service.dart';
import 'package:app/structures/models/settings_model.dart';
import 'package:app/system/constants.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_locale.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/splash_page.dart';

///================ call on any hot restart
void main() {
  PlatformDispatcher.instance.onError = mainIsolateError;
  FlutterError.onError = onErrorCatch;

  void zoneFn() async {
    if (defaultTargetPlatform != TargetPlatform.linux && defaultTargetPlatform != TargetPlatform.windows) {
      WidgetsFlutterBinding.ensureInitialized();
    }

    final initOk = await prepareDirectoriesAndLogger();

    if(!initOk.$1){
      runApp(MyErrorApp(errorLog: initOk.$2));
      return;
    }

    await mainInitialize();

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
                      style: AppThemes.instance.themeData.textTheme.bodySmall?? const TextStyle(),
                      child: OrientationBuilder( /// detect orientation change and rotate screen
                          builder: (context, orientation) {
                            return Toaster(
                              child: MyApp(),
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

  runZonedGuarded(zoneFn, zonedGuardedCatch);
  //zoneFn();
}

Future<void> mainInitialize() async {
  await FireBaseService.initializeApp();

  usePathUrlStrategy();
}

@pragma('vm:entry-point')
void dartFunction() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareDirectoriesAndLogger();
  NativeCallService.init();
}

@pragma('vm:entry-point')
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
///=============================================================================
class MyApp extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  MyApp({Key? key}) : super(key: key);

  ///============ call on any hot reload
  @override
  Widget build(BuildContext context) {
    RouteTools.materialContext = context;

    if(kIsWeb && !SplashManager.isFullInitialOk){
      return WidgetsApp(
        debugShowCheckedModeBanner: false,
        color: Colors.transparent,
        builder: (ctx, home){
            return SplashPage();
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
      locale: SplashManager.isFullInitialOk? SettingsManager.localSettings.appLocale : SettingsModel.defaultAppLocale,
      supportedLocales: AppLocale.getAssetSupportedLocales(), /// this do Rtl/Ltr
      localizationsDelegates: AppLocale.getLocaleDelegates(), /// this do Rtl/Ltr
      home: materialHomeBuilder(),
    );
  }

  Widget materialHomeBuilder(){
    double factor = PlatformDispatcher.instance.textScaleFactor.clamp(0.80, 1.5);

    return Builder(
      builder: (context) {

        if(factor > 1.0 && FontManager.firstFontSize != null){
          final themeFs = FontManager.instance.getThemeFontSizeOrRelative(context);

          while(factor > 1.0 && (themeFs * factor) > FontManager.maxForFontSize){
            factor = factor - 0.09;
          }
        }

        return Directionality(
          /// this line override MaterialApp auto direction. if need auto direction, remove this.
          textDirection: AppThemes.instance.textDirection,
          child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: factor),
              child: Builder(
                  builder: (localContext){
                    RouteTools.materialContext = localContext;
                    testCodes(localContext);

                    return SplashPage();
                  }
              )
          ),
        );
      }
    );
  }

  Future<void> testCodes(BuildContext context) async {
    if(!AppCache.canCallMethodAgain('testCodes')){
      return;
    }

    //await AppDB.db.clearTable(AppDB.tbKv);
    //NativeCallService.assistanceBridge?.invokeMethodByArgs('throw_error', [{'delay': 5000}]);
  }
}
///=============================================================================
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
///=============================================================================
void onErrorCatch(FlutterErrorDetails errorDetails) {
  var txt = 'AN ERROR HAS OCCURRED:: ${errorDetails.exception.toString()}';

  if(!kIsWeb) {
    txt += '\n STACK TRACE:: ${errorDetails.stack}';
  }

  txt += '\n**************************************** [END CATCH]';

  LogTools.logger.logToAll(txt);

  final eMap = DeviceInfoTools.mapDeviceInfo();
  eMap['catcher'] = 'mainIsolateError';
  eMap['error'] = txt;

  LogTools.reportError(eMap);
}
///=============================================================================
bool mainIsolateError(error, sTrace) {
  var txt = 'main-isolate CAUGHT AN ERROR:: ${error.toString()}';

  if(!(kDebugMode || kIsWeb)) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n**************************************** [END MAIN-ISOLATE]';
  LogTools.logger.logToAll(txt);

  final eMap = DeviceInfoTools.mapDeviceInfo();
  eMap['catcher'] = 'mainIsolateError';
  eMap['error'] = txt;

  LogTools.reportError(eMap);

  if(kDebugMode) {
    return false;
  }

  return true;
}
///=============================================================================
void zonedGuardedCatch(error, sTrace) {
  var txt = 'ZONED-GUARDED CAUGHT AN ERROR:: ${error.toString()}';

  if(!(kDebugMode || kIsWeb)) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n**************************************** [END ZONED-GUARDED]';
  LogTools.logger.logToAll(txt);

  final eMap = DeviceInfoTools.mapDeviceInfo();
  eMap['catcher'] = 'zonedGuardedCatch';
  eMap['error'] = txt;

  LogTools.reportError(eMap);

  if(kDebugMode) {
    throw error;
  }
}
