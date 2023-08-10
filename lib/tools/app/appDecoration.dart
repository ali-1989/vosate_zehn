import 'package:app/managers/font_manager.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AppDecoration {
  AppDecoration._();

  static Color mainColor = Colors.amber;
  static Color secondColor = Colors.orange;
  static Color differentColor = const Color(0xFFFF006E);
  static Color orange = const Color(0xFFFF006E);

  static InputDecoration inputBorder = const InputDecoration(
    border: OutlineInputBorder(),
    disabledBorder: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(),
    errorBorder: OutlineInputBorder(),
  );

  static ClassicFooter classicFooter = const ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );
  
  static TextStyle infoHeadLineTextStyle() {
    return AppThemes.instance.themeData.textTheme.headlineSmall!.copyWith(
      color: AppThemes.instance.themeData.textTheme.headlineSmall!.color!.withAlpha(150),
    );
  }

  static TextStyle infoTextStyle() {
    return AppThemes.instance.themeData.textTheme.headlineSmall!.copyWith(
      color: AppThemes.instance.themeData.textTheme.headlineSmall!.color!.withAlpha(150),
      fontSize: AppThemes.instance.themeData.textTheme.headlineSmall!.fontSize! -2,
      height: 1.5,
    );
    //return currentTheme.baseTextStyle.copyWith(color: currentTheme.infoTextColor);
  }

  static ButtonThemeData buttonTheme() {
    return AppThemes.instance.themeData.buttonTheme;
  }

  static TextStyle? buttonTextStyle() {
    return AppThemes.instance.themeData.textTheme.labelLarge;
    //return themeData.elevatedButtonTheme.style!.textStyle!.resolve({MaterialState.focused});
  }

  static Color? buttonTextColor() {
    return buttonTextStyle()?.color;
  }

  static Color? textButtonColor() {
    return AppThemes.instance.themeData.textButtonTheme.style!.foregroundColor!.resolve({MaterialState.selected});
  }

  static ThemeData dropdownTheme(BuildContext context, {Color? color}) {
    return AppThemes.instance.themeData.copyWith(
      canvasColor: color?? ColorHelper.changeHue(AppThemes.instance.currentTheme.accentColor),
    );
  }

  static TextStyle relativeSheetTextStyle() {
    final app = AppThemes.instance.themeData.appBarTheme.toolbarTextStyle!;
    final color = ColorHelper.getUnNearColor(/*app.color!*/Colors.white, AppThemes.instance.currentTheme.primaryColor, Colors.white);

    return app.copyWith(color: color, fontSize: 14);//currentTheme.appBarItemColor
  }

  static Text sheetText(String text) {
    return Text(
      text,
      style: relativeSheetTextStyle(),
    );
  }

  static TextStyle appBarTextStyle() {
    return AppThemes.instance.themeData.appBarTheme.toolbarTextStyle!;
  }
  static double fontSizeRelative(double size) {
    var siz = AppThemes.instance.currentTheme.baseTextStyle.fontSize;
    return (siz?? FontManager.deviceFontSize) + size;
  }
  ///------------------------------------------------------------------
  static InputDecoration noneBordersInputDecoration = const InputDecoration(
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
  );

  static InputDecoration outlineBordersInputDecoration = const InputDecoration(
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(),
    focusedErrorBorder: OutlineInputBorder(),
    disabledBorder: OutlineInputBorder(),
    errorBorder: OutlineInputBorder(),
  );

  static InputDecoration textFieldInputDecoration({int alpha = 255}) {
    final border = OutlineInputBorder(
        borderSide: BorderSide(color: AppThemes.instance.currentTheme.textColor.withAlpha(alpha))
    );

    return InputDecoration(
      border: border,
      disabledBorder: border,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
    );
  }

  static Color chipColor() {
    return checkPrimaryByWB(AppThemes.instance.currentTheme.primaryColor, AppThemes.instance.currentTheme.buttonBackColor);
  }

  static Color chipTextColor() {
    return ColorHelper.getUnNearColor(Colors.white, chipColor(), Colors.black);
  }

  static BoxDecoration dropdownDecoration({Color? color, double radius = 5}) {
    return BoxDecoration(
      color: color?? ColorHelper.changeHue(AppThemes.instance.currentTheme.accentColor),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static Color dropdownArrowColor() {
    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      return AppThemes.instance.currentTheme.appBarItemColor;
    }
    else {
      return Colors.white;
    }
  }

  static Color dropdownBackColor() {
    return ColorHelper.changeLight(AppThemes.instance.themeData.colorScheme.secondary);
  }

  static SnackBar buildSnackBar(String message, {
    SnackBarAction? action,
    Color? backgroundColor,
    Widget? replaceContent,
    int? durationMillis,
    double? width,
    SnackBarBehavior? behavior = SnackBarBehavior.floating,
    double? elevation,
    EdgeInsets? padding,
    EdgeInsets? margin,
    ShapeBorder? shape,
    Clip clip = Clip.hardEdge,
  }){

    return SnackBar(
      content: replaceContent?? Text(message),
      behavior: behavior,
      duration: Duration(milliseconds: durationMillis ?? 4000 /*default: 4000*/),
      backgroundColor: backgroundColor,
      dismissDirection: DismissDirection.horizontal,
      action: action,
      width: width?? (AppSizes.isBigWidth()? AppSizes.webMaxWidthSize: null),
      elevation: elevation,
      padding: padding,
      margin: margin, /*default: fromLTRB(15.0, 5.0, 15.0, 10.0)*/
      clipBehavior: clip,
      shape: shape,
    );
  }

  static MaterialBanner buildBanner(
      String message, {
        List<Widget> actions = const [],
        Color? backgroundColor,
        Color? dividerColor,
        Widget? replaceContent,
        TextStyle? textStyle,
        bool forceActionsBelow = false,
        Animation<double>? animation,
        double? elevation,
        EdgeInsets? padding,
        EdgeInsets? margin,
      }){

    if(actions.isEmpty){
      actions.add(SnackBarAction(label: AppMessages.ok, onPressed: (){}));
    }
    
    return MaterialBanner(
      content: replaceContent?? Text(message),
      backgroundColor: backgroundColor,
      actions: actions,
      animation: animation,
      contentTextStyle: textStyle,
      dividerColor: dividerColor,
      elevation: elevation,
      forceActionsBelow: forceActionsBelow,
      margin: margin,
      padding: padding,
    );
  }

  static Color cardColorOnCard() {
    return ColorHelper.changeHSLByRelativeDarkLight(AppThemes.instance.currentTheme.cardColor, 2, 0.0, 0.04);
  }

  static TextStyle relativeFabTextStyle() {
    final app = AppThemes.instance.themeData.appBarTheme.toolbarTextStyle!;

    return app.copyWith(fontSize: app.fontSize! - 3, color: AppThemes.instance.currentTheme.fabItemColor);
  }

  static Color relativeBorderColor$outButton({bool onColored = false}) {
    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.grey[900]!, Colors.grey[300]!])) {
      return AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      return onColored? Colors.white : AppThemes.instance.currentTheme.primaryColor;
    }
  }

  static BorderSide relativeBorderSide$outButton({bool onColored = false}) {
    return BorderSide(width: 1.0, color: relativeBorderColor$outButton(onColored: onColored).withAlpha(140));
  }

  static bool isDarkPrimary(){
    return ColorHelper.isNearColor(AppThemes.instance.currentTheme.primaryColor, Colors.grey[900]!);
  }

  static bool isLightPrimary(){
    return ColorHelper.isNearColor(AppThemes.instance.currentTheme.primaryColor, Colors.grey[200]!);
  }

  static Color checkPrimaryByWB(Color ifNotNear, Color ifNear){
    return ColorHelper.ifNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.grey[900]!, Colors.grey[600]!, Colors.white],
            ()=> ifNear, ()=> ifNotNear);
  }
}