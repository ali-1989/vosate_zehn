import 'package:flutter/widgets.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:popover/popover.dart';

class AppOverlay {
  AppOverlay._();

  static Future<T?> shoeTooltip<T>(BuildContext context, Widget view, {
    VoidCallback? onPop,
    double arrowHeight = 15,
    double arrowWidth = 30,
  }){
    return showPopover<T>(
      context: context,
      transitionDuration: const Duration(milliseconds: 150),
      bodyBuilder: (context) => view,
      onPop: onPop,
      direction: PopoverDirection.top,
      //width: 200,
      //height: 400,
      arrowHeight: arrowHeight,
      arrowWidth: arrowWidth,
    );
  }

  static Future showOverlay(BuildContext context, OverlayScreenView view){
    return OverlayDialog().show(context, view);
  }

}