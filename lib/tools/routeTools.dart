import 'package:flutter/material.dart';

import 'package:iris_route/iris_route.dart';

import 'package:app/pages/about_us_page.dart';
import 'package:app/pages/aid_page.dart';
import 'package:app/pages/contact_us_page.dart';
import 'package:app/pages/e404_page.dart';
import 'package:app/pages/favorites_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/last_seen_page.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/profile/profile_page.dart';
import 'package:app/pages/term_page.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:iris_tools/api/stackList.dart';

class RouteTools {
  static BuildContext? materialContext;
  static final StackList<State> widgetStateStack = StackList();

  RouteTools._();

  static prepareRoutes(){
    final aboutPage = IrisPageRoute.by((ProfilePage).toString(), ProfilePage());
    final homePage = IrisPageRoute.by((HomePage).toString(), HomePage());
    final supportPage = IrisPageRoute.by((LoginPage).toString(), LoginPage());
    final walletPage = IrisPageRoute.by((LayoutPage).toString(), const LayoutPage());
    final aboutUsPage = IrisPageRoute.by((AboutUsPage).toString(), const AboutUsPage());
    final aidPage = IrisPageRoute.by((AidPage).toString(), const AidPage());
    final contactUsPage = IrisPageRoute.by((ContactUsPage).toString(), const ContactUsPage());
    final favoritesPage = IrisPageRoute.by((FavoritesPage).toString(), const FavoritesPage());
    final lastSeenPage = IrisPageRoute.by((LastSeenPage).toString(), const LastSeenPage());
    //final payWebPage = IrisPageRoute.by((PayWebPage).toString(), PayWebPage());
    final termPage = IrisPageRoute.by((TermPage).toString(), const TermPage());
    final e404Page = IrisPageRoute.by((E404Page).toString(), const E404Page());
    //final imageFullScreen = IrisPageRoute.by((ImageFullScreen).toString(), ImageFullScreen());
    //final videoPlayerPage = IrisPageRoute.by((VideoPlayerPage).toString(), VideoPlayerPage());
    //final contentViewPage = IrisPageRoute.by((ContentViewPage).toString(), ContentViewPage());
    //final bucketPage = IrisPageRoute.by((BucketPage).toString(), BucketPage());
    //final subBucketPage = IrisPageRoute.by((SubBucketPage).toString(), SubBucketPage());
    //final registerPage = IrisPageRoute.by((RegisterPage).toString(), RegisterPage());
    //final audioPlayerPage = IrisPageRoute.by((AudioPlayerPage).toString(), AudioPlayerPage());

    //final registerFormPage = IrisPageRoute.by((RegisterFormPage).toString(), RegisterFormPage());
    //final profilePage = IrisPageRoute.by((ProfilePage).toString(), ProfilePage());

    IrisNavigatorObserver.notFoundHandler = (settings) => null;
    IrisNavigatorObserver.allAppRoutes.add(aboutPage);
    IrisNavigatorObserver.allAppRoutes.add(homePage);
    IrisNavigatorObserver.allAppRoutes.add(supportPage);
    IrisNavigatorObserver.allAppRoutes.add(walletPage);
    IrisNavigatorObserver.allAppRoutes.add(aboutUsPage);
    IrisNavigatorObserver.allAppRoutes.add(aidPage);
    IrisNavigatorObserver.allAppRoutes.add(contactUsPage);
    IrisNavigatorObserver.allAppRoutes.add(favoritesPage);
    IrisNavigatorObserver.allAppRoutes.add(lastSeenPage);
    IrisNavigatorObserver.allAppRoutes.add(termPage);
    IrisNavigatorObserver.allAppRoutes.add(e404Page);
    //IrisNavigatorObserver.allAppRoutes.add(registerPage);
    //IrisNavigatorObserver.allAppRoutes.add(audioPlayerPage);

    IrisNavigatorObserver.homeName = homePage.routeName;
  }

  static void addWidgetState(State state){
    return widgetStateStack.push(state);
  }

  static State removeWidgetState(){
    return widgetStateStack.pop();
  }

  static State getTopWidgetState(){
    return widgetStateStack.top();
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
