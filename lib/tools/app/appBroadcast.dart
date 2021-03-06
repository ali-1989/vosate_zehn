import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';
import 'package:vosate_zehn/pages/splash_page.dart';

import '/tools/app/appThemes.dart';

class AppBroadcast {
  AppBroadcast._();

  static final StreamController<bool> materialUpdaterStream = StreamController<bool>();
  static final RefreshController drawerMenuRefresher = RefreshController();
  static final LocalKey materialAppKey = UniqueKey();
  static final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final rootNavigatorStateKey = GlobalKey<NavigatorState>();
  //static final homeScreenKey = GlobalKey<HomePageState>();

  //static final homePageBadges = <int, int>{};
  static bool isNetConnected = true;
  static bool isWsConnected = false;


  /// this call build() method of all widgets
  /// this is effect on First Widgets tree, not rebuild Pushed pages
  static void reBuildMaterialBySetTheme() {
    AppThemes.applyTheme(AppThemes.instance.currentTheme);
    reBuildMaterial();
  }

  static void reBuildMaterial() {
    materialUpdaterStream.sink.add(true);
  }

  static void gotoSplash(int waitingInSplash) {
    mustShowSplash = true;
    splashWaitingMil = waitingInSplash;
    reBuildMaterial();
  }
}
