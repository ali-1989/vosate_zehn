import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:lottie/lottie.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appOverlay.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';

class AppLoading {
  AppLoading._();

  static late AppLoading _instance;
  static bool _isInit = false;

  static AppLoading get instance {
    if(!_isInit){
      _isInit = true;
      _init();

      _instance = AppLoading._();
    }

    return _instance;
  }

  static void _init(){
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 3500)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.grey
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.3)
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  Future<void> showWaiting({bool dismiss = false}){
    return EasyLoading.show(
        status: AppMessages.pleaseWait,
        dismissOnTap: dismiss,
      maskType: EasyLoadingMaskType.custom,
    );
  }

  Future<void> showError(String msg, {bool dismiss = true, Duration duration = const Duration(milliseconds: 3500)}){
    return EasyLoading.showError(
      msg,
      duration: duration,
      dismissOnTap: dismiss,
      maskType: EasyLoadingMaskType.none,
    );
  }

  Future<void> showSuccess(String msg, {bool dismiss = true, Duration duration = const Duration(milliseconds: 3500)}){
    return EasyLoading.showSuccess(
      msg,
      duration: duration,
      dismissOnTap: dismiss,
      maskType: EasyLoadingMaskType.none,
    );
  }

  Future<void> showProgress(String msg, double progress){
    return EasyLoading.showProgress(
      progress,
      status: msg,
      maskType: EasyLoadingMaskType.custom,
    );
  }

  Future<void> cancel({bool byAnimation = true}){
    return EasyLoading.dismiss(animation: byAnimation);
  }
  ///-----------------------------------------------------------------------------------
  Future<void> showLoading(BuildContext context, {bool dismiss = false}) async {
     EasyLoading.show(
      status: AppMessages.pleaseWait,
      dismissOnTap: dismiss,
      indicator: _getLoadingView(),
      maskType: EasyLoadingMaskType.custom,
    );

     if(!dismiss) {
       AppOverlay.showIgnoreScreen(context /*AppRoute.getContext()*/);
     }
  }

  Future<void> hideLoading(BuildContext context, {bool byAnimation = true}){
    AppOverlay.hideIgnoreScreen(context);
    return EasyLoading.dismiss(animation: byAnimation);
  }

  Future<void> showWaitingIgnore(BuildContext context) async {
    EasyLoading.show(
      status: AppMessages.pleaseWait,
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.custom,
    );

    AppOverlay.showIgnoreScreen(context);
  }

  Future<void> hideWaitingIgnore(BuildContext context, {bool byAnimation = true}){
    AppOverlay.hideIgnoreScreen(context);
    return EasyLoading.dismiss(animation: byAnimation);
  }

  Widget _getLoadingView(){
    var lottieColor = AppThemes.instance.currentTheme.primaryColor;

    if(ColorHelper.isNearColor(lottieColor, Colors.white)) {
      lottieColor = Colors.black;
    } else if(ColorHelper.isNearColor(lottieColor, Colors.black)) {
      lottieColor = Colors.white;
    }

    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
        child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Color(0x10000000),
                  Color(0x30000000),
                  Color(0x60000000),
                ],
                stops: [0.0, 0.4, 0.8, 1.0],
                tileMode: TileMode.clamp,
                radius: 0.9,
              ),
            ),
            child: Center(
              child: Lottie.asset(
                AppImages.loadingLottie,
                width: 200,
                height: 200,
                reverse: false,
                animate: true,
                fit: BoxFit.fill,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.strokeColor(
                      ['heartStroke', '**'],
                      value: lottieColor,
                    ),
                    ValueDelegate.color(
                      ['heartFill', 'Group 1', '**'],
                      value: lottieColor,
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}