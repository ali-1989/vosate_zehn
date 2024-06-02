import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/url_strategy.dart' as web_plugin;
import 'package:one_route/one_navigator.dart';

import 'package:app/tools/app/app_navigator.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/views/pages/home_page.dart';

class RouteTools {
  static BuildContext? materialContext;
  static final List<State> widgetStateStack = [];
  static final oneNavigator = OneNavigator();

  static late OneRoutePage homePage;

  RouteTools._();

  static prepareRoutes(){
    //activeMemoryAllocationsForPush();
    oneNavigator.debugLog = false;
    oneNavigator.isRestrictName = false;
    oneNavigator.notFoundHandler = (settings) => null;

    homePage = OneRoutePage.by('home', _pageViewBuilder);
  }

  static Widget _pageViewBuilder(BuildContext ctx, String routeName){
    if(routeName == homePage.routeName){
      return const HomePage();
    }

    return Material(
      child: Center(
        child: Text('### pageViewBuilder : $routeName'),
      ),
    );
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

  static String _correctName(String name){
    if(web_plugin.urlStrategy is web_plugin.PathUrlStrategy){
      if(!name.startsWith('/')){
        name = '/$name';
      }
    }
    else {
      if(name.startsWith('/')){
        name = name.substring(1);
      }
    }

    return name;
  }

  static void pushNamed(BuildContext context, String name, {dynamic args}) {
    Navigator.of(context).pushNamed(_correctName(name), arguments: args);
  }

  static void replaceNamed(BuildContext context, String name, {dynamic args}) {
    Navigator.of(context).pushReplacementNamed(_correctName(name), arguments: args);
  }

  /// note: Navigator.of()... not change url automatic in browser. if use [MaterialApp.router]
  /// and can not effect on back/pre buttons in browser
  static Future pushPage(BuildContext context, Widget page, {required String name, dynamic args}) async {
    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: _correctName(name), arguments: args)
    );

    return Navigator.of(context).push(r);
  }

  static Future pushReplacePage(BuildContext context, Widget page, {required String name, dynamic args}) {
    final r = MaterialPageRoute(
        builder: (ctx){return page;},
        settings: RouteSettings(name: _correctName(name), arguments: args)
    );

    return Navigator.of(context).pushReplacement(r);
  }

  static bool isMemoryAllocationsActive(){
    const bool kMemoryAllocations = bool.fromEnvironment('flutter.memory_allocations');
    return kMemoryAllocations || kDebugMode;
  }

  static void activeMemoryAllocationsForPush(){
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.addListener((event) {
        if (event is ObjectCreated && event.className.contains('Route')) {
          LogTools.logToScreen('>> Route Created ${event.object.toString()}');
        }
        /*else if (event is ObjectDisposed) {
          LogTools.logToScreen('>> ObjectDisposed');
        }
        else {
          LogTools.logToScreen('>> ${event.object}');
        }*/
      });
    }
    else {
      LogTools.logToScreen('>> >> >> FlutterMemoryAllocations is not Active. Run: --dart-define=flutter.memory_allocations=true');
    }
  }
}
