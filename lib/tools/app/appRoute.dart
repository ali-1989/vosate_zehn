import 'package:go_router/go_router.dart';
import 'package:vosate_zehn/pages/e404_page.dart';
import 'package:vosate_zehn/pages/home_page.dart';
import 'package:vosate_zehn/pages/splash_page.dart';
import 'package:vosate_zehn/tools/app/appDb.dart';
import 'package:flutter/material.dart';
import 'package:vosate_zehn/tools/app/appDirectories.dart';

import '/system/keys.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';


class AppRoute {
  AppRoute._();

  static late BuildContext materialContext;

  static BuildContext getContext() {
    var res = AppManager.widgetsBinding.focusManager.rootScope.focusedChild?.context;//deep: 50
    res ??= AppManager.widgetsBinding.focusManager.primaryFocus?.context; //deep: 71

    return res?? materialContext;
  }

  static BuildContext getFirstContext() {
    return materialContext;
  }

  static Future<bool> saveRouteName(String routeName) async {
    final int res = await AppDB.setReplaceKv(Keys.setting$lastRouteName, routeName);

    return res > 0;
  }

  static String? fetchRouteScreenName() {
    return AppDB.fetchKv(Keys.setting$lastRouteName);
  }

  static void backRoute() {
    final mustLastCtx = AppNavigator.getLastRouteContext(getContext());
    AppNavigator.backRoute(mustLastCtx);
  }

  static void pop(BuildContext context) {
    GoRouter.of(context).pop();
  }

  static void push(BuildContext context, String location) {
    GoRouter.of(context).go(location);
  }

  static void pushNamed(BuildContext context, String name) {
    GoRouter.of(context).goNamed(name);
  }

  static void reCallPage(BuildContext ctx, Widget page, {required String name, dynamic arguments}) {
    //ModalRoute before = AppNavigator.getPreviousPage(ctx);
    final current = AppNavigator.getModalRouteOf(ctx);
    AppNavigator.popRoutesUntil(ctx, current);
    AppNavigator.replaceCurrentRoute(ctx, page, name: name, data: arguments);
  }
}
///============================================================================================
final routers = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: (HomePage).toString(),
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
      GoRoute(
          path: '/splash',
          name: (SplashPage).toString(),
          builder: (BuildContext context, GoRouterState state) => const SplashPage(),
      ),
    ],
    initialLocation: '/',
    errorBuilder: (BuildContext context, GoRouterState state) => const E404Page(),
    //refreshListenable: loginInfo, //GoRouterRefreshStream(streamController.stream),
    redirect: (GoRouterState state){
      if(state.location == '/'){ //state.subloc
        AppDirectories.generateNoMediaFile();
      }

      print('--redirect---> ${state.subloc}, ${state.subloc}');
      return null;
    }
);
///============================================================================================
class MyPageRoute extends PageRouteBuilder {
  final Widget widget;
  final String? routeName;

  MyPageRoute({
    required this.widget,
    this.routeName,
  })
      : super(
        settings: RouteSettings(name: routeName),
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return widget;
        },
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero,).animate(animation),
          child: child,
        );
      });
}
