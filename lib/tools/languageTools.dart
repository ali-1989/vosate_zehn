import 'package:app/tools/app/appLocale.dart';
import '/managers/settingsManager.dart';

class LanguageTools {
  LanguageTools._();

  static String getLanguageLocaleName() {
    final lanCode = SettingsManager.settingsModel.appLocale.languageCode;
    final Map<String, Map> languages = AppLocale.getAssetSupportedLanguages();

    for(var L in languages.entries){
      if(L.key == lanCode){
        return L.value['locale_name'];
      }
    }

    return 'English!';
  }
}
