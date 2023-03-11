import 'package:flutter/material.dart';

import 'package:app/pages/about_us_page.dart';
import 'package:app/pages/aid_page.dart';
import 'package:app/pages/contact_us_page.dart';
import 'package:app/pages/e404_page.dart';
import 'package:app/pages/favorites_page.dart';
import 'package:app/pages/image_full_screen.dart';
import 'package:app/pages/last_seen_page.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/pages/levels/audio_player_page.dart';
import 'package:app/pages/levels/bucket_page.dart';
import 'package:app/pages/levels/content_view_page.dart';
import 'package:app/pages/levels/sub_bucket_page.dart';
import 'package:app/pages/levels/video_player_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/login/register_page.dart';
import 'package:app/pages/pay_web_page.dart';
import 'package:app/pages/profile/profile_page.dart';
import 'package:app/pages/term_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appNavigator.dart';

import 'package:app/tools/app/appRouteNoneWeb.dart'
 if (dart.library.html) 'package:app/tools/app/appRouteWeb.dart' as web;

class AppRoute {
  static BuildContext? materialContext;
  static bool _isInit = false;

  static final Map<Type, String?> webRoutes = {};

  AppRoute._();

  static void init() {
    if(_isInit){
      return;
    }

    webRoutes[ProfilePage] = null;
    webRoutes[LoginPage] = null;
    webRoutes[LayoutPage] = null;
    webRoutes[RegisterPage] = null;
    webRoutes[AudioPlayerPage] = null;
    webRoutes[SubBucketPage] = null;
    webRoutes[BucketPage] = null;
    webRoutes[ContentViewPage] = null;
    webRoutes[VideoPlayerPage] = null;
    webRoutes[AboutUsPage] = null;
    webRoutes[AidPage] = null;
    webRoutes[ContactUsPage] = null;
    webRoutes[E404Page] = null;
    webRoutes[FavoritesPage] = null;
    webRoutes[ImageFullScreen] = null;
    webRoutes[LastSeenPage] = null;
    webRoutes[PayWebPage] = null;
    webRoutes[TermPage] = null;

    _isInit = true;
  }

  static BuildContext? getLastContext() {
    var res = WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;//deep: 50,66

    Navigator? nav1 = res?.findAncestorWidgetOfExactType();

    if(res == null || nav1 == null) {
      //res = WidgetsBinding.instance.focusManager.primaryFocus?.context; //deep: 71
      res = WidgetsBinding.instance.focusManager.rootScope.context;
    }

    return res?? getBaseContext();
  }

  static BuildContext? getBaseContext() {
    return materialContext;
  }

  static Future<bool> saveRouteName(String routeName) async {
    final int res = await AppDB.setReplaceKv(Keys.setting$lastRouteName, routeName);

    return res > 0;
  }

  static String? fetchLastRouteName() {
    return AppDB.fetchKv(Keys.setting$lastRouteName);
  }
  ///------------------------------------------------------------
  static void backRoute() {
    final lastCtx = AppNavigator.getLastRouteContext(getLastContext()!);
    AppNavigator.backRoute(lastCtx);
  }

  static void backToRoot(BuildContext context) {
    //AppNavigator.popRoutesUntilRoot(AppRoute.getContext());

    while(canPop(context)){
      popTopView(context: context);
    }
  }

  static bool canPop(BuildContext context) {
    return AppNavigator.canPop(context);
  }

  static void popTopView({BuildContext? context, dynamic data}) {
    if(canPop(context?? getLastContext()!)) {
      AppNavigator.pop(context?? getLastContext()!, result: data);
    }
  }

  static void popPage(BuildContext context, {dynamic data}) {
    if(canPop(context)) {
      AppNavigator.pop(context, result: data);
    }
  }

  /*static void pushNamed(BuildContext context, String name, {dynamic extra}) {
    Navigator.of(context).pushNamed(name, arguments: extra);
    ///updateAddressBar(url);
  }

  static void replaceNamed(BuildContext context, String name, {dynamic extra}) {
    Navigator.of(context).pushReplacementNamed(name, arguments: extra);
    ///updateAddressBar(url);
  }*/

  /// note: Navigator.of()... not change url automatic in browser. if use [MaterialApp.router]
  /// and can not effect on back/pre buttons in browser
  static Future pushPage(BuildContext context, Widget page, {dynamic args, String? name}) async {
    final n = name?? (page).toString();

    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: n, arguments: args)
    );

    web.changeAddressBar(n);
    return Navigator.of(context).push(r);
  }

  static Future pushReplacePage(BuildContext context, Widget page, {dynamic args, String? name}) {
    final n = name?? (page).toString();

    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: n, arguments: args)
    );

    web.changeAddressBar(n);
    return Navigator.of(context).pushReplacement(r);
  }
}
