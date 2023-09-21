import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:material_dialogs/widgets/dialogs/dialog_widget.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_navigator.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/sheets/appSheetView.dart';
import 'package:app/views/sheets/sheet_custom_view.dart';

/* flutter:
>> showModalSheet()
>> showBottomSheet()
>> showModalBottomSheet()
>> showCupertinoModalPopup()

-- BottomSheet()
 */

class AppSheet {
  AppSheet._();

  static void closeSheet<T>(BuildContext context, {T? result}) {
    if(Navigator.of(context).canPop()){
      Navigator.of(context).pop(result);
    }
  }

  static void closeSheetByName<T>(BuildContext context, String routeName, {T? result}) {
    AppNavigator.popByRouteName(context, routeName, result: result);
  }

  static _SheetTheme _genTheme() {
    return _SheetTheme();
  }
  ///======= flutter api ==========================================================================================
  static PersistentBottomSheetController<T> showBottomSheetInScaffold<T>(
      BuildContext ctx,
      Widget Function(BuildContext context) builder, {
      Color? backgroundColor,
      double elevation = 0.0,
      ShapeBorder? shape,
      }) {
    return showBottomSheet<T>(
      context: ctx,
      shape: shape,
      constraints: AppSizes.isBigWidth()? BoxConstraints.tightFor(width: AppSizes.webMaxWidthSize) : null,
      clipBehavior: shape != null ? Clip.antiAlias : Clip.none,
      elevation: elevation,
      backgroundColor: backgroundColor ?? Colors.transparent,
      builder: builder,
    );
  }

  static Future<T?> showCupertinoModalPopup$<T>(
      BuildContext context,
      Widget view, {
      Color? dimColor,
      bool dismissible = true,
      RouteSettings? routeSettings,
      }) {
    final res = showCupertinoModalPopup<T>(
      context: context,
      barrierColor: dimColor ?? Colors.black12,
      barrierDismissible: dismissible,
      routeSettings: routeSettings,
      builder: (BuildContext context){
        return view;
      },
    );

    return res;
  }

  static Future<T?> showModalBottomSheet$<T>(
      BuildContext context, {
        required Widget Function(BuildContext context) builder,
        Color? backgroundColor,
        Color? barrierColor,
        double elevation = 1.0,
        ShapeBorder? shape,
        String routeName = 'ModalBottomSheet',
        bool useRootNavigator = false,
        bool isDismissible = true,
        /** isScrollControlled:
          if false: on small sheet show elevation to center page
          if true can have full screen, can use TextField  **/
        bool isScrollControlled = true,
      }) {
    FocusHelper.hideKeyboardByUnFocus(context);

    return showModalBottomSheet<T>(
        context: context,
        builder: builder,
        elevation: elevation,
        shape: shape,
        enableDrag: true,
        constraints: AppSizes.isBigWidth()? BoxConstraints.tightFor(width: AppSizes.webMaxWidthSize) : null,
        isDismissible: isDismissible,
        clipBehavior: shape != null ? Clip.antiAlias : Clip.none,
        backgroundColor: backgroundColor ?? Colors.transparent,
        barrierColor: barrierColor,
        routeSettings: RouteSettings(name: routeName),
        isScrollControlled: isScrollControlled,
        useRootNavigator: useRootNavigator, // if false: sheet show under bottom bar and not show fully
    );
  }

  ///======== flutter api | =====================================================================================
  /// T: is returned value from Navigator.Pop()
  static Future<T?> showSheetOneAction<T>(
      BuildContext context,
      String message, {
        VoidCallback? onButton,
        String? title,
        String? buttonText,
        bool dismissOnAction = true,
        bool isDismissible = true,
        String? routeName,
      }) {

    buttonText ??= AppMessages.ok;
    final theme = _genTheme();

    void close() {
      RouteTools.popTopView(context: context);
      onButton?.call();
    }

    final txtStyle = AppDecoration.relativeSheetTextStyle();

    final posBtn = TextButton(
        onPressed: dismissOnAction ? close : onButton,
        child: Text(buttonText, style: txtStyle)
    );

    final content = Text(message, style: txtStyle);

    Widget? titleView;

    if (title != null) {
      titleView = Text(title, style: txtStyle.copyWith(fontSize: txtStyle.fontSize!+2));
    }

    var body = _buildBody(
      ctx :context,
      builder: (ctx) {
        return AppSheetCustomView(
          description: content,
          contentColor: theme.contentColor,
          title: titleView,
          positiveButton: posBtn,
        );
      },
      contentColor: theme.contentColor,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
    );

    return showModalBottomSheet$<T>(
      context,
      builder: (ctx) => body,
      isDismissible: isDismissible,
      isScrollControlled: false,
      routeName: routeName ?? Generator.generateKey(5),
      barrierColor: theme.barrierColor,
    );
  }

  static Future<T?> showSheetOk<T>(BuildContext context, String msg, {bool isDismissible = true,}) {
    return showSheetOneAction(context, msg, isDismissible: isDismissible);
  }

  static Future<T?> showSheetNotice<T>(BuildContext context, String msg, {bool isDismissible = true}) {
    return showSheetOneAction(context, msg, title: AppMessages.notice, isDismissible: isDismissible);
  }

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
      }) {
    final theme = _genTheme();

    void posClose() {
      RouteTools.popTopView(context: context);
      posFn?.call();
    }

    void negClose() {
      RouteTools.popTopView(context: context);
      negFn?.call();
    }

    posBtnText ??= AppMessages.yes;
    negBtnText ??= AppMessages.no;

    final ts = AppThemes.baseTextStyle().copyWith(
      color: ColorHelper.getUnNearColor(Colors.white, AppThemes.instance.currentTheme.primaryColor, Colors.black),
    );

    final posBtn = TextButton(onPressed: dismissOnAction ? posClose : posFn,
        child: Text(posBtnText, style: ts)
    );
    final negBtn = TextButton(onPressed: dismissOnAction ? negClose : negFn,
        child: Text(negBtnText, style: ts)
    );

    final body = _buildBody(
      ctx: context,
      builder: (ctx) {
        return AppSheetCustomView(
          description: msg,
          contentColor: theme.contentColor,
          title: title,
          positiveButton: posBtn,
          negativeButton: negBtn,
        );
      },
      contentColor: theme.contentColor,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
    );

    return showModalBottomSheet$<T>(
      context,
      builder: (ctx) => body,
      isDismissible: isDismissible,
      isScrollControlled: true,
      routeName: routeName ?? Generator.generateKey(5),
      barrierColor: theme.barrierColor,
    );
  }

  static Future<T?> showSheetCustom<T>(
      BuildContext context, {
        required Widget Function(BuildContext context) builder,
        required String routeName,
        Color? backgroundColor,
        Color? contentColor,
        Color? barrierColor,
        bool isDismissible = true,
        /// isScrollControlled: true if need TextField or Big height view
        bool isScrollControlled = false,
        ShapeBorder? shape,
        double elevation = 0.0,
        Text? title,
      }) {

    final theme = _genTheme();
    backgroundColor ??= Colors.transparent;
    barrierColor ??= theme.barrierColor;

    Widget buildBody(BuildContext sheetCtx){
      return _buildBody(
          ctx: sheetCtx,
          builder: builder,
          contentColor: contentColor?? theme.contentColor,
      );
    }

    return showModalBottomSheet$<T>(
      context,
      builder: (ctx) => buildBody(ctx),
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
  static Widget _buildBody({
    required BuildContext ctx,
    required Widget Function(BuildContext context) builder,
    required Color contentColor,
    EdgeInsets padding = EdgeInsets.zero,
      }) {
    
    return AppSheetView(childBuilder: builder, contentColor: contentColor);
  }

  ///=======================================================================================================
  static void showSheetMenu(
      BuildContext context,
      List<Widget> widgets,
      String routeName, {
        Color? backgroundColor,
        bool isDismissible = true,
        bool useRootNavigator = false,
        EdgeInsets? padding,
      }) {

    final view = BottomSheet(
      onClosing: () {},
      constraints: const BoxConstraints.tightFor(),
      shape: const RoundedRectangleBorder(
          side: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)
          )
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: padding?? const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widgets,
            ],
          ),
        );
      },
    ).wrapListTileTheme();

    showModalBottomSheet$(
      context,
      builder: (context) => view,
      routeName: routeName,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
    );
  }

  static Widget generateSheetMenu(
      BuildContext context,
      List<Widget> items, {
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
                        onTapDelay: () {
                          RouteTools.popTopView(context: context);
                        }
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

  ///======== third party package ===============================================================================
  static void showSheetDialog(
      BuildContext context, {
      String? title,
      String? message,
      bool dismissible = true,
      List<Widget>? actions,
  }) {

    final theme = _genTheme();

    showModalBottomSheet$(
        context,
        backgroundColor: Colors.white,
        builder: (ctx){
          return DialogWidget(
            actions: [...?actions],
            msg: message,
            title: title,
            color: theme.backgroundColor,
          );
        },
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16)
          )
      )
    );
  }
}
///======================================================================================================
class _SheetTheme {
  Color backgroundColor = Colors.white;
  Color contentColor = AppThemes.instance.currentTheme.primaryColor;
  Color buttonbarColor = AppThemes.instance.currentTheme.primaryColor;
  Color barrierColor = ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.black,])
      ? Colors.white.withAlpha(80)
      : Colors.black.withAlpha(150);

  _SheetTheme();
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
        RouteTools.pop();
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
