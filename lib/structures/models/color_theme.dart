import 'dart:math';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';

class ColorTheme {
  String themeName = 'theme_${Random().nextInt(1000)}';
  late HSLColor primaryHsl; // in Init
  late MaterialColor primarySwatch;
  Color primaryColor = Colors.blue;
  Color accentColor = Colors.blue[400]!; // AppThemes.themeData.colorScheme.secondary
  Color differentColor = Colors.pinkAccent;
  Color textColor = Colors.black;
  Color backgroundColor = Colors.white;
  Color infoTextColor = Colors.black.withAlpha(170); //in Init
  Color webHoverColor = Colors.black.withAlpha(40); //in Init
  Color hintColor = Colors.blue[200]!;
  Color dividerColor = Colors.blue.withAlpha(140); //in Init
  Color activeItemColor = Colors.blue; //in Init
  Color inactiveBackColor = Colors.grey[400]!;
  Color inactiveTextColor = Colors.grey[700]!;
  Color buttonTextColor = Colors.white;
  Color buttonTextColorOnPrimary = Colors.black;
  Color buttonBackColor = Colors.blue;
  Color buttonBackColorOnPrimary = Colors.white;
  Color underLineDecorationColor = Colors.blue[700]!;
  Color cardColor = Colors.white;
  Color dialogBackColor = Colors.white;
  Color dialogTextColor = Colors.black;
  Color drawerBackColor = Colors.white;
  Color drawerItemColor = Colors.black;
  Color appBarBackColor = Colors.blue;
  Color appBarItemColor = Colors.white;
  Color shadowColor = const Color(0xf0000000);
  Color badgeBackColor = Colors.red;
  Color badgeTextColor = Colors.black;
  Color headerBackColor = Colors.blue.withAlpha(100); //in Init
  Color headerTextColor = Colors.white;
  Color fabBackColor = Colors.blue;
  Color fabItemColor = Colors.white;
  Color dimBackgroundColor = Colors.black.withAlpha(120); //in Init
  Color successColor = Colors.green[600]!;
  Color warningColor = Colors.orange;
  Color infoColor = Colors.blue[600]!;
  Color errorColor = Colors.red[600]!;
  Color textDifferentColor = Colors.black;

  late ColorScheme buttonsColorScheme;  //in Init & create
  late TextStyle baseTextStyle; //in Init
  late TextStyle subTextStyle; //in Init
  late TextStyle boldTextStyle; //in Init
  late TextStyle textUnderlineStyle; //in Init
  Function(ColorTheme to)? executeOnStart;
  Function(ThemeData themeData, ColorTheme to)? executeOnEnd;

  ColorTheme(Color primary, Color accent, Color different, this.textColor, {
    MaterialColor? primarySwatch,
    Brightness? brightness,
  }) {
    primaryColor = primary;
    accentColor = accent;
    differentColor = different;

    _initial(primarySwatch, brightness?? Brightness.light);
  }

  void _initial(MaterialColor? ps, Brightness brightness) {
    primaryHsl = HSLColor.fromColor(primaryColor);
    primarySwatch = ps?? MaterialColor(primaryColor.value, ColorHelper.getColorMap(primaryColor));

    appBarBackColor = primaryColor;
    buttonBackColor = ColorHelper.isDarkColor(primaryColor) ? primarySwatch[700]! : primarySwatch[800]!;
    hintColor = textColor.withAlpha(200);//primarySwatch[200]!;
    infoTextColor = textColor.withAlpha(170);
    webHoverColor = primaryColor.withAlpha(40);
    textDifferentColor = accentColor;

    buttonsColorScheme = ColorScheme.fromSwatch(
      primarySwatch: primarySwatch,
      // buttons are use this color for btnText (accentColor)
      accentColor: buttonTextColor,
      backgroundColor: buttonBackColor,
      errorColor: errorColor,
      cardColor: cardColor,
      brightness: brightness,
    );

    baseTextStyle = const TextStyle().copyWith(
      color: textColor,
    );

    badgeTextColor = appBarTextColor;
    dividerColor = primaryColor.withAlpha(140);

    textUnderlineStyle = baseTextStyle.copyWith(
        fontWeight: FontWeight.bold,
        //decoration: TextDecoration.underline,
        //decorationColor: underLineDecorationColor,
        color: underLineDecorationColor
    );

    activeItemColor = (){
      if(ColorHelper.isNearColors(primaryColor, [Colors.grey[900]!, Colors.grey[600]!])) {
        return differentColor;
      }

      if(ColorHelper.isNearColor(primaryColor, Colors.white)) {
        return differentColor;
      }

      return primaryColor;
    }();

    fabBackColor = (){
      if(ColorHelper.isNearColors(primaryColor, [Colors.grey[900]!, Colors.grey[600]!])) {
        return differentColor;
      }

      if(ColorHelper.isNearColor(primaryColor, Colors.grey[200]!)) {
        return differentColor;
      }

      return ColorHelper.darkIfIsLight(primaryColor);
    }();

    fabItemColor = ColorHelper.getUnNearColor(Colors.white, fabBackColor, Colors.black);

    headerBackColor = (){
      if(ColorHelper.isNearColor(primaryColor, Colors.grey[200]!)) {
        return Colors.black.withAlpha(100);
      }

      return primaryColor.withAlpha(62);
    }();

    headerTextColor = (){
      if(ColorHelper.isNearColor(headerBackColor, textColor, degrees: 0.45)) {
        return ColorHelper.inverseColor(textColor);
      }

      return textColor;
    }();
  }

  Color textColorOn(Color back) {
    if (ColorHelper.isNearColors(back, [Colors.white, Colors.grey[200]!])) {
      return Colors.black;
    } else if (ColorHelper.isNearColors(back, [Colors.black, Colors.grey[900]!])) {
      return Colors.white;
    } else {
      return textColor;
    }
  }

  Color textColorOnPrimary() {
      return textColorOn(primaryColor);
  }

  Color whiteOrBlackOn(Color back) {
    if (ColorHelper.isNearColors(back, [Colors.white, Colors.grey[200]!])) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Color whiteOrBlackOnPrimary() {
    return whiteOrBlackOn(primaryColor);
  }

  Color whiteOrAppBarItemOnPrimary() {
    if (ColorHelper.isNearColors(primaryColor, [Colors.white, Colors.grey[200]!])) {
      return appBarItemColor;
    } else {
      return Colors.white;
    }
  }

  Color primaryOrDifferentOn(Color back) {
    if (ColorHelper.isNearColor(primaryColor, back)) {
      return differentColor;
    } else {
      return primaryColor;
    }
  }

  Color primaryOrDifferentOnWB() {
  if(ColorHelper.isNearColors(primaryColor, [Colors.white, Colors.black, Colors.grey[500]!])) {
    return differentColor;
  }

    return primaryColor;
  }

  Color get appBarTextColor => appBarItemColor;

  Color get primaryWhiteBlackColor {
    if (ColorHelper.isNearColors(primaryColor, [Colors.white, Colors.grey[200]!])) {
      return Colors.black;
    } else if (ColorHelper.isNearColors(primaryColor, [Colors.black, Colors.grey[900]!])) {
      return Colors.white;
    } else {
      return primaryColor;
    }
  }

  Color get dialogButtonsColor => Colors.transparent;
  Color get dialogSelectedButtonColor => primaryColor;

  static ThemeData getThemeData(BuildContext context) {
    return Theme.of(context);
  }
}
