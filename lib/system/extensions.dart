import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/widgets/border/dotted_border.dart';

import 'package:app/managers/font_manager.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_locale.dart';
import 'package:app/tools/app/app_themes.dart';

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
    /*locale ??= SettingsManager.localSettings.appLocale;

    if (LocaleHelper.isRtlLocal(locale)) {
      return LocaleHelper.numberToFarsi(this);
    }

    return this;*/
    return AppLocale.numberRelative(this)?? this;
  }
}
///==========================================================================================================
extension FunctionExtension on Function {
  /// (await fn.delay()).call(args);
  Future<Function> delay({Duration dur = const Duration(milliseconds: 200)}) {
    return Future.delayed(dur, () => this);
  }
}
///==========================================================================================================
extension ContextExtension on BuildContext {
  void focusNextEditableText() {
    do {
      final foundFocusNode = FocusScope.of(this).nextFocus();

      if (!foundFocusNode) {
        return;
      }
    }
    while (FocusScope.of(this).focusedChild?.context?.widget is! EditableText);
  }

  bool get isMounted {
    try {
      widget;
      return true;
    }
    catch (e) {
      return false;
    }
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
    return AppLocale.appLocalize.translateAsMap(key);
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
    catch (e){/**/}

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
    double radius = 6.0,
    int alpha = 200,
    double stroke = 1.0,
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
    double radius = 6.0,
    int alpha = 200,
    double stroke = 1.0,
    Color? color,
    BorderType borderType = BorderType.rRect,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    List<double> dashPattern = const [6, 4],
  }) {

    color ??= AppThemes.instance.currentTheme.fabBackColor;

    return DottedBorder(
      dashPattern: dashPattern,
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
extension IconExtension on Icon {
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

  Text infoColor({bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
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

  Text bold({FontWeight? weight = FontWeight.bold, bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
    ts = ts.copyWith(fontWeight: weight);

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

  Text font(String family, {bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
    final font = FontManager.instance.fontByFamily(family) ?? FontManager.instance.getPlatformFont();

    ts = ts.copyWith(
      fontFamily: font.family,
      height: style?.height ?? font.height,
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

  Text thinFont({bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());

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

  Text boldFont({bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());

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

  Text platformFont() {
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

  Text fs(double size, {bool baseStyle = false}) {
    var ts = style ??  (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
    ts = ts.copyWith(fontSize: size);

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
    var siz = style?.fontSize?? AppThemes.instance.currentTheme.baseTextStyle.fontSize;
    siz = (siz?? FontManager.appFontSize()) + size;

    if (max != null) {
      siz = MathHelper.minDouble(siz, max);
    }

    return fs(siz);
  }

  Text alpha({int alpha = 160, bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
    final color = ts.color?? AppThemes.instance.currentTheme.baseTextStyle.color;

    ts = ts.copyWith(color: color!.withAlpha(alpha));

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

  Text color(Color v, {int? alpha}) {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: alpha != null ? v.withAlpha(alpha) : v);

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

  Widget fitWidthOverflow({double? maxWidth, double? minOfFontSize}) {
    return LayoutBuilder(
      builder: (context, size){
        final defaultTextStyle = DefaultTextStyle.of(context);

        var myStyle = style;
        if (style == null || style!.inherit) {
          myStyle = defaultTextStyle.style.merge(style);
        }

        if (myStyle!.fontSize == null) {
          myStyle = myStyle.copyWith(fontSize: FontManager.appFontSize());
        }

        var tp = TextPainter(
          maxLines: maxLines,
          textAlign: textAlign?? AppThemes.getTextAlign(),
          textDirection: textDirection?? AppThemes.instance.textDirection,
          textHeightBehavior: textHeightBehavior,
          strutStyle: strutStyle,
          locale: locale,
          textScaleFactor: textScaleFactor?? MediaQuery.of(context).textScaleFactor,
          textWidthBasis: textWidthBasis?? TextWidthBasis.parent,
          text: TextSpan(text: data, style: myStyle),
        );

        tp.layout(maxWidth: double.infinity);
        bool exceeded = tp.didExceedMaxLines || tp.width > (maxWidth?? size.maxWidth);
        double fontSize = myStyle.fontSize!;

        while(exceeded){
          fontSize = fontSize -.5;
          myStyle = myStyle!.copyWith(fontSize: fontSize);

          if(minOfFontSize != null && fontSize < minOfFontSize){
            break;
          }

          tp = TextPainter(
            maxLines: maxLines,
            textAlign: textAlign?? AppThemes.getTextAlign(),
            textDirection: textDirection?? AppThemes.instance.textDirection,
            textHeightBehavior: textHeightBehavior,
            strutStyle: strutStyle,
            locale: locale,
            textScaleFactor: textScaleFactor?? MediaQuery.of(context).textScaleFactor,
            textWidthBasis: textWidthBasis?? TextWidthBasis.parent,
            text: TextSpan(text: data, style: myStyle),
          );

          tp.layout(maxWidth: double.infinity);
          exceeded = tp.didExceedMaxLines || tp.width > (maxWidth?? size.maxWidth);
        }

        return Text(
          data!,
          key: key,
          style: myStyle,
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
      },
    );
  }

  Text lineHeight(double v, {bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
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

  Text underLineClickable() {
    return bold()
        .fsR(4)// fs(18)
        .color(AppThemes.instance.currentTheme.underLineDecorationColor);
  }
}
///==========================================================================================================
extension SelectableTextExtension on SelectableText {

  SelectableText infoColor({bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
    ts = ts.copyWith(color: AppThemes.instance.currentTheme.infoTextColor);

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText ltr() {
    return SelectableText(
      data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: TextDirection.ltr,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText oneLineOverflow$Start({
    TextOverflow textOverflow = TextOverflow.fade,
    TextAlign textAlign = TextAlign.start,
    }) {

    return SelectableText(
      data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: 1,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText oneLineOverflow$End({
    TextOverflow textOverflow = TextOverflow.fade,
    TextAlign textAlign = TextAlign.end,
    }) {

    return SelectableText(
      data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: 1,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText bold({FontWeight? weight = FontWeight.bold, bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
    ts = ts.copyWith(fontWeight: weight); // FontWeight.w900 is bigger then FontWeight.bold

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText thinFont({bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());

    ts = ts.copyWith(
        fontFamily: AppThemes.instance.currentTheme.subTextStyle.fontFamily,
    );

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText boldFont({bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());

    ts = ts.copyWith(
        fontFamily: AppThemes.instance.currentTheme.boldTextStyle.fontFamily,
    );

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText platformFont() {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;

    ts = ts.copyWith(
        fontFamily: FontManager.instance.getPlatformFont().family!,
    );

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText englishFont() {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;

    ts = ts.copyWith(
        fontFamily: FontManager.instance.getEnglishFont()!.family!,
    );

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

 SelectableText fs(double size, {bool baseStyle = false}) {
  var ts = style ??  (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
  ts = ts.copyWith(fontSize: size);


  return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText fsR(double size, {double? max /*20*/}) {
    var siz = style?.fontSize;
    siz ??= AppThemes.instance.currentTheme.baseTextStyle.fontSize;

    siz = (siz?? FontManager.appFontSize()) + size;

    if (max != null) {
      siz = MathHelper.minDouble(siz, max);
    }

    return fs(siz);
  }

  SelectableText alpha({int alpha = 160, bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
    final color = ts.color?? AppThemes.instance.currentTheme.baseTextStyle.color;

    ts = ts.copyWith(color: color!.withAlpha(alpha));

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText color(Color v, {int? alpha}) {
    var ts = style ?? AppThemes.instance.currentTheme.baseTextStyle;
    ts = ts.copyWith(color: alpha != null ? v.withAlpha(alpha) : v);

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText lineHeight(double v, {bool baseStyle = false}) {
    var ts = style ?? (baseStyle ? AppThemes.instance.currentTheme.baseTextStyle : const TextStyle());
    ts = ts.copyWith(height: v);

    return SelectableText(
      data!,
      key: key,
      style: ts,
      strutStyle: strutStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  SelectableText underLineClickable() {
    return bold()
        .fsR(4)// fs(18)
        .color(AppThemes.instance.currentTheme.underLineDecorationColor);
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
    EdgeInsets? padding,
  }) {

    arrowColor ??= AppDecoration.dropdownArrowColor();
    backColor ??= AppDecoration.dropdownBackColor();
    padding ??= const EdgeInsets.symmetric(horizontal: 4, vertical: 0);

    void fn(){
      FocusHelper.unFocus(context);
      FocusHelper.hideKeyboardByService();

      onTap?.call();
    }

    return Container(
      width: width,
      padding: padding,
      decoration: AppDecoration.dropdownDecoration(color: backColor, radius: radius),
      child: Theme(
        data: AppDecoration.dropdownTheme(context, color: backColor),
        child: DropdownButton(
          items: items,
          value: value,
          isExpanded: isExpanded,
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
extension TextHeightBehaviorExtension on TextHeightBehavior {
  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'applyHeightToFirstAscent': applyHeightToFirstAscent,
      'applyHeightToLastDescent': applyHeightToLastDescent,
    };
  }

  TextHeightBehavior? fromMap(Map<String, dynamic>? map){
    if(map == null){
      return null;
    }

    return TextHeightBehavior(
        applyHeightToLastDescent: map['applyHeightToLastDescent'],
        applyHeightToFirstAscent: map['applyHeightToFirstAscent']
    );
  }
}
