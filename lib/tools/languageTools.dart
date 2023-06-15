import 'package:app/system/keys.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/routeTools.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/system.dart';
import '/managers/settings_manager.dart';

class LanguageTools {
  LanguageTools._();

  static String getLanguageLocaleName() {
    final lanCode = SettingsManager.localSettings.appLocale.languageCode;
    final Map<String, Map> languages = AppLocale.getAssetSupportedLanguages();

    for(var L in languages.entries){
      if(L.key == lanCode){
        return L.value['locale_name'];
      }
    }

    return 'English!';
  }

  static Map addLanguageIso(Map src, [BuildContext? ctx]) {
    src[Keys.languageIso] = System.getLocalizationsLanguageCode(ctx ?? RouteTools.getTopContext()!);

    return src;
  }
}
