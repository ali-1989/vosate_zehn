import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:vosate_zehn/pages/e404_page.dart';
import 'package:vosate_zehn/pages/home_page.dart';
import 'package:vosate_zehn/pages/login/login_page.dart';
import 'package:vosate_zehn/pages/login/register_page.dart';
import 'package:vosate_zehn/pages/termPage.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appDb.dart';
import 'package:flutter/material.dart';
import 'package:vosate_zehn/tools/app/appDirectories.dart';

import '/system/keys.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';


class AppRoute {
  static final List<GoRoute> freeRoutes = [];

  AppRoute._();

  static late BuildContext materialContext;

  static BuildContext getContext() {
    var res = AppManager.widgetsBinding.focusManager.rootScope.focusedChild?.context;//deep: 50
    res ??= AppManager.widgetsBinding.focusManager.primaryFocus?.context; //deep: 71

    return res?? materialContext;
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

  static void push(BuildContext context, String address, {dynamic extra}) {
    if(kIsWeb){
      GoRouter.of(context).go(address, extra: extra);
    }
    else {
      GoRouter.of(context).push(address, extra: extra);
    }
  }

  static void pushNamed(BuildContext context, String name, {dynamic extra}) {
    if(kIsWeb){
      GoRouter.of(context).goNamed(name, params: {}, extra: extra);
    }
    else {
      GoRouter.of(context).pushNamed(name, params: {}, extra: extra);
    }
  }

  static void reCallPage(BuildContext ctx, Widget page, {required String name, dynamic arguments}) {
    //ModalRoute before = AppNavigator.getPreviousPage(ctx);
    final current = AppNavigator.getModalRouteOf(ctx);
    AppNavigator.popRoutesUntil(ctx, current);
    AppNavigator.replaceCurrentRoute(ctx, page, name: name, data: arguments);
  }

  static void init(){
    freeRoutes.add(LoginPage.route);
    freeRoutes.add(RegisterPage.route);
    freeRoutes.add(TermPage.route);
  }
}
///============================================================================================
final mainRouter = GoRouter(
    routes: <GoRoute>[
      E404Page.route,
      HomePage.route,
      LoginPage.route,
      RegisterPage.route,
      TermPage.route,
    ],
    initialLocation: HomePage.route.path,
    errorBuilder: (BuildContext context, GoRouterState state) => const E404Page(),
    //refreshListenable: loginInfo, //GoRouterRefreshStream(streamController.stream),
    redirect: _mainRedirect,
);

String? _mainRedirect(GoRouterState state){
  debugPrint('--redirect---> ${state.subloc}         |  qp:${state.queryParams}');

  if(state.subloc == HomePage.route.path){
    AppDirectories.generateNoMediaFile();
  }

  if(!Session.hasAnyLogin()){
    if(AppRoute.freeRoutes.any((r) => r.path == state.subloc)){
      return state.queryParams['from_page'];
    }
    else {
      final from = state.subloc == '/' ? '' : '?from_page=${state.location}';
      return '${LoginPage.route.path}$from';
    }
  }

  return state.queryParams['from_page'];
}
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
        //ScaleTransition, RotationTransition, SizeTransition, FadeTransition
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero,).animate(animation),
          child: child,
        );
      });
}
