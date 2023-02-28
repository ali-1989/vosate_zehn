import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/notifiers/extendValueNotifier.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';

import 'package:app/pages/layout_page.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/homeComponents/splashPage.dart';

class AppBroadcast {
  AppBroadcast._();

  static final StreamController<bool> viewUpdaterStream = StreamController<bool>();
  static final RefreshController drawerMenuRefresher = RefreshController();
  static final ExtendValueNotifier<int> newAdvNotifier = ExtendValueNotifier<int>(0);
  static final ExtendValueNotifier<int> changeFavoriteNotifier = ExtendValueNotifier<int>(0);
  //---------------------- keys
  static LocalKey materialAppKey = UniqueKey();
  static final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final layoutPageKey = GlobalKey<LayoutPageState>();

  //---------------------- status
  static bool isNetConnected = true;
  static bool isWsConnected = false;


  /// this call build() method of all widgets
  /// this is effect on First Widgets tree, not rebuild Pushed pages
  static void reBuildMaterialBySetTheme() {
    AppThemes.applyTheme(AppThemes.instance.currentTheme);
    reBuildMaterial();
  }

  static void reBuildMaterial() {
    if(kIsWeb){
      materialAppKey = UniqueKey();
    }

    viewUpdaterStream.sink.add(true);
  }

  static void gotoSplash(int waitingInSplashMil) {
    isInSplashTimer = true;
    splashWaitingMil = waitingInSplashMil;
    reBuildMaterial();
  }
}
