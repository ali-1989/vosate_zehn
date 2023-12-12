import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/notifiers/extendValueNotifier.dart';

import 'package:app/tools/app/app_themes.dart';
import 'package:app/views/pages/layout_page.dart';

class AppBroadcast {
  AppBroadcast._();

  static final StreamController<bool> viewUpdaterStream = StreamController<bool>();
  static final ExtendValueNotifier<int> newAdvNotifier = ExtendValueNotifier<int>(0);
  static final ExtendValueNotifier<int> changeFavoriteNotifier = ExtendValueNotifier<int>(0);

  //---------------------- keys
  static const String drawerMenuRefresherId = 'drawerMenuRefresherId';
  static LocalKey materialAppKey = UniqueKey();
  static final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final layoutPageKey = GlobalKey<LayoutPageState>();

  //---------------------- status
  static bool isNetConnected = true;
  static bool isWsConnected = false;


  /// this call build() method of all widgets
  /// this is effect on First Widgets tree, not rebuild Pushed pages
  static void reBuildAppBySetTheme() {
    AppThemes.applyTheme(AppThemes.instance.currentTheme);
    reBuildApp();
  }

  static void reBuildApp() {
    if(kIsWeb){
      materialAppKey = UniqueKey();
    }

    viewUpdaterStream.sink.add(true);
  }
}
