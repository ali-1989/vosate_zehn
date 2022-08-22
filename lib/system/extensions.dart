// ignore_for_file: empty_catches

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/widgets/border/dottedBorder.dart';

import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appThemes.dart';
import '/managers/fontManager.dart';
import '/managers/settingsManager.dart';
import '/tools/app/appSizes.dart';

// usage: import 'package:common_version/tools/centers/extensions.dart';
///==========================================================================================================
extension StringExtension on String {
  String get L {
    return toLowerCase();
  }

  String get capitalize {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get unCapitalize {
    return '${this[0].toLowerCase()}${substring(1)}';
  }

  String get capitalizeFirstOfEach => split(' ').map((str) => str.capitalize).join(' ');

  int parseInt() {
    return int.parse(this);
  }

  String localeNum({Locale? locale}) {
    locale ??= SettingsManager.settingsModel.appLocale;

    if (LocaleHelper.isRtlLocal(locale)) {
      return LocaleHelper.numberToFarsi(this);
    }

    return this;
  }
}
///==========================================================================================================
extension FunctionExtension on Function {
  /// (await fn.delay()).call(args);
  Future<Function> delay({Duration dur = const Duration(milliseconds: 180)}) {
    return Future.delayed(dur, () => this);
  }
}
///==========================================================================================================
extension ContextExtension on BuildContext {
  void nextEditableTextFocus() {
    do {
      final foundFocusNode = FocusScope.of(this).nextFocus();

      if (!foundFocusNode) {
        return;
      }
    }
    while (FocusScope.of(this).focusedChild?.context?.widget is! EditableText);
  }
  //--------------------------------------------------
  String? t(String key, {String? key2, String? key3}) {
    var res1 = AppLocale.appLocalize.translate(key);

    if(res1 == null) {
      return null;
    }

    if(key2 != null) {
      res1 += ' ${AppLocale.appLocalize.translate(key2)?? ''}';
    }

    if(key3 != null) {
      res1 += ' ${AppLocale.appLocalize.translate(key3)?? ''}';
    }

    return res1;
  }
  //--------------------------------------------------
  String? tC(String key, {String? key2, String? key3}) {
    var res1 = AppLocale.appLocalize.translateCapitalize(key);

    if(res1 == null) {
      return null;
    }

    if(key2 != null) {
      res1 += ' ${AppLocale.appLocalize.translate(key2)?? ''}';
    }

    if(key3 != null) {
      res1 += ' ${AppLocale.appLocalize.translate(key3)?? ''}';
    }

    return res1;
  }
  //--------------------------------------------------
  Map<String, dynamic>? tAsMap(String key) {
    return AppLocale.appLocalize.translateMap(key);
  }

  Map<String, String>? tAsStringMap(String key, String subMapKey) {
    final res = tAsMap(key)?[subMapKey];

    if(res is Map){
      return res.map<String, String>((key, value) => MapEntry(key, value.toString()));
    }

    return res;
  }

  String? tInMap(String key, String subKey) {
    return tAsMap(key)?[subKey];
  }

  dynamic tDynamicOrFirst(String key, String subKey) {
    final list = tAsMap(key);

    if(list == null) {
      return null;
    }

    final Iterable<MapEntry> tra = list.entries;
    MapEntry? find;

    try {
      find = tra.firstWhere((element) {
        return element.key == subKey;
      });
    }
    catch (e){}

    if(find != null) {
      return find.value;
    }

    return tra.first.value;
  }

  String? tJoin(String key, {String join = ''}) {
    final list = tAsMap(key);

    if(list == null) {
      return null;
    }

    var res = '';

    for (var s in list.entries) {
      res += s.value.toString() + join;
    }

    res = res.replaceFirst(RegExp(join), '');

    return res;
  }
}
///==========================================================================================================
extension IterableExtension<E> on Iterable<E> {
  E? firstWhereSafe(bool Function(E element) test) {
    try {
      return firstWhere(test);
    }
    catch (e){
      return null;
    }
  }
}
///==========================================================================================================
extension RowExtension<E> on Row {
  Row min() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      children: children,
    );
  }
}
///==========================================================================================================
extension ColumnExtension<E> on Column {
  Column min() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      children: children,
    );
  }
}
///==========================================================================================================
extension WidgetExtension on Widget {
  Widget wrapMaterial({
    MaterialType type = MaterialType.circle,
    VoidCallback? onTapDelay,
    Color? splashColor,
    Color? materialColor,
    EdgeInsets padding = const EdgeInsets.all(8.0),
  }) {
    materialColor ??= Colors.transparent;
    splashColor ??= AppThemes.instance.currentTheme.differentColor;

    return Material(
      color: materialColor,
      clipBehavior: Clip.antiAlias,
      borderOnForeground: true,
      elevation: 0,
      type: type,

      child: InkWell(
        splashColor: splashColor,
        canRequestFocus: true,
        autofocus: true,
        onTap: () {
          if (onTapDelay != null) {
            Future.delayed(const Duration(milliseconds: 150), () {
              onTapDelay.call();
            });
          }
        },
        child: Padding(
          padding: padding,
          child: this,
        ),
      ),
    );
  }
  ///----------------------------------------------------------
  Widget wrapBoxBorder({
    double radius = 10.0,
    int alpha = 200,
    double stroke = 0.8,
    Color? color,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
  }) {

    color ??= AppThemes.instance.currentTheme.fabBackColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.all(
          color: color.withAlpha(alpha),
          style: BorderStyle.solid,
          width: stroke,
        ),
      ),
      child: Padding(
        padding: padding,
        child: this,
      ),
    );
  }
  ///----------------------------------------------------------
  Widget wrapBackground({
    double radius = 12.0,
    double stroke = 0.4,
    Color? backColor,
    Color? borderColor,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
  }) {

    backColor ??= Colors.grey.withAlpha(190);
    borderColor ??= Colors.grey;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.all(
          color: borderColor,
          style: BorderStyle.solid,
          width: stroke,
        ),
      ),
      child: Padding(
        padding: padding,
        child: this,
      ),
    );
  }
  ///----------------------------------------------------------
  Widget wrapDotBorder({
    double radius = 10.0,
    int alpha = 200,
    double stroke = 0.8,
    Color? color,
    BorderType borderType = BorderType.rRect,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
  }) {

    color ??= AppThemes.instance.currentTheme.fabBackColor;

    return DottedBorder(
      dashPattern: const [6, 4, 6, 4],
      padding: padding,
      color: color.withAlpha(alpha),
      borderType: borderType,
      strokeCap: StrokeCap.round,
      strokeWidth: stroke,
      radius: Radius.circular(radius),
      child: this,
    );
  }
  ///----------------------------------------------------------
  Widget wrapListTileTheme({
    Color? iconColor,
    Color? textColor,
    }) {

    iconColor ??= AppThemes.instance.currentTheme.textColor.withAlpha(140);
    textColor ??= AppThemes.instance.currentTheme.textColor;

    return ListTileTheme(
      iconColor: iconColor,
      textColor: textColor,
      style: ListTileStyle.drawer,
      child: this,
    );
  }
}
///==========================================================================================================
extension DividerExtension on Divider {
  Divider intelliWhite() {
    Color replace;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      replace = Colors.white;
    }

    return Divider(
      key: key,
      color: replace,
      endIndent: endIndent,
      indent: indent,
      thickness: thickness,
      height: height,
    );
  }
}
///==========================================================================================================
extension IconExtension on Icon {
  Icon whiteOrAppBarItemOnPrimary() {
    Color replace;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      replace = Colors.white;
    }

    return Icon(
      icon,
      key: key,
      color: replace,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon whiteOrDifferentOnPrimary() {
    Color replace;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      replace = AppThemes.instance.currentTheme.differentColor;
    } else {
      replace = Colors.white;
    }

    return Icon(
      icon,
      key: key,
      color: replace,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon whiteOrDifferentOnBackColor() {
    Color replace;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.backgroundColor,
        [Colors.black, Colors.white, Colors.grey[200]!, Colors.grey[900]!])) {
      replace = AppThemes.instance.currentTheme.differentColor;
    } else {
      replace = Colors.white;
    }

    return Icon(
      icon,
      key: key,
      color: replace,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon primaryOrAppBarItemOnBackColor({Color? backColor}) {
    backColor ??= AppThemes.instance.currentTheme.backgroundColor;
    Color replace;

    if (ColorHelper.isNearColors(backColor, [AppThemes.instance.currentTheme.primaryColor])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      replace = AppThemes.instance.currentTheme.primaryColor;
    }

    return Icon(
      icon,
      key: key,
      color: replace,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon btnTextColor() {
    final replace = AppThemes.instance.currentTheme.buttonTextColor;

    return Icon(
      icon,
      key: key,
      color: replace,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon btnBackColor() {
    final replace = AppThemes.instance.currentTheme.buttonBackColor;

    return Icon(
      icon,
      key: key,
      color: replace,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon textColor() {
    final replace = AppThemes.instance.currentTheme.textColor;

    return Icon(
      icon,
      key: key,
      color: replace,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon toColor(Color c) {
    return Icon(
      icon,
      key: key,
      color: c,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon chipItemColor() {
    return Icon(
      icon,
      key: key,
      color: AppThemes.instance.themeData.chipTheme.deleteIconColor,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon info() {
    return Icon(
      icon,
      key: key,
      color: AppThemes.instance.currentTheme.infoTextColor,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon alpha({int alpha = 160}) {
    return Icon(
      icon,
      key: key,
      color: (color ?? AppThemes.instance.currentTheme.textColor).withAlpha(alpha),
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: size,
    );
  }

  Icon siz(double s) {
    return Icon(
      icon,
      key: key,
      color: color,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
      size: s,
    );
  }

  Icon rSiz(double s) {
    final cSiz = AppThemes.instance.themeData.iconTheme.size ?? 24;

    return siz(cSiz + s);
  }
}
///==========================================================================================================
extension TextExtension on Text {
  Text whiteOrAppBarItemOn(Color color) {
    Color replace;

    if(ColorHelper.isNearColors(color, [Colors.white, Colors.grey[200]!])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      replace = Colors.white;
    }

    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: replace);

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text whiteOrAppBarItemOnPrimary() {
    Color replace;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      replace = Colors.white;
    }

    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: replace);

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text whiteOrDifferentOnPrimary() {
    Color replace;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      replace = AppThemes.instance.currentTheme.differentColor;
    } else {
      replace = Colors.white;
    }

    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: replace);

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text whiteOrDifferentOnBackColor() {
    Color replace;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.backgroundColor,
        [Colors.black, Colors.white, Colors.grey[200]!, Colors.grey[900]!])) {
      replace = AppThemes.instance.currentTheme.differentColor;
    } else {
      replace = Colors.white;
    }

    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: replace);

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text primaryOrAppBarItemOnBackColor({Color? backColor}) {
    backColor ??= AppThemes.instance.currentTheme.backgroundColor;
    Color replace;

    if (ColorHelper.isNearColors(backColor, [AppThemes.instance.currentTheme.primaryColor])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      replace = AppThemes.instance.currentTheme.primaryColor;
    }

    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: replace);

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text infoColor() {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: AppThemes.instance.currentTheme.infoTextColor);

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text ltr() {
    return Text(
      data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: TextDirection.ltr,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text oneLineOverflow$Start({
    TextOverflow textOverflow = TextOverflow.fade,
    TextAlign textAlign = TextAlign.start,
    }) {

    return Text(
      data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: 1,
      overflow: textOverflow,
      semanticsLabel: semanticsLabel,
      softWrap: false,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text oneLineOverflow$End({
    TextOverflow textOverflow = TextOverflow.fade,
    TextAlign textAlign = TextAlign.end,
    }) {

    return Text(
      data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: 1,
      overflow: textOverflow,
      semanticsLabel: semanticsLabel,
      softWrap: false,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text bold({FontWeight? weight = FontWeight.bold}) {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(fontWeight: weight); // FontWeight.w900 is bigger then FontWeight.bold

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text subAlpha([int alpha = 160]) {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;

    ts = ts.copyWith(
        //fontWeight: FontWeight.bold,
        color: ts.color?.withAlpha(alpha)
    );

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      //textAlign: center ? TextAlign.center : textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text subFont() {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;

    ts = ts.copyWith(
        fontFamily: AppThemes.instance.currentTheme.subTextStyle.fontFamily,
    );

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text boldFont() {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;

    ts = ts.copyWith(
        fontFamily: AppThemes.instance.currentTheme.boldTextStyle.fontFamily,
    );

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text defFont() {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;

    ts = ts.copyWith(
        fontFamily: FontManager.instance.getPlatformFont().family!,
    );

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text englishFont() {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;

    ts = ts.copyWith(
        fontFamily: FontManager.instance.getEnglishFont()!.family!,
    );

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text underLineClickable() {
    return bold()
        .fsR(4)// fs(18)
        .color(AppThemes.instance.currentTheme.underLineDecorationColor);
  }

  Text fs(double size) {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(fontSize: AppSizes.fwFontSize(size));

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text fsR(double size, {double? max /*20*/}) {
    final ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    var siz = ts.fontSize;
    siz ??= AppThemes.instance.currentTheme.baseTextStyle.fontSize;

    siz = siz! + size;

    if (max != null) {
      siz = MathHelper.minDouble(siz, max);
    }

    return fs(siz);
  }

  Text alpha({int alpha = 160}) {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: ts.color!.withAlpha(alpha));

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text color(Color v) {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: v);

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  Text lineHeight(double v) {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(height: v);

    return Text(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }
}
///==========================================================================================================
extension TextFieldExtension on TextField {
  TextField intelliWhite() {
    Color replace;

    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    var dec = decoration ?? const InputDecoration();

    replace = Colors.white;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    }

    ts = ts.copyWith(color: replace);

    final border = dec.border?? AppThemes.instance.themeData.inputDecorationTheme.border;
    final enabledBorder = dec.enabledBorder?? AppThemes.instance.themeData.inputDecorationTheme.enabledBorder;
    final disabledBorder = dec.disabledBorder?? AppThemes.instance.themeData.inputDecorationTheme.disabledBorder;
    final errorBorder = dec.errorBorder?? AppThemes.instance.themeData.inputDecorationTheme.errorBorder;
    final focusedBorder = dec.focusedBorder?? AppThemes.instance.themeData.inputDecorationTheme.focusedBorder;
    final focusedErrorBorder = dec.focusedErrorBorder?? AppThemes.instance.themeData.inputDecorationTheme.focusedErrorBorder;

    dec = InputDecoration(
      border: border?.copyWith(borderSide: border.borderSide.copyWith(color: replace)),
      enabledBorder: enabledBorder?.copyWith(borderSide: enabledBorder.borderSide.copyWith(color: replace)),
      disabledBorder: disabledBorder?.copyWith(borderSide: disabledBorder.borderSide.copyWith(color: replace)),
      errorBorder: errorBorder?.copyWith(borderSide: errorBorder.borderSide.copyWith(color: replace)),
      focusedBorder: focusedBorder?.copyWith(borderSide: focusedBorder.borderSide.copyWith(color: replace)),
      focusedErrorBorder: focusedErrorBorder?.copyWith(borderSide: focusedErrorBorder.borderSide.copyWith(color: replace)),
      alignLabelWithHint: dec.alignLabelWithHint,
      contentPadding: dec.contentPadding,
      counter: dec.counter,
      counterStyle: dec.counterStyle,
      counterText: dec.counterText,
      fillColor: dec.fillColor,
      filled: dec.filled,
      prefix: dec.prefix,
      prefixIcon: dec.prefixIcon,
      prefixStyle: dec.prefixStyle,
      prefixText: dec.prefixText,
      prefixIconConstraints: dec.prefixIconConstraints,
      suffix: dec.suffix,
      suffixStyle: dec.suffixStyle,
      suffixText: dec.suffixText,
      suffixIcon: dec.suffixIcon,
      suffixIconConstraints: dec.suffixIconConstraints,
      floatingLabelBehavior: dec.floatingLabelBehavior,
      semanticCounterText: dec.semanticCounterText,
      labelText: dec.labelText,
      labelStyle: dec.labelStyle,
      isDense: dec.isDense,
      isCollapsed: dec.isCollapsed,
      hintText: dec.hintText,
      hintStyle: dec.hintStyle,
      hintMaxLines: dec.hintMaxLines,
      helperText: dec.helperText,
      helperStyle: dec.helperStyle,
      helperMaxLines: dec.helperMaxLines,
    );

    return TextField(
      key: key,
      controller: controller,
      style: ts,
      strutStyle: strutStyle,
      decoration: dec,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      keyboardAppearance: keyboardAppearance,
      textAlign: textAlign,
      cursorColor: replace,
      cursorWidth: cursorWidth,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onTap: onTap,
      onAppPrivateCommand: onAppPrivateCommand,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      buildCounter: buildCounter,
      toolbarOptions: toolbarOptions,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      autocorrect: autocorrect,
    );
  }
}
///==========================================================================================================
extension TextFormFieldExtension on TextFormField {
  TextFormField intelliWhite() {
    final my = this as TextField;
    var replace = Colors.white;

    var ts = my.style ?? AppThemes.instance.currentTheme.baseTextStyle;
    var dec = my.decoration ?? const InputDecoration();

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    }

    ts = ts.copyWith(color: replace);

    final border = dec.border?? AppThemes.instance.themeData.inputDecorationTheme.border;
    final enabledBorder = dec.enabledBorder?? AppThemes.instance.themeData.inputDecorationTheme.enabledBorder;
    final disabledBorder = dec.disabledBorder?? AppThemes.instance.themeData.inputDecorationTheme.disabledBorder;
    final errorBorder = dec.errorBorder?? AppThemes.instance.themeData.inputDecorationTheme.errorBorder;
    final focusedBorder = dec.focusedBorder?? AppThemes.instance.themeData.inputDecorationTheme.focusedBorder;
    final focusedErrorBorder = dec.focusedErrorBorder?? AppThemes.instance.themeData.inputDecorationTheme.focusedErrorBorder;

    dec = InputDecoration(
      border: border?.copyWith(borderSide: border.borderSide.copyWith(color: replace)),
      enabledBorder: enabledBorder?.copyWith(borderSide: enabledBorder.borderSide.copyWith(color: replace)),
      disabledBorder: disabledBorder?.copyWith(borderSide: disabledBorder.borderSide.copyWith(color: replace)),
      errorBorder: errorBorder?.copyWith(borderSide: errorBorder.borderSide.copyWith(color: replace)),
      focusedBorder: focusedBorder?.copyWith(borderSide: focusedBorder.borderSide.copyWith(color: replace)),
      focusedErrorBorder: focusedErrorBorder?.copyWith(borderSide: focusedErrorBorder.borderSide.copyWith(color: replace)),
        alignLabelWithHint: dec.alignLabelWithHint,
        contentPadding: dec.contentPadding,
        counter: dec.counter,
        counterStyle: dec.counterStyle,
        counterText: dec.counterText,
        fillColor: dec.fillColor,
        filled: dec.filled,
        prefix: dec.prefix,
        prefixIcon: dec.prefixIcon,
        prefixStyle: dec.prefixStyle,
        prefixText: dec.prefixText,
        prefixIconConstraints: dec.prefixIconConstraints,
        suffix: dec.suffix,
        suffixStyle: dec.suffixStyle,
        suffixText: dec.suffixText,
        suffixIcon: dec.suffixIcon,
        suffixIconConstraints: dec.suffixIconConstraints,
        floatingLabelBehavior: dec.floatingLabelBehavior,
        semanticCounterText: dec.semanticCounterText,
        labelText: dec.labelText,
        labelStyle: dec.labelStyle,
        isDense: dec.isDense,
        isCollapsed: dec.isCollapsed,
        hintText: dec.hintText,
        hintStyle: dec.hintStyle,
        hintMaxLines: dec.hintMaxLines,
        helperText: dec.helperText,
        helperStyle: dec.helperStyle,
        helperMaxLines: dec.helperMaxLines,
      );
    
    return TextFormField(
      //key: this.key,
      controller: controller,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      validator: validator,
      initialValue: initialValue,
      decoration: dec,
      style: ts,
      strutStyle: my.strutStyle,
      textInputAction: my.textInputAction,
      keyboardType: my.keyboardType,
      keyboardAppearance: my.keyboardAppearance,
      textAlign: my.textAlign,
      cursorColor: replace,
      cursorWidth: my.cursorWidth,
      onChanged: my.onChanged,
      onEditingComplete: my.onEditingComplete,
      onTap: my.onTap,
      inputFormatters: my.inputFormatters,
      autofillHints: my.autofillHints,
      buildCounter: my.buildCounter,
      toolbarOptions: my.toolbarOptions,
      focusNode: my.focusNode,
      autofocus: my.autofocus,
      readOnly: my.readOnly,
      autocorrect: my.autocorrect,
    );
  }
}
///==========================================================================================================
extension DropdownButtonExtension on DropdownButton {
  Widget wrap(
    BuildContext context, {
    double width = 130,
    double radius = 5,
    Color? backColor,
    Color? arrowColor,
  }) {

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      arrowColor ??= AppThemes.instance.currentTheme.appBarItemColor;
    }
    else {
      arrowColor ??= Colors.white;
    }

    final back = backColor?? ColorHelper.changeLight(AppThemes.instance.themeData.colorScheme.secondary); //primaryColor

    void fn(){
      FocusHelper.unFocus(context);
      FocusHelper.hideKeyboardByService();

      onTap?.call();
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: AppThemes.dropdownDecoration(color: back, radius: radius),
      child: Theme(
        data: AppThemes.dropdownTheme(context, color: back),
        child: DropdownButton(
          items: items,
          value: value,
          isExpanded: true,
          selectedItemBuilder: selectedItemBuilder,
          iconDisabledColor: iconDisabledColor?? arrowColor,
          iconEnabledColor: iconEnabledColor?? arrowColor,
          dropdownColor: dropdownColor,
          isDense: isDense,
          onChanged: onChanged,
          onTap: fn,
          elevation: elevation,
          icon: icon,
          iconSize: iconSize,
          autofocus: autofocus,
          focusNode: focusNode,
          focusColor: focusColor,
          underline: underline?? const SizedBox(),
          style: style,
          itemHeight: itemHeight,
          hint: hint,
          disabledHint: disabledHint,
        ),
      ),
    );
  }
}
///==========================================================================================================
extension RadioExtension on Radio {
  Radio intelliWhite<T>() {
    Color replace;

    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor,
        [Colors.grey[900]!, Colors.white, Colors.grey[600]!])) {
      replace = AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      replace = Colors.white;
    }

    return Radio<T>(
      key: key,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: replace,
      fillColor:  MaterialStateProperty.all(replace),
      hoverColor: hoverColor,
      overlayColor: overlayColor,
      focusColor: focusColor,
      autofocus: autofocus,
      focusNode: focusNode,
      materialTapTargetSize: materialTapTargetSize,
      mouseCursor: mouseCursor,
      splashRadius: splashRadius,
      toggleable: toggleable,
      visualDensity: visualDensity,
    );
  }
}
///==========================================================================================================
