import 'package:app/system/keys.dart';

class CountryModel {
  String? countryName;
  String? nativeName;
  String? countryPhoneCode;
  String? countryIso;

  CountryModel();

  CountryModel.fromMap(Map? map){
    if(map != null) {
      countryName = map['country_name'];
      nativeName = map['native_name'];
      countryIso = map[Keys.countryIso];
      countryPhoneCode = map[Keys.phoneCode];
    }
  }

  Map<String, dynamic> toMap(){
    return {
      'country_name': countryName,
      'native_name': nativeName,
      Keys.countryIso: countryIso,
      Keys.phoneCode: countryPhoneCode,
    };
  }
}
///=============================================================================================
class CurrencyModel {
  String? currencyName;
  String? currencyCode;
  String? currencySymbol;
  String? countryIso;

  CurrencyModel();

  CurrencyModel.fromMap(Map? map){
    if(map != null) {
      currencyName = map['currency_name'];
      currencySymbol = map['currency_symbol'];
      currencyCode = map['currency_code'];
      countryIso = map['country_iso'];
    }
  }

  Map<String, dynamic> toMap(){
    return {
      'country_iso': countryIso,
      'currency_name': currencyName,
      'currency_symbol': currencySymbol,
      'currency_code': currencyCode,
    };
  }
}
