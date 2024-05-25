import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/path/box_clipper.dart';

import 'package:app/managers/font_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/managers/splash_manager.dart';
import 'package:app/structures/models/settings_model.dart';
import 'package:app/system/constants.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_locale.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/empty_app.dart';
import 'package:app/views/baseComponents/route_dispatcher.dart';
import 'package:app/views/baseComponents/splash_page.dart';

class MyApp extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  MyApp({super.key});

  @override
  State createState() => _MyAppState();
}
///=============================================================================
class _MyAppState extends State<MyApp> {
  /* before ancestors:
  depth:
  == 7  MediaQuery
  == 6  _MediaQueryFromView
  == 5  _PipelineOwnerScope
  == 4  _ViewScope
  == 3  _RawView
  == 2  View
  == 1  [root]
   */
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white70,
      child: StreamBuilder<bool>(
          initialData: true,
          stream: AppBroadcast.viewUpdaterStream.stream,
          builder: (context, snapshot) {
            if(!SplashManager.isBaseInitialize){
              return EmptyApp();
            }

            var mData = MediaQuery.of(context);

            if(!System.isMobile()){
              mData = mData.copyWith(
                size: Size(AppSizes.descktopMaxWidthSize, AppSizes.getMediaQueryHeight(context)),
              );
            }

            /// this effect on [MediaQuery.of(), Overlay.of()]
            return MediaQuery(
              data: mData,
              child: MaxWidth(
                maxWidth: AppSizes.descktopMaxWidthSize,
                apply: !System.isMobile(),
                child: ClipRect(
                  clipper: BoxClipper(width: System.isMobile()? double.infinity: AppSizes.descktopMaxWidthSize),
                  child: Directionality(
                    textDirection: AppThemes.instance.textDirection,
                    child: DefaultTextHeightBehavior(
                      textHeightBehavior: AppThemes.instance.baseFont.textHeightBehavior?? const TextHeightBehavior(),
                      child: DefaultTextStyle(
                        style: AppThemes.instance.themeData.textTheme.bodySmall?? const TextStyle(),
                        /// detect orientation change and rotate screen
                        child: OrientationBuilder(
                            builder: (context, orientation) {
                              //isLand = orientation == Orientation.landscape;
                              return Toaster(
                                child: MaterialApp(
                                  key: AppBroadcast.materialAppKey,
                                  navigatorKey: AppBroadcast.rootNavigatorKey,
                                  scaffoldMessengerKey: AppBroadcast.rootScaffoldMessengerKey,
                                  debugShowCheckedModeBanner: false,
                                  title: Constants.appTitle,
                                  themeMode: AppThemes.instance.currentThemeMode,
                                  theme: AppThemes.instance.themeData,
                                  //darkTheme: ThemeData.dark(),
                                  onGenerateRoute: RouteTools.oneNavigator.generateRoute,
                                  navigatorObservers: [RouteTools.oneNavigator],
                                  scrollBehavior: ScrollConfiguration.of(context).copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.touch,
                                    },
                                  ),
                                  locale: SplashManager.mustWaitToLoadingSettings? SettingsModel.defaultAppLocale : SettingsManager.localSettings.appLocale,
                                  supportedLocales: AppLocale.getAssetSupportedLocales(), /// this do Rtl/Ltr
                                  localizationsDelegates: AppLocale.getLocaleDelegates(), /// this do Rtl/Ltr
                                  home: materialHomeBuilder(),
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Widget materialHomeBuilder(){
    double factor = PlatformDispatcher.instance.textScaleFactor.clamp(0.80, 1.5);

    return Builder(
        builder: (context) {
          if(factor > 1.0 && FontManager.instance.startFontSize != null){
            final themeFs = FontManager.instance.themeFontSizeOrRelative(context);

            while(factor > 1.0 && (themeFs * factor) > FontManager.instance.maximumAppFontSize){
              factor = factor - 0.09;
            }
          }

          return Directionality(
            /// this line override MaterialApp auto direction. if need auto direction, remove this.
            textDirection: AppThemes.instance.textDirection,
            child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(factor)),
                child: Builder(
                    builder: (localContext){
                      RouteTools.materialContext = localContext;

                      if (SplashManager.mustWaitInSplash()) {
                        SplashManager.initOnSplash(localContext);
                        return SplashPage();
                      }
                      else {
                        testCodes(localContext);
                        return RouteDispatcher.dispatch();
                      }
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
  }
}
