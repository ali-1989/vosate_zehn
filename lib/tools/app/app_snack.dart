import 'package:flutter/material.dart';

import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/app/app_themes.dart';

class AppSnack {
  AppSnack._();

  static ScaffoldMessengerState getScaffoldMessenger(BuildContext context){
    return ScaffoldMessenger.of(context);
  }

  static ScaffoldMessengerState getScaffoldMessengerByKey(){
    return AppBroadcast.rootScaffoldMessengerKey.currentState!;
  }

  /// must call inside a scaffold.   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('')));
  /// width: AppSizes.isBigWidth()? AppSizes.webMaxDialogSize: null,
  static ScaffoldFeatureController showFlutterSnackBar(SnackBar snackBar){
    return getScaffoldMessengerByKey().showSnackBar(snackBar);
  }

  static ScaffoldFeatureController showFlutterBanner(MaterialBanner banner){
    return getScaffoldMessengerByKey().showMaterialBanner(banner);
  }

  static ScaffoldFeatureController showCustomSnack(
      BuildContext context,
      String message, {
        Duration dur = const Duration(milliseconds: 3500),
        SnackBarAction? action,
        SnackBarBehavior? behavior,
        Color? backColor,
        EdgeInsetsGeometry? padding,
        ShapeBorder? shape,
        VoidCallback? onVisible,
      }){
    final snackBar = SnackBar(
        content: Text(message),
      behavior: behavior ?? SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      duration: dur,
      action: action,
      padding: padding,
      backgroundColor: backColor,
      shape: shape,
      onVisible: onVisible,
      width: AppSizes.isBigWidth()? AppSizes.webMaxWidthSize: null,
    );

    return getScaffoldMessenger(context).showSnackBar(snackBar);
  }

  static SnackBar buildSnackBar(String message, {SnackBarAction? action, Widget? replaceContent, int? millis}){
    return AppDecoration.buildSnackBar(message,
        action: action,
        replaceContent: replaceContent,
        margin: const EdgeInsets.fromLTRB(20,0,20,50),
        durationMillis: millis,
    );
  }

  static MaterialBanner buildBanner(String message){
    return AppDecoration.buildBanner(message);
  }
  ///---------------------------------------------------------------------------------------------------------
  static void showSnack(BuildContext context, Widget message){
    final snack = buildSnackBar('', replaceContent: message);
    showFlutterSnackBar(snack);
  }

  static void showSnackText(BuildContext context, String message){
    final snack = buildSnackBar(message);
    showFlutterSnackBar(snack);
  }

  static void showError(BuildContext context, String message){
    final v = Row(
      children: [
        Icon(AppIcons.close, size: 30, color: AppThemes.instance.currentTheme.errorColor),
        const SizedBox(width: 30,),
        Flexible(child: Text(message))
      ],
    );

    final snack = buildSnackBar('', replaceContent: v);
    showFlutterSnackBar(snack);
  }

  static void showSuccess(BuildContext context, String message){
    final v = Row(
      children: [
        Icon(AppIcons.downloadDone, size: 30, color: AppThemes.instance.currentTheme.successColor),
        const SizedBox(width: 30,),
        Flexible(child: Text(message))
      ],
    );

    final snack = buildSnackBar('', replaceContent: v);
    showFlutterSnackBar(snack);
  }

  static void showInfo(BuildContext context, String message, {int millis = 3500}){
    final v = Row(
      children: [
        Icon(AppIcons.lightBulb, size: 30, color: AppThemes.instance.currentTheme.infoColor),
        const SizedBox(width: 30),
        Flexible(child: Text(message))
      ],
    );

    final snack = buildSnackBar('', replaceContent: v, millis: millis);
    showFlutterSnackBar(snack);
  }

  static void showAction(BuildContext context, String message, SnackBarAction action){
    final snack = buildSnackBar(AppMessages.operationCanceled, action: action);
    showFlutterSnackBar(snack);
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
