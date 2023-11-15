import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/modules/irisLocalizations.dart';

import 'package:app/structures/models/settings_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/route_tools.dart';
import '/managers/settings_manager.dart';
import '/tools/app/app_themes.dart';

class AppLocale {
  AppLocale._();

  static late final IrisLocaleDelegate localeDelegate;
  static const Locale englishLocal = Locale('en', 'US');
  static bool _isInit = false;

  static IrisLocalizations get appLocalize {
    return localeDelegate.getLocalization();
  }

  static void init() {
    if(!_isInit) {
      _isInit = true;
      localeDelegate = IrisLocaleDelegate((locale) => _isLocaleSupported(locale));
    }
  }

  /// this method help when system not found a key in en_US , search key in en_EE.
  /// note must exist en_US or fa_IR file, else take error.
  static Future<void> setFallBack() async {
    init();
    await localeDelegate.getLocalization().setFallbackByLocale(const Locale('en', 'EE'));
  }

  static bool _isLocaleSupported(Locale l) {
    return getAssetSupportedLanguages().containsKey(l.languageCode);
  }

  static Iterable<Locale> getAssetSupportedLocales() {
    /// must for any record ,create a file in assets/locales directory
    return SettingsModel.locals;
  }

  static Map<String, Map<String, String>> getAssetSupportedLanguages() {
    final res = <String, Map<String, String>>{};

    res.putIfAbsent('en', () => {'name': 'English', 'local_name': 'English'});
    res.putIfAbsent('fa', () => {'name': 'Persian', 'local_name': 'فارسی'});

    return res;
  }

  static List<LocalizationsDelegate<dynamic>> getLocaleDelegates() {
    init();

    return <LocalizationsDelegate<dynamic>>[
      localeDelegate,
      DefaultMaterialLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
    // https://flutter.dev/docs/development/accessibility-and-localization/internationalization
  }

  static Future<void> changeApplicationLanguage(String languageCode, {String? countryCode}) async {
    final list = getAssetSupportedLocales();

    final l = list.firstWhere((element) {
      if(countryCode == null || element.countryCode == null || element.countryCode!.isEmpty) {
        return element.languageCode == languageCode;
      }
      else {
        return element.languageCode == languageCode && element.countryCode == countryCode;
      }

    }, orElse: () => englishLocal);

    await localeDelegate.load(l);
    SettingsManager.localSettings.appLocale = l;
    AppThemes.instance.textDirection = detectLocaleDirection(l);
    SettingsManager.saveLocalSettingsAndNotify();
  }
  ///---------------------------------------------------------------------------
  static TextDirection detectLocaleDirection(Locale locale){
    if(LocaleHelper.rtlLanguageCode.contains(locale.languageCode)) {
      return TextDirection.rtl;
    }

    return TextDirection.ltr;
  }

  static Widget genDifferentLocale(BuildContext context, Locale locale, Widget child) {
    return IrisLocalizations.getCustomLocalization(context, locale, child);
  }

  static String? numberRelative(String? input){
    if(input == null) {
      return null;
    }

    final farsiList = <String>['fa', 'ps', 'ur'];
    final arabicList = <String>['ar'];

    if(farsiList.contains(SettingsManager.localSettings.appLocale.languageCode)) {
      return LocaleHelper.numberToFarsi(input);
    }

    if(arabicList.contains(SettingsManager.localSettings.appLocale.languageCode)) {
      return LocaleHelper.numberToArabic(input);
    }

    return LocaleHelper.numberToEnglish(input);
  }

  static String getLanguageLocalName() {
    final lanCode = SettingsManager.localSettings.appLocale.languageCode;
    final languages = AppLocale.getAssetSupportedLanguages();

    for(var L in languages.entries){
      if(L.key == lanCode){
        return L.value['local_name']?? '-';
      }
    }

    return 'English!';
  }

  static Map attachLanguageIso(Map src, {BuildContext? context}) {
    src[Keys.languageIso] = System.getLocalizationsLanguageCode(context ?? RouteTools.getTopContext()!);

    return src;
  }
}
