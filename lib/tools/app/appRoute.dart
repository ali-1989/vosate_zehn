import 'package:vosate_zehn/tools/app/appDb.dart';
import 'package:flutter/material.dart';
import 'package:iris_db/iris_db.dart';

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

  static Future<bool> saveRouteName(String name) async {
    final val = <dynamic, dynamic>{};
    val[Keys.name] = 'LastScreenName';
    val[Keys.value] = name;

    final dynamic res = await AppDB.db.insertOrReplace(AppDB.tbKv, val,
        Conditions()..add(Condition()..key = Keys.name..value = 'LastScreenName'));

    return res != null;
  }

  static String? fetchRouteScreenName() {
    final res = AppDB.db.query(AppDB.tbKv,
        Conditions()..add(Condition()..key = Keys.name..value = 'LastScreenName'));

    if(res.isEmpty) {
      return null;
    }

    final Map m = res.firstWhere((map) => map.containsValue('LastScreenName'));
    return m[Keys.value];
  }

  static void backRoute() {
    final mustLastCtx = AppNavigator.getLastRouteContext(getContext());
    AppNavigator.backRoute(mustLastCtx);
  }

  static void reCallPage(BuildContext ctx, Widget page, {required String name, dynamic arguments}) {
    //ModalRoute before = AppNavigator.getPreviousPage(ctx);
    final current = AppNavigator.getModalRouteOf(ctx);
    AppNavigator.popRoutesUntil(ctx, current);
    AppNavigator.replaceCurrentRoute(ctx, page, name: name, data: arguments);
  }
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
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero,).animate(animation),
          child: child,
        );
      });
}
