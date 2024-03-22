import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';

/// realWidth: 1080.0, realHeight: 2274.0, pixelRatio: 2.625, Padding(left: 0, top: 83, right: 0, bottom: 0)
/// realWidth: 720, realHeight: 1280.0, pixelRatio: 2.0, Padding(left: 0, top: 48, right: 0, bottom: 0)

class AppSizes {
  AppSizes._();

  static final _instance = AppSizes._();
  static bool _initialState = false;
  static double sizeOfBigScreen = 700;
  static double descktopMaxWidthSize = 400;

  double? realPixelWidth;
  double? realPixelHeight;
  double? _pixelRatio;
  double appWidth = 0;    //Tecno: 360.0  Web: 1200
  double appHeight = 0;  //Tecno: 640.0  Web: 620
  ViewPadding? rootPadding;
  final List<Function> _onMetricListeners = [];
  Function? _systemMetricFunc;

  static AppSizes get instance {
    if(!_initialState){
      _initialState = true;
      _instance._systemMetricFunc = PlatformDispatcher.instance.onMetricsChanged;

      _instance._initial();
    }

    return _instance;
  }

  void _prepareSizes() {
    realPixelWidth = PlatformDispatcher.instance.implicitView!.physicalSize.width;
    realPixelHeight = PlatformDispatcher.instance.implicitView!.physicalSize.height;
    _pixelRatio = PlatformDispatcher.instance.implicitView!.devicePixelRatio;
    rootPadding = PlatformDispatcher.instance.implicitView!.padding;
    final isLandscape = realPixelWidth! > realPixelHeight!;

    if(kIsWeb) {
      appWidth = min(realPixelWidth! / _pixelRatio!, descktopMaxWidthSize);
      appHeight = realPixelHeight! / _pixelRatio!;
      _pixelRatio = realPixelHeight! / descktopMaxWidthSize;
    }
    else {
      appWidth = (isLandscape ? realPixelHeight : realPixelWidth)! / _pixelRatio!;
      appHeight = (isLandscape ? realPixelWidth : realPixelHeight)! / _pixelRatio!;
    }
  }

  void _initial() {
    _prepareSizes();

    ///----------------- onMetricsChanged -----------------
    void onMetricsChanged(){
      final oldW = realPixelWidth;
      final oldH = realPixelHeight;
      _prepareSizes();

      _systemMetricFunc?.call();

      for(final f in _onMetricListeners){
        try{
          f.call(oldW, oldH, realPixelWidth, realPixelHeight);
        }
        catch (e){/**/}
      }
    }

    ///----------------- onLocalChanged -----------------
    void onLocalChanged(){
    }

    PlatformDispatcher.instance.onLocaleChanged = onLocalChanged;
    /// Note: if below listener be set, auto orientation reBuild not work {OrientationBuilder()}
    PlatformDispatcher.instance.onMetricsChanged = onMetricsChanged;
  }

  void addMetricListener(Function(double oldW, double oldH, double newW, double newH) lis){
    _onMetricListeners.add(lis);
  }

  void removeMetricListener(Function lis){
    _onMetricListeners.remove(lis);
  }

  double? get pixelRatio => _pixelRatio;

  // pixel6 pro  => [411 * 843]  rate: 3.5
  // WQVGA       => [320 * 533]  rate: 0.75
  double get heightRelative => MathHelper.relativeOf(appHeight, 530, 40, 0.06);
  double get widthRelative => MathHelper.relativeOf(appWidth, 320, 40, 0.1);
  double get fontRatio => MathHelper.between(1.4, 3.5, 0.8, 0.8, _pixelRatio!);
  double get iconRatio => MathHelper.between(1.3, 3.5, 0.7, 0.8, _pixelRatio!);

  ///●●●● static ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
  static FlutterView? getWindow(){
    return PlatformDispatcher.instance.implicitView;
  }

  static Size getWindowSize(){
    return getWindow()!.physicalSize;
  }

  static bool isBigWidth(){
    return instance.appWidth > sizeOfBigScreen;
  }

  static double getPixelRatio(BuildContext context){
    return MediaQuery.of(context).devicePixelRatio;
  }

  static TextScaler getTextScaleFactor(BuildContext context){
    return MediaQuery.of(context).textScaler;
  }

  /// is include statusBarHeight
  static Size getMediaQuerySize(BuildContext context){
    return MediaQuery.of(context).size;
  }

  static Size getMediaQueryRealSize(BuildContext context){
    final r = MediaQuery.of(context).devicePixelRatio;
    final s = MediaQuery.of(context).size;

    return Size(s.width * r, s.height * r);
  }

  /// same of appWidth.  Tecno: 360.0   ,Web: deferToWindow [1200]
  static double getMediaQueryWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  /// is include statusBarHeight
  /// same of appHeight.   Tecno: 640.0   ,Web: deferToWindow [620]
  static double getMediaQueryHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  static double getStatusBarHeight(BuildContext context){
    return MediaQuery.of(context).padding.top;
  }

  static double getAppbarHeight(){
    return kToolbarHeight;
  }

  /// screen widthOut statusBar
  static double getViewPortHeight(BuildContext context){
    final full = MediaQuery.of(context).size.height;
    final status = MediaQuery.of(context).viewPadding.top; // this is variable
    const appBar = kToolbarHeight;

    return full - (status + appBar);
  }
}
