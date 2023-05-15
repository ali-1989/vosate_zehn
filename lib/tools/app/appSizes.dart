import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// realWidth: 1080.0, realHeight: 2274.0, pixelRatio: 2.625, Padding(left: 0, top: 83, right: 0, bottom: 0)
/// realWidth: 720, realHeight: 1280.0, pixelRatio: 2.0, Padding(left: 0, top: 48, right: 0, bottom: 0)

class AppSizes {
  AppSizes._();

  static final _instance = AppSizes._();
  static bool _initialState = false;

  static double sizeOfBigScreen = 700;
  static double webMaxWidthSize = 500;

  double? realPixelWidth;
  double? realPixelHeight;
  double? pixelRatio;
  double appWidth = 0;    //Tecno: 360.0  Web: 1200
  double appHeight = 0;  //Tecno: 640.0  Web: 620
  double textMultiplier = 6; // Tecno: ~6.4
  double imageMultiplier = 1;
  double heightMultiplier = 1;
  List<Function> onMetricListeners = [];
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
    pixelRatio = PlatformDispatcher.instance.implicitView!.devicePixelRatio;
    final isLandscape = realPixelWidth! > realPixelHeight!;

    if(kIsWeb) {
      appWidth = realPixelWidth! / pixelRatio!;
      appHeight = realPixelHeight! / pixelRatio!;
      imageMultiplier = 3.6;
      textMultiplier = 6.2;
      heightMultiplier = 6.2;
    }
    else {
      appWidth = (isLandscape ? realPixelHeight : realPixelWidth)! / pixelRatio!;
      appHeight = (isLandscape ? realPixelWidth : realPixelHeight)! / pixelRatio!;
      imageMultiplier = appWidth / 100;
      textMultiplier = appHeight / 100; // ~6.3
      heightMultiplier = appHeight / 100;
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
      /*if(oldW == realHeight && oldH == realWidth) {
        return;
      }*/

      for(final f in onMetricListeners){
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
    onMetricListeners.add(lis);
  }

  void removeMetricListener(Function lis){
    onMetricListeners.remove(lis);
  }

  double get appWidthRelateWeb => webMaxWidthSize;
  ///●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
  static Size getWindowSize(){
    return PlatformDispatcher.instance.implicitView!.physicalSize;
  }

  static bool isBigWidth(){
    return instance.appWidth > sizeOfBigScreen;
  }

  static double webFontSize(double size){
    if(kIsWeb) {
      return size * 1.1;
    }

    return size;
  }

  double? getPixelRatio(){
    return pixelRatio;
  }

  static double getPixelRatioBy(BuildContext context){
    return MediaQuery.of(context).devicePixelRatio;
  }

  static Size getScreenRealSize(BuildContext context){
    final r = MediaQuery.of(context).devicePixelRatio;
    final s = MediaQuery.of(context).size;

    return Size(s.width * r, s.height * r);
  }

  static double getTextScaleFactorBy(BuildContext context){
    return MediaQuery.of(context).textScaleFactor;
  }

  /// is include statusBarHeight
  static Size getScreenSizeBy(BuildContext context){
    return MediaQuery.of(context).size;
  }

  /// same of appWidth.  Tecno: 360.0   ,Web: deferToWindow [1200]
  static double getScreenWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  /// is include statusBarHeight
  /// same of appHeight.   Tecno: 640.0   ,Web: deferToWindow [620]
  static double getScreenHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }
  ///-----------------------------------------------------------------------------------------
  static double getStatusBarHeight(BuildContext context){
    return MediaQuery.of(context).padding.top;
  }

  static double getAppbarHeight(){
    return kToolbarHeight;
  }

  static double getViewPortHeight(BuildContext context){
    final full = MediaQuery.of(context).size.height;
    final status = MediaQuery.of(context).viewPadding.top; // this is variable
    const appBar = kToolbarHeight;

    return full - (status + appBar);
  }
}
