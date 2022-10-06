import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';

import 'package:app/system/localizations.dart';
import '/managers/settingsManager.dart';
import '/tools/app/appThemes.dart';

class AppLocale {
  AppLocale._();

  static final IrisLocaleDelegate _localeDelegate = _prepare();

  static IrisLocaleDelegate localeDelegate() => _localeDelegate;

  static IrisLocalizations get appLocalize {
    return localeDelegate().getLocalization();
  }

  static IrisLocaleDelegate _prepare() {
    //rint('@@ this line must log once');
    return IrisLocaleDelegate((locale) => _isLocaleSupported(locale));
  }

  static bool _isLocaleSupported(Locale l) {
    return getAssetSupportedLanguages().containsKey(l.languageCode);
  }

  static Iterable<Locale> getAssetSupportedLocales() {
    /// must for any record ,create a file in assets/locales directory
    return [
      //const Locale('en', 'US'),
      const Locale('fa', 'IR'),
    ];
  }

  static Map<String, Map<String, String>> getAssetSupportedLanguages() {
    final res = <String, Map<String, String>>{};

    //getSupportedLocales().forEach((element) {
    //});
    res.putIfAbsent('en', () => {'name': 'English', 'locale_name': 'English'});
    res.putIfAbsent('fa', () => {'name': 'Persian', 'locale_name': 'فارسی'});

    return res;
  }

  static List<LocalizationsDelegate<dynamic>> getLocaleDelegates() {
    return <LocalizationsDelegate<dynamic>>[
      localeDelegate(),
      DefaultMaterialLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
    // https://flutter.dev/docs/development/accessibility-and-localization/internationalization
  }

  static Future changeApplicationLanguage(String languageCode, {String? countryCode}) async {
    final list = getAssetSupportedLocales();

    final l = list.firstWhere((element) {
      if(countryCode == null || element.countryCode == null || element.countryCode!.isEmpty) {
        return element.languageCode == languageCode;
      }
      else {
        return element.languageCode == languageCode && element.countryCode == countryCode;
      }

    }, orElse: () => const Locale('en', 'US'));

    SettingsManager.settingsModel.appLocale = l;
    await localeDelegate().load(l);
    detectLocaleDirection(l);
    SettingsManager.saveSettings();
  }
  ///------------------------------------------------------------------------------------
  static void detectLocaleDirection(Locale locale){
    if(LocaleHelper.rtlLanguageCode.contains(locale.languageCode)) {
      AppThemes.instance.textDirection = TextDirection.rtl;
    } else {
      AppThemes.instance.textDirection = TextDirection.ltr;
    }
  }

  static Widget genDifferentLocale(BuildContext context, Locale locale, Widget child) {
    return IrisLocalizations.getCustomLocalization(context, locale, child);
  }

  static String? numberRelative(dynamic input){
    if(input == null) {
      return null;
    }

    final text = input.toString();

    final farsiList = <String>['fa', 'ps', 'ur'];
    final arabicList = <String>['ar'];

    if(farsiList.contains(SettingsManager.settingsModel.appLocale.languageCode)) {
      return LocaleHelper.numberToFarsi(text);
    }

    if(arabicList.contains(SettingsManager.settingsModel.appLocale.languageCode)) {
      return LocaleHelper.numberToArabic(text);
    }

    return text;
  }
}
