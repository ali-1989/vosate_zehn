//import 'package:currency_formatter/currency_formatter.dart';

class CurrencyTools {
  CurrencyTools._();

  /*
  static String formatCurrency(num cur, {String name = '', String? symbol}){
    final format = NumberFormat.currency(
      locale: SettingsManager.settingsModel.appLocale.languageCode,
      name: name,
      symbol: symbol,
      decimalDigits: 0,
      //customPattern: ,
    );

    return format.format(cur);
  }

  
  static String formatCurrency(String price, {String? symbol}) {
    CurrencyFormatterSettings euroSettings = CurrencyFormatterSettings(
      symbol: symbol?? '',
      symbolSide: SymbolSide.left,
      thousandSeparator: ',',
      decimalSeparator: '.',
    );

    CurrencyFormatter cf = CurrencyFormatter();
    num amount = double.parse(price);

    return cf.format(amount, euroSettings);
  }*/
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