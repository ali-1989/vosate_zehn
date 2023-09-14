import 'package:intl/intl.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/structures/models/country_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/country_tools.dart';

//import 'package:currency_formatter/currency_formatter.dart';

class CurrencyTools {
  CurrencyTools._();

  static String formatCurrency(num cur, {String name = '', String? symbol}){
    final format = NumberFormat.currency(
      locale: SettingsManager.localSettings.appLocale.languageCode,
      name: name,
      symbol: symbol,
      decimalDigits: 0,
      //customPattern: ,
    );

    return format.format(cur);
  }

  static String formatCurrencyString(String? cur, {String name = '', String? symbol}){
    if(cur == null || cur.isEmpty){
      return '';
    }

    return formatCurrency(MathHelper.clearToDouble(cur), name: name, symbol: symbol);
  }
  
  static CurrencyModel getCurrencyBy(String currencyCode, String countryIso) {
    final Map countryMap = CountryTools.countriesMap!;
    final itr = countryMap.entries;

    final res = CurrencyModel();
    res.currencyName = itr.first.value['currencyName'];
    res.currencySymbol = itr.first.value['currencySymbol'];
    res.currencyCode = itr.first.value['currencyCode'];
    res.countryIso = itr.first.value['iso'];

    itr.firstWhereSafe((country) {
      if(country.value['currencyCode'] == currencyCode && country.value['iso'] == countryIso) {
        res.currencyName = country.value['currencyName'];
        res.currencySymbol = country.value['currencySymbol'];
        res.currencyCode = country.value['currencyCode'];
        res.countryIso = country.value['iso'];
        return true;
      }

      return false;
    });

    return res;
  }
}




///*****************************************************************************************************
/** --------- auto format text field -----------------------------------------------
    onChanged: (t){
    t = LocaleHelper.numberToEnglish(t.trim())!;
    var t2 = LocaleHelper.removeMarks(t)!;
    if(t2.isEmpty || t2 == '-'){
    return;
    }
    var ch = CurrencyTools.formatCurrency(MathHelper.clearToDouble(t));
    controller.priceCtr.value = KeyboardHelper.getTextEditingValue(ch);
    },
    -----------------------------------------------------------------------
 */
