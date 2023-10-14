import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:app/views/components/overlay/overlay_animations.dart';

enum OverlayIndicatorType {
  fadingCircle,
  circle,
  threeBounce,
  chasingDots,
  wave,
  wanderingCubes,
  rotatingPlain,
  doubleBounce,
  fadingFour,
  fadingCube,
  pulse,
  cubeGrid,
  rotatingCircle,
  foldingCube,
  pumpingHeart,
  dualRing,
  hourGlass,
  pouringHourGlass,
  fadingGrid,
  ring,
  ripple,
  spinningCircle,
  squareCircle,
}

enum OverlayStyle {
  light,
  dark,
  custom,
}

enum OverlayToastPosition {
  top,
  center,
  bottom,
}

enum OverlayAnimationStyle {
  opacity,
  offset,
  scale,
  custom,
}

enum OverlayMaskType {
  none,
  clear,
  black,
  custom,
}
///=================================================================================================
T? genericCallbackFn<T>(T? value) => value;

class OverlayContainer extends StatefulWidget {
  final Widget? indicator;
  final String? message;
  final OverlayTheme? overlayTheme;
  final OverlayToastPosition? toastPosition;
  final OverlayMaskType? maskType;
  final Completer<void>? completer;
  final bool animation;

  const OverlayContainer({
    Key? key,
    this.indicator,
    this.message,
    this.overlayTheme,
    this.toastPosition,
    this.maskType,
    this.completer,
    this.animation = true,
  }) : super(key: key);

  @override
  OverlayContainerState createState() => OverlayContainerState();
}

class OverlayContainerState extends State<OverlayContainer> with SingleTickerProviderStateMixin {
  String? _status;
  Color? _maskColor;
  late OverlayTheme theme;
  late AnimationController _animationController;
  late AlignmentGeometry _alignment;

  bool get isPersistentCallbacks => genericCallbackFn(SchedulerBinding.instance)!.schedulerPhase == SchedulerPhase.persistentCallbacks;

  @override
  void initState() {
    super.initState();

    if (!mounted) {
      return;
    }

    theme = widget.overlayTheme?? OverlayTheme();

    _status = widget.message;
    _alignment = (widget.indicator == null && widget.message?.isNotEmpty == true)
        ? theme.alignment(widget.toastPosition)
        : AlignmentDirectional.center;
    _maskColor = theme.maskColor(widget.maskType);

    _animationController = AnimationController(
      vsync: this,
      duration: theme.animationDuration,
    )..addStatusListener((status) {
      bool isCompleted = widget.completer?.isCompleted ?? false;

      if (status == AnimationStatus.completed && !isCompleted) {
        widget.completer?.complete();
      }
    });

    show(widget.animation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: _alignment,
      children: <Widget>[
        Visibility(
          visible: theme.defaultMaskType != OverlayMaskType.clear,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget? child) {
                return Opacity(
                  opacity: _animationController.value,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: _maskColor,
                  ),
                );
              },
            ),
        ),

        AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) {
            return theme.loadingAnimation.buildWidget(
              _Indicator(
                message: _status,
                indicator: widget.indicator,
                theme: theme,
              ),
              _animationController,
              _alignment,
            );
          },
        ),
      ],
    );
  }

  Future<void> show(bool animation) {
    if (isPersistentCallbacks) {
      Completer<void> completer = Completer<void>();
      genericCallbackFn(SchedulerBinding.instance)!.addPostFrameCallback((_) {
        _animationController.forward(from: animation ? 0 : 1);
        completer.complete();
      });

      return completer.future;
    }
    else {
      return _animationController.forward(from: animation ? 0 : 1);
    }
  }

  Future<void> dismiss(bool animation) {
    if (isPersistentCallbacks) {
      Completer<void> completer = Completer<void>();
      genericCallbackFn(SchedulerBinding.instance)!.addPostFrameCallback((_) {
        _animationController.reverse(from: animation ? 1 : 0);
        completer.complete();
      });

      return completer.future;
    }
    else {
      return _animationController.reverse(from: animation ? 1 : 0);
    }
  }

  void updateStatus(String status) {
    if (_status == status){
      return;
    }

    setState(() {
      _status = status;
    });
  }
}
///====================================================================================
class _Indicator extends StatelessWidget {
  final Widget? indicator;
  final String? message;
  final OverlayTheme theme;

  const _Indicator({
    required this.indicator,
    required this.message,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(50.0),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(
          theme.radius,
        ),
        boxShadow: theme.boxShadow,
      ),
      padding: theme.contentPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(
            builder: (ctx){
              if(indicator != null){
                return Container(
                  margin: message?.isNotEmpty == true
                      ? theme.textPadding
                      : EdgeInsets.zero,
                  child: UnconstrainedBox(
                    child: indicator!,
                  ),
                );
              }

              return const SizedBox();
            },
          ),

          Builder(
            builder: (ctx){
              if(message != null){
                return Text(message!,
                  style: theme.textStyle ??
                      TextStyle(
                        color: theme.textColor,
                        fontSize: theme.fontSize,
                      ),
                  textAlign: theme.textAlign,
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
///========================================================================================
class OverlayTheme {
  OverlayStyle defaultLoadingStyle = OverlayStyle.dark;
  OverlayMaskType defaultMaskType = OverlayMaskType.custom;
  OverlayToastPosition defaultToastPosition = OverlayToastPosition.center;
  OverlayAnimationStyle defaultAnimationStyle = OverlayAnimationStyle.opacity;
  TextAlign defaultTextAlign = TextAlign.center;
  EdgeInsets defaultContentPadding = const EdgeInsets.symmetric(
    vertical: 15.0,
    horizontal: 20.0,
  );
  EdgeInsets defaultTextPadding = const EdgeInsets.only(bottom: 10.0);
  double defaultIndicatorSize = 45.0;
  double radius = 10.0;
  double defaultFontSize = 15.0;
  double defaultProgressWidth = 2.0;
  double defaultLineWidth = 4.0;
  Duration defaultDisplayDuration = const Duration(milliseconds: 3000);
  Duration defaultAnimationDuration = const Duration(milliseconds: 200);
  OverlayAnimation? customAnimation;
  TextStyle? defaultTextStyle;
  Color? defaultTextColor = Colors.white;
  Color? defaultIndicatorColor = Colors.white;
  Color? defaultProgressColor = Colors.white;
  Color? defaultBackgroundColor = Colors.transparent;
  List<BoxShadow>? defaultBoxShadow;
  Color? defaultMaskColor;
  Widget? defaultSuccessWidget;
  Widget? defaultErrorWidget;

  OverlayTheme(){
    defaultSuccessWidget = Icon(
      Icons.done,
      color: indicatorColor,
      size: indicatorSize,
    );

    defaultErrorWidget = Icon(
      Icons.clear,
      color: indicatorColor,
      size: indicatorSize,
    );

  }

  Color get indicatorColor =>
      defaultLoadingStyle == OverlayStyle.custom
          ? defaultIndicatorColor!
          : defaultLoadingStyle == OverlayStyle.dark
          ? Colors.white
          : Colors.black;

  Color get progressColor =>
      defaultLoadingStyle == OverlayStyle.custom
          ? defaultProgressColor!
          : defaultLoadingStyle == OverlayStyle.dark
          ? Colors.white
          : Colors.black;

   Color get backgroundColor =>
      defaultLoadingStyle == OverlayStyle.custom
          ? defaultBackgroundColor!
          : defaultLoadingStyle == OverlayStyle.dark
          ? Colors.black.withOpacity(0.8)
          : Colors.white;

  List<BoxShadow>? get boxShadow =>
      defaultLoadingStyle == OverlayStyle.custom
          ? defaultBoxShadow ?? [const BoxShadow()]
          : null;

  Color get textColor =>
      defaultLoadingStyle == OverlayStyle.custom
          ? defaultTextColor!
          : defaultLoadingStyle == OverlayStyle.dark
          ? Colors.white
          : Colors.black;

  Color maskColor(OverlayMaskType? maskType) {
    maskType ??= defaultMaskType;

    if(maskType == OverlayMaskType.custom){
      return defaultMaskColor?? Colors.transparent;
    }

    if(maskType == OverlayMaskType.black){
      return Colors.black.withOpacity(0.5);
    }

    return Colors.transparent;
  }

  OverlayAnimation get loadingAnimation {
    OverlayAnimation animation;

    switch (defaultAnimationStyle) {
      case OverlayAnimationStyle.custom:
        animation = customAnimation!;
        break;
      case OverlayAnimationStyle.offset:
        animation = OffsetAnimation();
        break;
      case OverlayAnimationStyle.scale:
        animation = ScaleAnimation();
        break;
      default:
        animation = OpacityAnimation();
        break;
    }

    return animation;
  }

  double get fontSize => defaultFontSize;

  double get indicatorSize => defaultIndicatorSize;

  double get progressWidth => defaultProgressWidth;

  double get lineWidth => defaultLineWidth;

  OverlayToastPosition get toastPosition => defaultToastPosition;

  AlignmentGeometry alignment(OverlayToastPosition? position) {
    if(position == OverlayToastPosition.bottom){
      return AlignmentDirectional.bottomCenter;
    }

    if(position == OverlayToastPosition.top){
      return AlignmentDirectional.topCenter;
    }

    return AlignmentDirectional.center;
  }

  Duration get displayDuration => defaultDisplayDuration;

  Duration get animationDuration => defaultAnimationDuration;

  EdgeInsets get contentPadding => defaultContentPadding;

  EdgeInsets get textPadding => defaultTextPadding;

  TextAlign get textAlign => defaultTextAlign;

  TextStyle? get textStyle => defaultTextStyle;
}

