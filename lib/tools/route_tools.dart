import 'package:app/views/pages/home_page.dart';
import 'package:flutter/material.dart';


import 'package:app/tools/app/app_navigator.dart';
import 'package:one_route/one_navigator.dart';

class RouteTools {
  static BuildContext? materialContext;
  static final List<State> widgetStateStack = [];
  static final oneNavigator = OneNavigator();

  static late OneRoutePage homePage;

  RouteTools._();

  static prepareRoutes(){
    oneNavigator.debugLog = false;
    oneNavigator.isRestrictName = false;
    oneNavigator.notFoundHandler = (settings) => null;

    homePage = OneRoutePage.by('home', _pageBuilder);
  }

  static Widget _pageBuilder(BuildContext ctx, String routeName){
    if(routeName == homePage.routeName){
      return const HomePage();
    }

    return const SizedBox();
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
    var res = WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;

    Navigator? nav1 = res?.findAncestorWidgetOfExactType();

    if(res == null || nav1 == null) {
      res = AppNavigator.getTopBuildContext();//WidgetsBinding.instance.focusManager.rootScope.context;
    }

    if(res != null && res.mounted){
      return res;
    }

    return getBaseContext();
  }

  static BuildContext? getBaseContext() {
    if(materialContext != null && materialContext!.mounted){
      return materialContext!;
    }

    return AppNavigator.getDeepBuildContext();
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
