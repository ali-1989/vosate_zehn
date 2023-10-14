import 'package:flutter/material.dart';

abstract class OverlayAnimation {
  OverlayAnimation();

  Widget call(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      ) {
    return buildWidget(
      child,
      controller,
      alignment,
    );
  }

  Widget buildWidget(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      );
}
///=============================================================================
class OffsetAnimation extends OverlayAnimation {
  OffsetAnimation();

  @override
  Widget buildWidget(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      ) {
    Offset begin = alignment == AlignmentDirectional.topCenter
        ? const Offset(0, -1)
        : alignment == AlignmentDirectional.bottomCenter
        ? const Offset(0, 1)
        : const Offset(0, 0);
    Animation<Offset> animation = Tween(
      begin: begin,
      end: const Offset(0, 0),
    ).animate(controller);
    return Opacity(
      opacity: controller.value,
      child: SlideTransition(
        position: animation,
        child: child,
      ),
    );
  }
}
///=============================================================================
class OpacityAnimation extends OverlayAnimation {
  OpacityAnimation();

  @override
  Widget buildWidget(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      ) {
    return Opacity(
      opacity: controller.value,
      child: child,
    );
  }
}
///=============================================================================
class ScaleAnimation extends OverlayAnimation {
  ScaleAnimation();

  @override
  Widget buildWidget(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      ) {
    return Opacity(
      opacity: controller.value,
      child: ScaleTransition(
        scale: controller,
        child: child,
      ),
    );
  }
}