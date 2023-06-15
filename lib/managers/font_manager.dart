import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appThemes.dart';

class FontManager {
  FontManager._();

  static late final FontManager _instance;

  static final List<Font> _fontList = [];
  static late Font _platformDefaultFont;
  static late final TextTheme _rawTextTheme;
  static late final ThemeData _rawThemeData;
  static bool _calledInit = false;

  static _init(){
    if(!_calledInit){
      _createThemes();
      _prepareFontList();
      
      _calledInit = true;
      _instance = FontManager._();
    }
  }

  static FontManager get instance {
    _init();

    return _instance;
  }

  ThemeData get rawThemeData => _rawThemeData;
  TextTheme get rawTextTheme => _rawTextTheme;

  String getPlatformFontFamily(){
    BuildContext? context;

    try{
      context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
      context ??= WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;
      context ??= WidgetsBinding.instance.focusManager.rootScope.context;

      return getPlatformFontFamilyOf(context!)!;
    }
    catch (e){/**/}

    return (kIsWeb? 'Segoe UI' : 'Roboto'); // monospace
  }

  String? getPlatformFontFamilyOf(BuildContext context){
    return getDefaultTextStyleOf(context).style.fontFamily;
  }

  DefaultTextStyle getDefaultTextStyleOf(BuildContext context){
    return DefaultTextStyle.of(context);
  }

  List<Font> fontListFor(String language, FontUsage usage, bool onlyDefault) {
    final result = <Font>[];
    
    for(final fon in _fontList){
      var matchLanguage = fon.defaultLanguage == language;
      var matchUsage = fon.defaultUsage == usage;

      if(!matchLanguage && fon.defaultLanguage == null) {
        matchLanguage = fon.languages.isEmpty || fon.languages.contains(language);
      }

      if(!matchUsage && !onlyDefault) { // && fon.defaultUsage == null
        matchUsage = fon.usages.isEmpty || fon.usages.contains(usage);
      }

      if(matchLanguage && matchUsage){
        result.add(fon.clone());
      }
    }

    return result;
  }

  // defaultFontFor(Settings.appLocale.languageCode, FontUsage.sub);
  Font defaultFontFor(String language, FontUsage usage) {
    for(final fon in _fontList){
      final matchLanguage = fon.defaultLanguage == language;
      final matchUsage = fon.defaultUsage == usage;

      if(matchLanguage && matchUsage) {
        return fon.clone();
      }
    }

    for(final fon in _fontList){
      final matchLanguage = fon.defaultLanguage == language;
      final matchUsage = fon.usages.any((element) => element == usage);

      if(matchLanguage && matchUsage) {
        return fon.clone();
      }
    }

    return _platformDefaultFont.clone();
  }

  String defaultFontFamilyFor(String language, FontUsage usage) {
    return defaultFontFor(language, usage).family!;
  }

  Font getPlatformFont(){
    return _platformDefaultFont.clone();
  }

  Font? getEnglishFont(){
    return defaultFontFor('en', FontUsage.normal);
  }

  String? getEnglishFontFamily(){
    return getEnglishFont()?.family;
  }

  static void _prepareFontList() {
    if(_fontList.isNotEmpty){
      return;
    }

    /// family: any-name   fileName: font name in [pubspec.yaml]

    /*final atlanta = Font.bySize()
        ..family = 'Atlanta'
        ..fileName = 'Atlanta'
        ..defaultLanguage = 'en'
        ..defaultUsage = 'base'
        ..usages = ['sub'];

      */
    //------------- fa -------------------------------------------------
    final iranSans = Font.bySize()
      ..family = 'IranSans'
      ..fileName = 'IranSans'
      ..defaultLanguage = 'fa'
      ..defaultUsage = FontUsage.normal
      ..usages = [FontUsage.sub, FontUsage.bold]
      ..textHeightBehavior = const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false)
      ..height = 1.4;

    final sans = Font.bySize()
      ..family = 'Sans'
      ..fileName = 'Sans'
      ..defaultLanguage = 'fa'
      ..defaultUsage = FontUsage.sub;

    final icomoon = Font.bySize()
      ..family = 'Icomoon'
      ..fileName = 'Icomoon'
      ..defaultLanguage = 'fa'
      ..defaultUsage = FontUsage.normal
      ..usages = [FontUsage.sub, FontUsage.bold];

    _fontList.add(iranSans);
    _fontList.add(sans);
    _fontList.add(icomoon);

    var rawDef = _getDefaultFontFamily();

    try {
      final findIdx = _fontList.indexWhere((font) => font.family == rawDef);

      if (findIdx < 0) { // && rawDef != def
        _platformDefaultFont = Font.bySize()
          ..family = rawDef
          ..fileName = rawDef;

        _fontList.add(_platformDefaultFont);
      }
      else {
        _platformDefaultFont = _fontList[findIdx];
      }
    }
    catch (e){/**/}
  }

  static void _createThemes(){
    final fs = Font.getRelativeFontSize();
    final temp = ThemeData();
    const c1 = Colors.teal;
    final c2 = Colors.blue.shade700;

    _rawTextTheme = TextTheme(
      /// Drawer > ListTile {textColor}  [emphasizing text]
      bodyLarge: temp.textTheme.bodyLarge!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///default for Material
      bodyMedium: temp.textTheme.bodyMedium!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      /// images caption
      bodySmall: temp.textTheme.bodySmall!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      labelSmall: temp.textTheme.labelSmall!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///   [Extremely large]
      displayLarge: temp.textTheme.displayLarge!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///   [Very, very large]
      displayMedium: temp.textTheme.displayMedium!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      displaySmall: temp.textTheme.displaySmall!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      headlineMedium: temp.textTheme.headlineMedium!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      /// large text in dialogs (month and year ...)
      headlineSmall: temp.textTheme.headlineSmall!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///{appBar and dialogs} Title   (old = subtitle & subhead)
      titleLarge: temp.textTheme.titleLarge!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      /// textField, list
      titleMedium: temp.textTheme.titleMedium!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///       [medium emphasis]
      titleSmall: temp.textTheme.titleSmall!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      /// Buttons
      labelLarge: temp.textTheme.labelLarge!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
    );

    _rawThemeData = ThemeData.from(colorScheme: temp.colorScheme, textTheme: _rawTextTheme);
  }

  static String _getDefaultFontFamily(){
    var ff = _rawTextTheme.bodyLarge?.fontFamily;
    return ff ?? _rawTextTheme.bodyMedium?.fontFamily?? (kIsWeb? 'Segoe UI' : 'Roboto');
  }

  static Future<bool> saveFontThemeData(String lang) async {
    var dbData = AppDB.fetchKv(Keys.setting$fontThemeData);
    dbData ??= {};

    final Map dataJs = dbData[lang]?? <String, dynamic>{};
    dbData[lang] = dataJs;

    dataJs['UserBaseFont'] = AppThemes.instance.baseFont.toMap();
    dataJs['UserSubFont'] = AppThemes.instance.subFont.toMap();
    dataJs['UserBoldFont'] = AppThemes.instance.boldFont.toMap();

    final dynamic res = await AppDB.setReplaceKv(Keys.setting$fontThemeData, dbData);

    return res > 0;
  }

  static Future fetchFontThemeData(String lang) async {
    var res = AppDB.fetchKv(Keys.setting$fontThemeData);

    if(res == null) {
      /// can set app default font
      //AppThemes.baseFont.size = 14;
      //AppThemes.baseFont.family = 'Nazanin';
    }

    res ??= {};
    final Map data = res[lang]?? <String, dynamic>{};

    AppThemes.instance.baseFont = Font.fromMap(data['UserBaseFont']);
    AppThemes.instance.subFont = Font.fromMap(data['UserSubFont']);
    AppThemes.instance.boldFont = Font.fromMap(data['UserBoldFont']);

    if(AppThemes.instance.baseFont.family == null) {
      AppThemes.instance.baseFont = FontManager.instance.defaultFontFor(lang, FontUsage.normal);
    }

    if(AppThemes.instance.subFont.family == null) {
      AppThemes.instance.subFont = FontManager.instance.defaultFontFor(lang, FontUsage.sub);
    }

    if(AppThemes.instance.boldFont.family == null) {
      AppThemes.instance.boldFont = FontManager.instance.defaultFontFor(lang, FontUsage.bold);
    }

    return;
  }
}
///=====================================================================================================
enum FontUsage {
  normal,
  sub,
  bold;

  static FontUsage fromName(String name){
    for(final f in FontUsage.values){
      if(f.name == name){
        return f;
      }
    }

    return FontUsage.normal;
  }
}
///=====================================================================================================
class Font {
  String? family;
  String? fileName;
  double? height;
  double? size;
  FontUsage defaultUsage = FontUsage.normal;
  String? defaultLanguage;
  TextHeightBehavior? textHeightBehavior;
  List<String> languages = [];
  List<FontUsage> usages = [];

  Font();

  Font.bySize(){
    size = getRelativeFontSize();
  }

  Font.fromMap(Map? map){
    if(map == null){
      return;
    }

    family = map['family'];
    fileName = map['file_name'];
    size = map['size']?? 10;
    height = map['height'];
    textHeightBehavior = const TextHeightBehavior().fromMap(map['textHeightBehavior']);
    defaultUsage = FontUsage.fromName(map['default_usage']);
    defaultLanguage = map['default_language'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['family'] = family;
    map['file_name'] = fileName;
    map['size'] = size;
    map['height'] = height;
    map['textHeightBehavior'] = textHeightBehavior?.toMap();
    map['default_usage'] = defaultUsage.name;
    map['default_language'] = defaultLanguage;

    return map;
  }

  Font clone(){
    return Font.fromMap(toMap());
  }

  static double getRelativeFontSize() {
    final realPixelWidth = PlatformDispatcher.instance.implicitView!.physicalSize.width;
    final realPixelHeight = PlatformDispatcher.instance.implicitView!.physicalSize.height;
    final pixelRatio = PlatformDispatcher.instance.implicitView!.devicePixelRatio;
    final isLandscape = realPixelWidth > realPixelHeight;

    if(kIsWeb) {
      return 13;
    }
    else {
      final appHeight = (isLandscape ? realPixelWidth : realPixelHeight) / pixelRatio;
      return (appHeight / 100 /* ~6 */) + 4;    //  this is relative to any fonts
    }
  }
}
