import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/native_call_service.dart';
import 'package:app/structures/models/settingsModel.dart';
import 'package:app/system/applicationInitialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/homeComponents/splashPage.dart';

///================ call on any hot restart
Future<void> main() async {
  if (defaultTargetPlatform != TargetPlatform.linux && defaultTargetPlatform != TargetPlatform.windows) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  final initOk = await ApplicationInitial.prepareDirectoriesAndLogger();

  if(!initOk){
    runApp(const MyErrorApp());
    return;
  }

  await mainInitialize();

  zone() {
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
                    textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                    child: DefaultTextStyle(
                      style: AppThemes.instance.themeData.textTheme.bodyMedium?? TextStyle(),
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

  //runZonedGuarded(zone, zonedGuardedCatch);
  zone();
}

Future<void> mainInitialize() async {
  //SchedulerBinding.instance.ensureVisualUpdate();
  //SchedulerBinding.instance.window.scheduleFrame();
  PlatformDispatcher.instance.onError = mainIsolateError;
  FlutterError.onError = onErrorCatch;
  await FireBaseService.initializeApp();

  usePathUrlStrategy();

  if(System.isAndroid()) {
    NativeCallService.init();
    await NativeCallService.invokeMethod('setAppIsRun');
  }
}
///==============================================================================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ///============ call on any hot reload
  @override
  Widget build(BuildContext context) {
    RouteTools.materialContext = context;

    if(kIsWeb && !ApplicationInitial.isInit()){
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
      locale: ApplicationInitial.isInit()? SettingsManager.settingsModel.appLocale : SettingsModel.defaultAppLocale,
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
            child: SplashPage()
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
    return Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.expand(
          child: ColoredBox(
              color: Colors.brown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error in app initialization'),
                Text(ApplicationInitial.errorInInit),
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

  PublicAccess.logger.logToAll(txt);
}
///==============================================================================================
bool mainIsolateError(error, sTrace) {
  var txt = 'main-isolate CAUGHT AN ERROR:: ${error.toString()}';

  if(!kDebugMode/* && !kIsWeb*/) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n**************************************** [END MAIN-ISOLATE]';
  PublicAccess.logger.logToAll(txt);

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
  PublicAccess.logger.logToAll(txt);

  if(kDebugMode) {
    throw error;
  }
}
