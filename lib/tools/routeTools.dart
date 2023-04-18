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
import 'package:app/pages/home_page.dart';
import 'package:app/pages/term_page.dart';
import 'package:flutter/material.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:iris_route/iris_route.dart';

class RouteTools {
  static BuildContext? materialContext;

  RouteTools._();

  static prepareWebRoute(){
    final aboutPage = WebRoute.by((ProfilePage).toString(), ProfilePage());
    final homePage = WebRoute.by((HomePage).toString(), HomePage());
    final supportPage = WebRoute.by((LoginPage).toString(), LoginPage());
    final walletPage = WebRoute.by((LayoutPage).toString(), LayoutPage());
    final aboutUsPage = WebRoute.by((AboutUsPage).toString(), AboutUsPage());
    final aidPage = WebRoute.by((AidPage).toString(), AidPage());
    final contactUsPage = WebRoute.by((ContactUsPage).toString(), ContactUsPage());
    final favoritesPage = WebRoute.by((FavoritesPage).toString(), FavoritesPage());
    final lastSeenPage = WebRoute.by((LastSeenPage).toString(), LastSeenPage());
    //final payWebPage = WebRoute.by((PayWebPage).toString(), PayWebPage());
    final termPage = WebRoute.by((TermPage).toString(), TermPage());
    final e404Page = WebRoute.by((E404Page).toString(), E404Page());
    //final imageFullScreen = WebRoute.by((ImageFullScreen).toString(), ImageFullScreen());
    //final videoPlayerPage = WebRoute.by((VideoPlayerPage).toString(), VideoPlayerPage());
    //final contentViewPage = WebRoute.by((ContentViewPage).toString(), ContentViewPage());
    //final bucketPage = WebRoute.by((BucketPage).toString(), BucketPage());
    //final subBucketPage = WebRoute.by((SubBucketPage).toString(), SubBucketPage());
    //final registerPage = WebRoute.by((RegisterPage).toString(), RegisterPage());
    //final audioPlayerPage = WebRoute.by((AudioPlayerPage).toString(), AudioPlayerPage());

    //final registerFormPage = WebRoute.by((RegisterFormPage).toString(), RegisterFormPage());
    //final profilePage = WebRoute.by((ProfilePage).toString(), ProfilePage());

    IrisNavigatorObserver.webRoutes.add(aboutPage);
    IrisNavigatorObserver.webRoutes.add(homePage);
    IrisNavigatorObserver.webRoutes.add(supportPage);
    IrisNavigatorObserver.webRoutes.add(walletPage);
    IrisNavigatorObserver.webRoutes.add(aboutUsPage);
    IrisNavigatorObserver.webRoutes.add(aidPage);
    IrisNavigatorObserver.webRoutes.add(contactUsPage);
    IrisNavigatorObserver.webRoutes.add(favoritesPage);
    IrisNavigatorObserver.webRoutes.add(lastSeenPage);
    IrisNavigatorObserver.webRoutes.add(termPage);
    IrisNavigatorObserver.webRoutes.add(e404Page);
    //IrisNavigatorObserver.webRoutes.add(registerPage);
    //IrisNavigatorObserver.webRoutes.add(audioPlayerPage);

    IrisNavigatorObserver.homeName = homePage.routeName;
  }

  static BuildContext? getTopContext() {
    var res = WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;//deep: 50,66

    Navigator? nav1 = res?.findAncestorWidgetOfExactType();

    if(res == null || nav1 == null) {
      res = AppNavigator.getTopBuildContext();//WidgetsBinding.instance.focusManager.rootScope.context;
    }

    return res?? getBaseContext();
  }

  static BuildContext? getBaseContext() {
    return materialContext?? AppNavigator.getDeepBuildContext();
  }

  /*static Future<bool> saveRouteName(String routeName) async {
    final int res = await AppDB.setReplaceKv(Keys.setting$lastRouteName, routeName);

    return res > 0;
  }

  static String? fetchLastRouteName() {
    return AppDB.fetchKv(Keys.setting$lastRouteName);
  }*/
  ///------------------------------------------------------------
  static void backRoute() {
    final lastCtx = getTopContext()!;
    AppNavigator.backRoute(lastCtx);
  }

  static void backToRoot(BuildContext context) {
    while(canPop(context)){
      popTopView(context: context);
    }
  }

  static bool canPop(BuildContext context) {
    return AppNavigator.canPop(context);
  }

  /// popPage
  static void popTopView({BuildContext? context, dynamic data}) {
    if(canPop(context?? getTopContext()!)) {
      AppNavigator.pop(context?? getTopContext()!, result: data);
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

    return Navigator.of(context).push(r);
  }

  static Future pushReplacePage(BuildContext context, Widget page, {dynamic args, String? name}) {
    final n = name?? (page).toString();

    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: n, arguments: args)
    );

    return Navigator.of(context).pushReplacement(r);
  }
}
