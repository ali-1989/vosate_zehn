import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';

import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/widgets/overlay/overlayContainer.dart';
import 'package:app/views/widgets/progressBarPrompt.dart';

class AppLoading {
  AppLoading._();

  static late AppLoading _instance;
  static bool _isInit = false;
  static late OverlayTheme _overlayTheme;

  static AppLoading get instance {
    if(!_isInit){
      _isInit = true;
      _init();

      _instance = AppLoading._();
    }

    return _instance;
  }

  static void _init(){
    _overlayTheme = OverlayTheme();
    _overlayTheme.defaultDisplayDuration = const Duration(milliseconds: 3500);
    _overlayTheme.defaultMaskColor = Colors.transparent;
  }

  Future<void> showWaiting(BuildContext context, {bool dismiss = false}){
    final easyView = OverlayContainer(
      overlayTheme: _overlayTheme,
      message: AppMessages.pleaseWait,
      maskType: OverlayMaskType.custom,
      indicator: SpinKitFadingCircle(
        color: _overlayTheme.defaultIndicatorColor,
        size: _overlayTheme.indicatorSize,
      ),
    );

    final over = OverlayScreenView(
      content: easyView,
      backgroundColor: Colors.black.withOpacity(0.3),
    );

    return AppOverlay.showDialogScreen(context, over, canBack: dismiss);
  }

  Future<void> showError(BuildContext context, String msg, {bool dismiss = true, Duration? duration}){
    final easyView = OverlayContainer(
      overlayTheme: _overlayTheme,
      message: msg,
      maskType: OverlayMaskType.none,
      indicator: _overlayTheme.defaultErrorWidget,
    );

    final over = OverlayScreenView(
      content: easyView,
    );

    Future.delayed(duration?? _overlayTheme.displayDuration, () => cancel(context));
    return AppOverlay.showDialogScreen(context, over, canBack: dismiss);
  }

  Future<void> showSuccess(BuildContext context, String msg, {bool dismiss = true, Duration? duration}){
    final easyView = OverlayContainer(
      overlayTheme: _overlayTheme,
      message: msg,
      maskType: OverlayMaskType.none,
      indicator: _overlayTheme.defaultSuccessWidget,
    );

    final over = OverlayScreenView(
      content: easyView,
    );

    Future.delayed(duration?? _overlayTheme.displayDuration, () => cancel(context));
    return AppOverlay.showDialogScreen(context, over, canBack: dismiss);
  }

  void cancel(BuildContext context){
    AppOverlay.hideDialog(context);
  }
  ///-----------------------------------------------------------------------------------
  Future<void> showLoading(BuildContext context, {bool dismiss = false}) async {
    final easyView = OverlayContainer(
      overlayTheme: _overlayTheme,
      message: AppMessages.pleaseWait,
      maskType: OverlayMaskType.custom,
      indicator: _getLoadingView(),
    );

    final over = OverlayScreenView(
      content: easyView,
    );

    return AppOverlay.showDialogScreen(context, over, canBack: dismiss);

     /*if(!dismiss) {
       AppOverlay.showIgnoreScreen(context *//*RouteTools.getContext()*//*);
     }*/
  }

  Future<void> hideLoading(BuildContext context) async {
    //AppOverlay.hideIgnoreScreen(context);
    AppOverlay.hideDialog(context);
  }
  //---------------------------------------------------------------------------------
  Future<void> showProgress(BuildContext context, Stream<double> stream, {
    String? message,
    String? buttonText,
    VoidCallback? buttonEvent,
  }){
    final over = OverlayScreenView(
      content: SizedBox.expand(
        child: Center(
          child: ProgressBarPrompt(
            stream: stream,
            message: message,
            buttonEvent: buttonEvent,
            buttonText: buttonText,
          ),
        ),
      ),
      backgroundColor: Colors.black26,
    );

    return AppOverlay.showDialogScreen(context, over, canBack: false);
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
            child: SizedBox()
        )
    );
  }
}
