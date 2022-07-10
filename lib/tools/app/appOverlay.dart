import 'package:flutter/widgets.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:popover/popover.dart';

class AppOverlay {
  static final _ignoreScreen = OverlayScreenView(
    content: const IgnorePointer(
      ignoring: true,
      child: SizedBox.expand(),
    ),
  );

  AppOverlay._();

  static Future showScreen(BuildContext context, OverlayScreenView view){
    return OverlayDialog().show(context, view);
  }

  static void hideScreen(BuildContext context){
    OverlayDialog().hide(context);
  }

  static Future showIgnoreScreen(BuildContext context){
    return OverlayDialog().show(context, _ignoreScreen);
  }

  static void hideIgnoreScreen(BuildContext context){
    OverlayDialog().hideByOverlay(context, _ignoreScreen);
  }

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