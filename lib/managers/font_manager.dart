import 'package:flutter/material.dart';

import 'package:iris_tools/api/managers/fonts_manager.dart';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_themes.dart';

class FontManager extends FontsManager {
  FontManager._({
    super.startFontSize,
    super.maximumAppFontSize,
    super.minimumAppFontSize,
    super.webScreenWidth,
  }) : super() {
    _prepareFontList();
  }

  static late final FontManager _instance;
  static bool _calledInit = false;

  static init({double? startFontSize, double? maxFontSize, double? minFontSize, double? webWidth, required bool calcFontSize}){
    if(!_calledInit){
      _calledInit = true;

      final temp = FontsManager();
      _instance = FontManager._(
          startFontSize: startFontSize,
          maximumAppFontSize: maxFontSize?? temp.maximumAppFontSize,
          minimumAppFontSize: minFontSize?? temp.minimumAppFontSize,
          webScreenWidth: webWidth
      );

      if(calcFontSize){
        _instance.calcFontSize();
      }
    }
  }

  static FontManager get instance {
    if(!_calledInit){
      assert(false, 'FontManager is not initialized.');
    }

    return _instance;
  }

  void _prepareFontList() {
    if(fontList().isNotEmpty){
      return;
    }

    /// family: family name in [pubspec.yaml]   *** family match is important, case insensitive

    final fs = appFontSizeOrRelative();

    /*final atlanta = Font.bySize(fs)
        ..family = 'Atlanta'
        ..defaultLanguage = 'en'
        ..defaultUsage = 'base'
        ..usages = ['sub'];

      */
    //------------- fa -------------------------------------------------
    final iranSans = Font.bySize(fs)
      ..family = 'IranSans'
      ..defaultLanguage = 'fa'
      ..defaultUsage = FontUsage.regular
      ..usages = [FontUsage.thin, FontUsage.bold]
      ..textHeightBehavior = const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false)
      ..height = 1.4;

    final sans = Font.bySize(fs)
      ..family = 'Sans'
      ..defaultLanguage = 'fa'
      ..defaultUsage = FontUsage.thin;

    final icomoon = Font.bySize(fs)
      ..family = 'Icomoon'
      ..defaultLanguage = 'fa'
      ..defaultUsage = FontUsage.regular
      ..usages = [FontUsage.thin, FontUsage.bold];

    addFont(iranSans);
    addFont(sans);
    addFont(icomoon);

    var rawDef = getPlatformFont().family;

    try {
      final findIdx = fontList().toList().indexWhere((font) => font.family == rawDef);

      if (findIdx < 0) { // && rawDef != def
        addFont(getPlatformFont());
      }
    }
    catch (e){/**/}
  }

  static Future<bool> saveFontThemeData(String lang) async {
    var dbData = AppDB.fetchKv(Keys.setting$fontThemeData);
    dbData ??= {};

    final Map dataJs = dbData[lang]?? <String, dynamic>{};
    dbData[lang] = dataJs;

    dataJs['UserBaseFont'] = AppThemes.instance.baseFont.toMap();
    dataJs['UserThinFont'] = AppThemes.instance.lightFont.toMap();
    dataJs['UserBoldFont'] = AppThemes.instance.boldFont.toMap();

    final dynamic res = await AppDB.setReplaceKv(Keys.setting$fontThemeData, dbData);

    return res > 0;
  }

  static Future<void> fetchFontThemeData(String lang) async {
    var res = AppDB.fetchKv(Keys.setting$fontThemeData);

    if(res != null) {
      final Map data = res[lang] ?? <String, dynamic>{};

      AppThemes.instance.baseFont = Font.fromMap(data['UserBaseFont']);
      AppThemes.instance.lightFont = Font.fromMap(data['UserThinFont']);
      AppThemes.instance.boldFont = Font.fromMap(data['UserBoldFont']);
    }

    if(AppThemes.instance.baseFont.family == null) {
      AppThemes.instance.baseFont = FontManager.instance.defaultFontFor(lang, FontUsage.regular);
    }

    if(AppThemes.instance.lightFont.family == null) {
      AppThemes.instance.lightFont = FontManager.instance.defaultFontFor(lang, FontUsage.thin);
    }

    if(AppThemes.instance.boldFont.family == null) {
      AppThemes.instance.boldFont = FontManager.instance.defaultFontFor(lang, FontUsage.bold);
    }
  }
}

