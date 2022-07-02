import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class IrisLocalizations {
	Map<String, dynamic>? _keyValues;
	Map<String, dynamic>? _fallback;
	Locale? _currentLocale;

	IrisLocalizations();

	Locale? get currentLocale => _currentLocale;

	/// find ancestor
	static IrisLocalizations? of(BuildContext context) {
		return Localizations.of<IrisLocalizations>(context, IrisLocalizations);
	}

	Future<String> _loadAssets(String address) async {
		return await rootBundle.loadString(address);
	}

	Future<bool> loadByAssets(Locale locale) async {
		String? strJson;
		_currentLocale = locale;

		if(locale.countryCode != null && locale.countryCode!.isNotEmpty) {
			strJson = await _loadAssets('assets/locales/${locale.languageCode}_${locale.countryCode}.json');
		}

		strJson ??= await _loadAssets('assets/locales/${locale.languageCode}.json');

		final Map<String, dynamic> mappedJson = jsonDecode(strJson);
		//unNeed: _keyValues = mappedJson.map((key, value) => MapEntry(key, value.toString()));
		_keyValues = mappedJson;

		return true;
	}

	Future<bool> loadByMap(Map<String, String> kv) async {
		_keyValues = kv;
		return true;
	}

	Future<void> setFallbackByLocale(Locale locale) async {
		String? strJson;

		if(locale.countryCode != null && locale.countryCode!.isNotEmpty) {
			strJson = await _loadAssets('assets/locales/${locale.languageCode}_${locale.countryCode}.json');
		}

		strJson ??= await _loadAssets('assets/locales/${locale.languageCode}.json');

		_fallback = jsonDecode(strJson);
	}

	void setFallbackByMap(Map<String, String> kv) async {
		_fallback = kv;
	}

	/// static
	static String? translateBy(BuildContext context, String key) {
		return Localizations.of<IrisLocalizations>(context, IrisLocalizations)?.translate(key);
	}

	String? translate(String key) {
		var res = _keyValues?[key];

		if(res == null && _fallback != null) {
			res = _fallback![key];
		}

		return res;
	}

	String? translateCapitalize(String key) {
		final res = translate(key);
		return res == null ? null: ('${res[0].toUpperCase()}${res.substring(1)}');
	}

	Map<String, dynamic>? translateMap(String key) {
		var res = _keyValues![key];

		if(res == null && _fallback != null) {
			res = _fallback![key];
		}

		return res;
	}

	static Widget getCustomLocalization(BuildContext context, Locale locale, Widget child) {
		return Localizations.override(context: context, locale: locale, child: child,);
	}

	static Locale? getLocalOf(BuildContext context) {
		return Localizations.maybeLocaleOf(context);
	}
}
///=====================================================================================================
typedef CheckLocaleSupported = bool Function(Locale locale);

class IrisLocaleDelegate extends LocalizationsDelegate<IrisLocalizations> {
	late final IrisLocalizations _localization;
	late final CheckLocaleSupported _localeSupportChecker;

	IrisLocaleDelegate(CheckLocaleSupported checkLocaleSupported){
		_localization = IrisLocalizations();
		_localeSupportChecker = checkLocaleSupported;
	}

	@override
	bool isSupported(Locale locale) {
		return _localeSupportChecker(locale);
	}

	@override
	Future<IrisLocalizations> load(Locale locale) async {
		await _localization.loadByAssets(locale);

		return SynchronousFuture<IrisLocalizations>(_localization);
		//return Future.value(localData);
	}

	@override
	bool shouldReload(IrisLocaleDelegate old) => false;

	IrisLocalizations getLocalization() => _localization;
}





/*static Map<String, Map<String, String>> _data = {
		'en': {
			'title': 'App title',
			'googleLogin': 'Login with Google'
		},
		'fa': {
			'title': '',
			'googleLogin': ''
		},
	};

	String get title =>  _data[locale.languageCode]['title'];
	*/
