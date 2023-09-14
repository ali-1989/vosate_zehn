// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'package:app/tools/app/app_themes.dart';

class AppToast {
  AppToast._();

  static void showToast(BuildContext context, String msg, {Duration duration = const Duration(milliseconds: 3500)}){
    Widget toast = Material(
      color: Colors.transparent,
      child: Card(
        color: Color(0xff303030),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:12.0, vertical: 20),
          child: Text(msg, style: TextStyle(color: Colors.white)),
        ),
      )
    );

    Toaster.showToast(toast);
    Future.delayed(duration, () => Toaster.showToast(null));
  }
}
///=========================================================================================================
class Toaster extends StatefulWidget {
  final Widget child;
  static late ToasterState _state;

  Toaster({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ToasterState();
  }

  static void showToast(Widget? toast){
    _state.showToast(toast);
  }
}
///=========================================================================================================
class ToasterState extends State<Toaster> {
  Widget? toast;

  @override
  Widget build(BuildContext context) {
    Toaster._state = this;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        widget.child,

        Directionality(
          textDirection: AppThemes.instance.textDirection,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Visibility(
              visible: toast != null,
                child: toast?? SizedBox()
            ),
          ),
        ),
      ],
    );
  }

  void showToast(Widget? toastWidget){
    toast = toastWidget;

    setState(() {});
  }
}
