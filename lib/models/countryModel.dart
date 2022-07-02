
class CountryModel {
  String? countryName;
  String? countryPhoneCode;
  String? countryIso;

  CountryModel();

  CountryModel.fromMap(Map? map){
    if(map != null) {
      countryName = map['country_name'];
      countryIso = map['country_iso'];
      countryPhoneCode = map['phone_code'];
    }
  }

  Map<String, dynamic> toMap(){
    return {
      'country_name': countryName,
      'country_iso': countryIso,
      'phone_code': countryPhoneCode,
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