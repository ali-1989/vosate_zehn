import 'package:flutter/material.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';

class AppSnack {
  AppSnack._();

  static ScaffoldMessengerState getScaffoldMessenger(BuildContext context){
    return ScaffoldMessenger.of(context);
  }

  static ScaffoldMessengerState getScaffoldMessengerByKey(){
    return AppBroadcast.rootScaffoldMessengerKey.currentState!;
  }

  static ScaffoldFeatureController showFlutterSnackBar(SnackBar snackBar){
    return getScaffoldMessengerByKey().showSnackBar(snackBar);
  }

  static ScaffoldFeatureController showFlutterBanner(MaterialBanner banner){
    return getScaffoldMessengerByKey().showMaterialBanner(banner);
  }

  static SnackBar genSnackBar(String message){
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 3000),
    );
  }
  ///===================================================================================================
  static ScaffoldFeatureController showSnack(
      BuildContext context,
      String message, {
        Duration dur = const Duration(milliseconds: 3500),
        SnackBarAction? action,
        SnackBarBehavior? behavior,
        Color? backColor,
        EdgeInsetsGeometry? padding,
      }){
    final snackBar = SnackBar(
        content: Text(message),
      behavior: behavior ?? SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      duration: dur,
      action: action,
      padding: padding,
      backgroundColor: backColor,
    );

    return getScaffoldMessenger(context).showSnackBar(snackBar);
  }

  static void showSnackNotice(BuildContext context, String message){
    final snack = genSnackBar(message);
    showFlutterSnackBar(snack);
  }
  ///--------------------------------------------------------------------------------
  static void showSnack$netDisconnected(BuildContext context) {
    final snack = genSnackBar(AppMessages.netConnectionIsDisconnect);
    showFlutterSnackBar(snack);
  }

  static void showSnack$errorCommunicatingServer(BuildContext context) {
    final snack = genSnackBar(AppMessages.errorCommunicatingServer);
    showFlutterSnackBar(snack);
  }

  static void showSnack$serverNotRespondProperly(BuildContext context) {
    final snack = genSnackBar(AppMessages.serverNotRespondProperly);
    showFlutterSnackBar(snack);
  }

  static void showSnack$operationCannotBePerformed(BuildContext context) {
    final snack = genSnackBar(AppMessages.operationCannotBePerformed);
    showFlutterSnackBar(snack);
  }

  static void showSnack$successOperation(BuildContext context) {
    final snack = genSnackBar(AppMessages.successOperation);
    showFlutterSnackBar(snack);
  }

  static void showSnack$OperationFailed(BuildContext context) {
    final snack = genSnackBar(AppMessages.operationFailed);
    showFlutterSnackBar(snack);
  }

  static void showSnack$OperationFailedTryAgain(BuildContext context) {
    final snack = genSnackBar(AppMessages.operationFailedTryAgain);
    showFlutterSnackBar(snack);
  }

  static void showSnack$operationCanceled(BuildContext context) {
    final snack = genSnackBar(AppMessages.operationCanceled);
    showFlutterSnackBar(snack);
  }
}