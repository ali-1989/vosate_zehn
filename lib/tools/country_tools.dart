import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/managers/assetManager.dart';

import 'package:app/structures/models/country_model.dart';
import 'package:app/tools/app/app_cache.dart';
import '/system/extensions.dart';

class CountryTools {
  CountryTools._();

  static Map<String, dynamic>? _countriesMap;

  static Map<String, dynamic>? get countriesMap => _countriesMap;

  static Future<Map<String, dynamic>?> get countriesMapAsync async {
    if(_countriesMap == null){
      return fetchCountries();
    }

    return _countriesMap;
  }

  static Future<Map<String, dynamic>?> fetchCountries() async {
    return AssetsManager.loadAsString('assets/raw/countries.json').then((data) {
      if (data == null) {
        if(AppCache.timeoutCache.addTimeout('prepareCountries', const Duration(seconds: 5))) {
          return Future.delayed(const Duration(seconds: 1), () {
            return fetchCountries();
          });
        }

        return null;
      }

      _countriesMap = JsonHelper.jsonToMap(data)!;
      return _countriesMap;
    });
  }

  static String countryShowNameByCountryIso(String countryIso) {
    final Map countryMap = countriesMap!;
    final itr = countryMap.entries;
    final first = itr.first;
    String res = first.key + (first.value['nativeName'] != null? ' (${first.value['nativeName']})': '');

    itr.firstWhereSafe((country) {
      if(country.value['iso'] == countryIso) {
        res = country.key + (country.value['nativeName'] != null? ' (${country.value['nativeName']})': '');
        return true;
      }

      return false;
    });

    return res;
  }

  static CountryModel countryModelByCountryIso(String countryIso) {
    final Map countryMap = countriesMap!;
    final itr = countryMap.entries;
    final first = itr.first;

    final res = CountryModel();
    res.countryIso = countryIso;
    res.countryName = first.value['nativeName']?? '';
    res.countryPhoneCode = first.value['phoneCode']?? '';

    itr.firstWhereSafe((country) {
      if(country.value['iso'] == countryIso) {
        res.countryName = country.value['nativeName']?? '';
        res.countryPhoneCode = country.value['phoneCode']?? '';
        return true;
      }

      return false;
    });

    return res;
  }
}
