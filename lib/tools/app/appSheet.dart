import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';


import '/system/extensions.dart';
import '/tools/app/appNavigator.dart';

/*
>> showModalSheet()
>> showBottomSheet()
>> showModalBottomSheet()
>> showCupertinoModalPopup()
 */

class AppSheet {
  AppSheet._();

  static void closeSheet<T>(BuildContext context, {T? result}){
    Navigator.of(context).pop(result);
  }

  static void closeSheetByName<T>(BuildContext context, String routeName, {T? result}){
    AppNavigator.popByRouteName(context, routeName, result: result);
  }
  ///=======================================================================================================
  static PersistentBottomSheetController<T> showBottomSheetInScaffold<T>(
      BuildContext ctx,
      Widget Function(BuildContext context) builder, {
        Color? backgroundColor,
        double elevation = 0.0,
        ShapeBorder? shape,
      }){

    return showBottomSheet<T>(
      context: ctx,
      shape: shape,
      clipBehavior: shape!= null? Clip.antiAlias : Clip.none,
      elevation: elevation,
      backgroundColor: backgroundColor?? Colors.transparent,
      builder: builder,
    );
  }

  static Future<T?> showCupertinoSheet<T>(BuildContext context, Widget view,{
    Color? dimColor,
    bool dismissible = true,
    RouteSettings? routeSettings,
  }){

    final res = showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => view,
      barrierColor: dimColor?? Colors.black12,
      barrierDismissible: dismissible,
      routeSettings: routeSettings,
    );

    return res;
  }

  static Future<T?> showModalSheet<T>(
      BuildContext ctx,
      Widget Function(BuildContext context) builder, {
        Color? backgroundColor,
        Color? barrierColor,
        double elevation = 1.0,
        ShapeBorder? shape,
        bool isDismissible = true,
        //[isScrollControlled] if false: on small sheet show elevation to center page
        // if true can have full screen
        bool isScrollControlled = true,
        String routeName = 'ModalBottomSheet',
      }){

    FocusHelper.hideKeyboardByUnFocus(ctx);

    return showModalBottomSheet<T>(
        context: ctx,
        elevation: elevation,
        shape: shape,
        isDismissible: isDismissible,
        clipBehavior: shape!= null? Clip.antiAlias : Clip.none,
        backgroundColor: backgroundColor?? Colors.transparent,
        barrierColor: barrierColor,
        routeSettings: RouteSettings(name: routeName),
        //constraints: BoxConstraints.tightFor(),
        isScrollControlled: isScrollControlled,
        builder: builder
    );
  }
  ///=======================================================================================================
  /// T: is returned value from Navigator.Pop()
  static Future<T?> showSheetOneAction<T>(
      BuildContext context,
      String message,
      VoidCallback? fn, {
        String? title,
        String? buttonText,
        bool dismissOnAction = true,
        bool isDismissible = true,
        String? routeName,
      }){

    buttonText ??= AppMessages.ok;
    final contentColor = AppThemes.instance.currentTheme.primaryColor;
    final buttonbarColor = AppThemes.instance.currentTheme.primaryColor;
    final barrierColor = ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.black,])
        ? Colors.white.withAlpha(80) : Colors.black.withAlpha(120);

    void close(){
      Navigator.maybeOf(context)?.pop();
      fn?.call();
    }

    final posBtn = TextButton(
        onPressed: dismissOnAction? close : fn,
        child: Text(buttonText, style: AppThemes.relativeSheetTextStyle(),)
    );
    //TextButton.icon(onPressed: fn, label: Text(btnText,), icon: Icon(icon, color: textColor,),);

    final content = Text(message, style: AppThemes.relativeSheetTextStyle(),);
    Widget? titleView;

    if(title != null) {
      titleView = Text(title, style: AppThemes.relativeSheetTextStyle(),);
    }

    final body = _getBody(
      context,
      contentColor,
      content,
      posButton: posBtn,
      title: titleView,
      buttonBarColor: buttonbarColor,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
    );

    return showModalSheet<T>(
      context,
          (ctx) => body,
      isDismissible: isDismissible,
      isScrollControlled: false,
      routeName : routeName?? Generator.generateKey(5),
      barrierColor: barrierColor,
    );
  }

  static Future<T?> showSheetOk<T>(BuildContext context, String msg, {bool isDismissible = true,}){
    return showSheetOneAction(context, msg, null, isDismissible: isDismissible);
  }

  static Future<T?> showSheetNotice<T>(BuildContext context, String msg, {bool isDismissible = true}){
    return showSheetOneAction(context, msg, null, title: AppMessages.notice, isDismissible: isDismissible);
  }
  ///=======================================================================================================
  static Future<T?> showSheetYesNo<T>(
      BuildContext context,
      Text msg,
      VoidCallback? posFn,
      VoidCallback? negFn, {
        Text? title,
        String? posBtnText,
        String? negBtnText,
        Widget? icon,
        bool dismissOnAction = true,
        bool isDismissible = true,
        String? routeName,
      }){

    final contentColor = AppThemes.instance.currentTheme.primaryColor;
    final btnBarColor = AppThemes.instance.currentTheme.primaryColor;
    final barrierColor = ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.black])? Colors.white.withAlpha(80) : Colors.black.withAlpha(120);

    void posClose(){
      Navigator.of(context).pop();
      posFn?.call();
    }

    void negClose(){
      Navigator.of(context).pop();
      negFn?.call();
    }

    posBtnText ??= AppMessages.yes;
    negBtnText ??= AppMessages.no;

    final ts = AppThemes.baseTextStyle().copyWith(
      color: ColorHelper.getUnNearColor(Colors.white, AppThemes.instance.currentTheme.primaryColor, Colors.black),
    );

    final posBtn = TextButton(onPressed: dismissOnAction? posClose: posFn,
        child: Text(posBtnText, style: ts)
    );
    final negBtn = TextButton(onPressed: dismissOnAction? negClose: negFn,
        child: Text(negBtnText, style: ts)
    );

    final body = _getBody(
      context, contentColor, msg,
      posButton: posBtn,
      negButton: negBtn,
      title: title,
      buttonBarColor: btnBarColor,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
    );

    return showModalSheet<T>(
      context,
          (ctx) => body,
      isDismissible: isDismissible,
      isScrollControlled: true,
      routeName: routeName?? Generator.generateKey(5),
      barrierColor: barrierColor,
    );
  }

  static Future<T?> showSheetCustom<T>(
      BuildContext context,
      Widget content, {
        required String routeName,
        Widget? positiveButton,
        Color? backgroundColor,
        Color? contentColor,
        Color? buttonBarColor,
        Color? barrierColor,
        bool isDismissible = true,
        bool useExpanded = false,
        bool isScrollControlled = false,
        ShapeBorder? shape,
        double elevation = 0.0,
        Widget? negativeButton,
        Text? title,
      }){

    backgroundColor ??= Colors.transparent;
    contentColor ??= AppThemes.instance.currentTheme.primaryColor;
    barrierColor ??= ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.black])
        ? Colors.white.withAlpha(80) : Colors.black.withAlpha(120);

    Widget body;

    if(useExpanded) {
      body = _getBodyForList(
          context, contentColor, content,
          posButton: positiveButton,
          title: title,
          negButton: negativeButton,
          buttonBarColor: buttonBarColor ?? contentColor
      );
    }
    else {
      body = _getBody(
          context, contentColor, content,
          posButton: positiveButton,
          title: title,
          negButton: negativeButton,
          buttonBarColor: buttonBarColor ?? contentColor
      );
    }

    return showModalSheet<T>(context,
            (ctx) => body,
        backgroundColor: backgroundColor,
        isDismissible: isDismissible,
        isScrollControlled: isScrollControlled,
        barrierColor: barrierColor,
        shape: shape,
        elevation: elevation,
        routeName: routeName,
    );
  }
  ///=======================================================================================================
  static Widget _getBodyForList(
      BuildContext ctx,
      Color contentColor,
      Widget description, {
        Widget? title,
        Widget? posButton,
        Widget? negButton,
        Color? buttonBarColor,
        EdgeInsets padding = EdgeInsets.zero,
      }){

    final theme = Theme.of(ctx);

      return ColoredBox(
        color: contentColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Expanded(
              child: Padding(
              padding: padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if(title != null)
                    DefaultTextStyle(
                        style: theme.textTheme.headline6!.copyWith(fontSize: 17, fontWeight: FontWeight.bold,),
                        textAlign: TextAlign.start,
                        child: title
                    ),

                  Expanded(
                    child: DefaultTextStyle(
                      style: theme.textTheme.headline6!.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
                      child: description,
                    ),
                  )
                ],
              ),
            ),
            ),

            ///------- buttons
            if(posButton != null || negButton != null)
              ColoredBox(
              color: buttonBarColor?? contentColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    posButton?? const SizedBox(),
                    negButton?? const SizedBox(),
                  ],
                ),
              ),
            )
          ],
        ),
      );
  }

  static Widget _getBody(
      BuildContext ctx,
      Color contentColor,
      Widget description, {
        Widget? title,
        Widget? posButton,
        Widget? negButton,
        Color? buttonBarColor,
        EdgeInsets padding = EdgeInsets.zero,
      }) {
    final theme = Theme.of(ctx);

    return ColoredBox(
      color: contentColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null)
                  DefaultTextStyle(
                      style: theme.textTheme.headline6!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                      child: title),
                if (title != null)
                  const SizedBox(height: 10,),

                DefaultTextStyle(
                  style: theme.textTheme.headline6!.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                  child: description,
                )
              ],
            ),
          ),

          ///------- buttons
          if (posButton != null || negButton != null)
            ColoredBox(
              color: buttonBarColor ?? contentColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    posButton ?? const SizedBox(),
                    negButton ?? const SizedBox(),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
  ///=======================================================================================================
  static void showSheetMenu(BuildContext ctx,
      List<Widget> widgets,
      String routeName,{
      Color? backgroundColor,
    }){
    final view = BottomSheet(
      onClosing: () {},
      shape: const RoundedRectangleBorder(
          side: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20))
      ),
      constraints: const BoxConstraints.tightFor(),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widgets,
          ],
        );
      },
    ).wrapListTileTheme();

    showModalSheet(ctx, (context) => view,
      routeName: routeName,
      backgroundColor: backgroundColor?? Colors.transparent,
      elevation: 0,
    );
  }
  ///===================================================================================================
  static Widget generateSheetMenu(
      BuildContext context,
      List<Widget> items,
      {
        Color? backColor,
        EdgeInsets? padding,
        TextDirection? textDirection,
      }) {
    backColor ??= Colors.white;
    padding ??= const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    textDirection ??= Directionality.of(context);

    return ColoredBox(
      color: backColor,
      child: Padding(
        padding: padding,
        child: Directionality(
          textDirection: textDirection,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(!Platform.isAndroid)
                  const Icon(
                    AppIcons.close,
                  ).wrapMaterial(
                      materialColor: AppThemes.instance.currentTheme.primaryColor.withAlpha(70),
                      padding: const EdgeInsets.all(4),
                      onTapDelay: (){AppNavigator.pop(context);}
                  ),
                ],
              ),

              ...items
            ],
          ),
        ),
      ),
    );
  }
  ///=======================================================================================================
  static Future<T?> showSheet$NetDisconnected<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.netConnectionIsDisconnect, null);
  }

  static Future<T?> showSheet$ErrorCommunicatingServer<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.errorCommunicatingServer, null);
  }

  static Future<T?> showSheet$ServerNotRespondProperly<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.serverNotRespondProperly, null);
  }

  static Future<T?> showSheet$OperationCannotBePerformed<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.operationCannotBePerformed, null);
  }

  static Future<T?> showSheet$SuccessOperation<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.successOperation, null);
  }

  static Future<T?> showSheet$OperationFailed<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.operationFailed, null);
  }

  static Future<T?> showSheet$OperationFailedTryAgain<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.operationFailedTryAgain, null);
  }

  static Future<T?> showSheet$OperationCanceled<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.operationCanceled, null);
  }

  static Future<T?> showSheet$YouDoNotHaveAccess<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.sorryYouDoNotHaveAccess, null);
  }

  static Future<T?> showSheet$AccountIsBlock<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.accountIsBlock, null);
  }

  static Future<T?> showSheet$ThereAreNoResults<T>(BuildContext context){
    return showSheetOneAction<T>(context, AppMessages.thereAreNoResults, null);
  }
  ///=====================================================================================================
  static void showSheet(BuildContext context, {
   String? title,
   String? message,
   List<Widget>? actions,
  }){
    return Dialogs.bottomMaterialDialog(
        msg: message,
        title: title,
        context: context,
        actions: [
          ...?actions
        ]);
  }

  /*IconsOutlineButton(
            onPressed: () {},
            text: 'Cancel',
            iconData: Icons.cancel_outlined,
            textStyle: TextStyle(color: Colors.grey),
            iconColor: Colors.grey,
          ),
          IconsButton(
            onPressed: () {},
            text: 'Delete',
            iconData: Icons.delete,
            color: Colors.red,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),*/
}

/*
final items = <Map>[];

    items.add({
      'title': '${state.t('temporaryStorage')}',
      'icon': IconList.flag,
      'fn': (){changeShowState();}
    });

    items.add({
      'title': '${state.t('delete')}',
      'icon': IconList.delete,
      'fn': (){
        yesFn(){
          AppNavigator.pop(state.context);
          deleteFood();
        }

        DialogCenter().showYesNoDialog(state.context,
            yesFn: yesFn,
            desc: state.t('wantToDeleteThisItem'));
      }
    });


    Widget genView(elm){
      return ListTile(
        title: Text(elm['title']),
        leading: Icon(elm['icon']),
        onTap: (){
          SheetCenter.closeSheetByName(state.context, 'EditMenu');
          elm['fn']?.call();
        },
      );
    }

    SheetCenter.showSheetMenu(state.context,
        items.map(genView).toList(),
        'EditMenu');
----------------------------------------------------------------------
  CupertinoActionSheet(
        title: Text(translate('language.selection.title')),
        message: Text(translate('language.selection.message')),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(translate('language.name.en')),
            onPressed: () => Navigator.pop(context, 'en_US'),
            )
   */
