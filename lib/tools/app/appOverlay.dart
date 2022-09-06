import 'package:flutter/material.dart';

import 'package:iris_tools/features/overlayDialog.dart';
import 'package:popover/popover.dart';

import 'package:app/tools/app/appSizes.dart';

class AppOverlay {

  AppOverlay._();

  static final _ignoreScreen = OverlayScreenView(
    content: const IgnorePointer(
      ignoring: true,
      child: SizedBox.expand(),
    ),
  );

  static Future showScreen(BuildContext context, OverlayScreenView view, {bool canBack = false}){
    OverlayScreenView v = view;

    if(AppSizes.isBigWidth()){
      v = OverlayScreenView(
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.getWebPadding()),
          child: view.content,
        ),
        backgroundColor: view.backgroundColor,
        routingName: view.routeName,
        scrollable: view.scrollable,
      );
    }

    return OverlayDialog().show(context, v, canBack: canBack);
  }

  static void hideScreen(BuildContext context){
    //OverlayDialog().hide(context);
    Navigator.of(context).pop();
  }

  static void hideScreenByOverlay(BuildContext context, OverlayScreenView overlay){
    OverlayDialog().hideByOverlay(context, overlay);
  }
  ///-------------------------------------------------------------------
  static Future showIgnoreScreen(BuildContext context){
    return showScreen(context, _ignoreScreen, canBack: false);
  }

  static void hideIgnoreScreen(BuildContext context){
    hideScreenByOverlay(context, _ignoreScreen);
  }
  ///-------------------------------------------------------------------
  static Offset findPosition(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }

  static void showOverlay(BuildContext context, OverlayEntry view){
    Overlay.of(context)?.insert(view);
  }// LayerLink()

  /// must wrap widget with Builder() to get anchorContext
  static Future<T?> showTooltip<T>(BuildContext anchorContext, Widget view, {
    VoidCallback? onPop,
    double arrowHeight = 15,
    double arrowWidth = 25,
    double? width,
    double? height,
  }){
    return showPopover<T>(
      context: anchorContext,
      transitionDuration: const Duration(milliseconds: 200),
      bodyBuilder: (context) => view,
      onPop: onPop,
      barrierDismissible: true,
      direction: PopoverDirection.bottom,
      width: width,
      height: height,
      arrowHeight: arrowHeight,
      arrowWidth: arrowWidth,
    );
  }
}


///*** Sample ************************************************************
/**
final pos = AppOverlay.findPosition(ctx);

final t = OverlayEntry(
  builder: (ctx){
    return Positioned(
      top: pos.dy,
      left: pos.dx,
      child: ...);
    }
);

AppOverlay.showOverlay(ctx, t);
  --------------------------------------------------------------------------
 */
