import 'package:flutter/material.dart';

class AppPageRoute extends PageRouteBuilder {
  final Widget widget;
  final String? routeName;

  AppPageRoute({
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
