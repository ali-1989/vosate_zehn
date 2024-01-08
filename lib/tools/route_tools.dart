import 'package:flutter/material.dart';

import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/api/stack_list.dart';

import 'package:app/tools/app/app_navigator.dart';
import 'package:app/views/pages/about_us_page.dart';
import 'package:app/views/pages/aid_page.dart';
import 'package:app/views/pages/contact_us_page.dart';
import 'package:app/views/pages/e404_page.dart';
import 'package:app/views/pages/favorites_page.dart';
import 'package:app/views/pages/home_page.dart';
import 'package:app/views/pages/last_seen_page.dart';
import 'package:app/views/pages/layout_page.dart';
import 'package:app/views/pages/login/login_page.dart';
import 'package:app/views/pages/profile/profile_page.dart';
import 'package:app/views/pages/term_page.dart';

class RouteTools {
  static BuildContext? materialContext;
  //static final StackList<State> widgetStateStack = StackList();
  static final List<State> widgetStateStack = [];

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
    final termPage = IrisPageRoute.by((TermPage).toString(), const TermPage());
    final e404Page = IrisPageRoute.by((E404Page).toString(), const E404Page());
    
    IrisNavigatorObserver.notFoundHandler = (settings) => null;
    IrisNavigatorObserver.homeName = homePage.routeName;

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
  }

  static void addWidgetState(State state){
    return widgetStateStack.add(state);
  }

  static void removeWidgetState(State state){
    widgetStateStack.remove(state);
  }

  static State getTopWidgetState(){
    return widgetStateStack.last;
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

  static void popIfCan(BuildContext context) {
    if(canPop(context)){
      popTopView(context: context);
    }
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
    String n = name?? (page).toString();

    if(!n.startsWith('/')){
      n = '/$n';
    }

    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: n, arguments: args)
    );

    return Navigator.of(context).push(r);
  }

  static Future pushReplacePage(BuildContext context, Widget page, {dynamic args, String? name}) {
    String n = name?? (page).toString();

    if(!n.startsWith('/')){
      n = '/$n';
    }

    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: n, arguments: args)
    );

    return Navigator.of(context).pushReplacement(r);
  }
}
