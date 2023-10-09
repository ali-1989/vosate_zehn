import 'package:flutter/material.dart';

import 'package:iris_tools/features/overlayDialog.dart';

class AppOverlay {

  AppOverlay._();

  static final _touchIgnoreScreen = OverlayScreenView(
    content: const IgnorePointer(
      ignoring: true,
      child: SizedBox.expand(),
    ),
  );

  static Future showDialogScreen(BuildContext context, OverlayScreenView view, {bool canBack = false}){
    OverlayScreenView v = view;

    /*if(AppSizes.isBigWidth()){
      v = OverlayScreenView(
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.getWebPadding()),
          child: view.content,
        ),
        backgroundColor: view.backgroundColor,
        routingName: view.routeName,
        scrollable: view.scrollable,
      );
    }*/

    return OverlayDialog().show(context, v, canBack: canBack);
  }

  static void hideDialog(BuildContext context){
    //OverlayDialog().hide(context);
    if(Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static void hideScreenByOverlay(BuildContext context, OverlayScreenView overlay){
    OverlayDialog().hideByOverlay(context, overlay);
  }
  ///-------------------------------------------------------------------
  static Future showIgnoreScreen(BuildContext context){
    return showDialogScreen(context, _touchIgnoreScreen, canBack: false);
  }

  static void hideIgnoreScreen(BuildContext context){
    hideScreenByOverlay(context, _touchIgnoreScreen);
  }
  ///-------------------------------------------------------------------
  static Offset findPosition(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }

  static void showOverlay(BuildContext context, OverlayEntry view){
    Overlay.of(context).insert(view);
  }// LayerLink()
}


///*** Sample ************************************************************
/**
final pos = AppOverlay.findPosition(child_context);

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
