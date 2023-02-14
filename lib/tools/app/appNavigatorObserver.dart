import 'package:flutter/material.dart';
import 'package:app/tools/app/appRouteNoneWeb.dart'
if (dart.library.html) 'package:app/tools/app/appRouteWeb.dart' as web;

class AppNavigatorObserver with NavigatorObserver /*or RouteObserver*/{
  static final AppNavigatorObserver _instance = AppNavigatorObserver._();

  AppNavigatorObserver._();

  static AppNavigatorObserver instance(){
    return _instance;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    web.clearAddressBar(route.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
   super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  static Route? onUnknownRoute(RouteSettings settings) {
    print('HHHHHHHHHHHHHHHHHH onUnknownRoute');
    return null;
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    print('HHHHHHHHHHHHHHHHHH onGenerateRoute');
    return null;
  }

  static bool onPopPage(Route<dynamic> route, result) {
    print('HHHHHHHHHHHHHHHHHH: $route');
    print('HHHHHHHHHHHHHHHHHH: $result');
    return route.didPop(result);
  }
}