import 'dart:async';

import 'package:iris_notifier/iris_notifier.dart';

import 'package:app/managers/font_manager.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/global_settings_model.dart';
import 'package:app/structures/models/settings_model.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_themes.dart';
import '/system/keys.dart';

class SettingsManager {
	SettingsManager._();

	static late final SettingsModel _localSettings;
	static late final GlobalSettingsModel _globalSettings;
	static bool _isInit = false;

	static void init(){
		if(_isInit){
			return;
		}

		_isInit = true;
		loadSettings();
		_prepareSettings();
		EventNotifierService.addListener(AppEvents.networkConnected, _netListener);
	}

	static void _netListener({data}) {
		requestGlobalSettings();
	}

	static SettingsModel get localSettings {
		init();

		return _localSettings;
	}

  static GlobalSettingsModel get globalSettings {
		init();

		return _globalSettings;
	}

	static void _prepareSettings() {
		FontManager.fetchFontThemeData(_localSettings.appLocale.languageCode);

		if(AppThemes.instance.currentTheme.themeName != _localSettings.colorTheme) {
			for (final t in AppThemes.instance.themeList.entries) {
				if (t.key == _localSettings.colorTheme) {
					AppThemes.applyTheme(t.value);
					break;
				}
			}
		}
	}

	static void loadSettings() {
		_isInit = true;
		final local = AppDB.fetchKv(Keys.setting$appSettings);
		final global = AppDB.fetchKv(Keys.setting$globalSettings);

		if (local == null) {
			_localSettings = SettingsModel();
			_localSettings.colorTheme ??= AppThemes.instance.currentTheme.themeName;
			saveLocalSettingsAndNotify(notify: false);
		}
		else {
			_localSettings = SettingsModel.fromMap(local);
		}

		if (global == null) {
			_globalSettings = GlobalSettingsModel();
			saveGlobalSettingsAndNotify(notify: false);
		}
		else {
			_globalSettings = GlobalSettingsModel.fromMap(global);
		}
	}

	static Future<void> saveLocalSettingsAndNotify({int delaySec = 0, bool notify = true}) async {
		if(delaySec > 0){
			await Future.delayed(Duration(seconds: delaySec));
		}

		await AppDB.setReplaceKv(Keys.setting$appSettings, _localSettings.toMap());

		if(notify) {
			EventNotifierService.notify(SettingsEvents.localSettingsChange);
		}

		return;
	}

	static Future<void> saveGlobalSettingsAndNotify({int delaySec = 0, bool notify = true}) async {
		if(delaySec > 0){
			await Future.delayed(Duration(seconds: delaySec));
		}

		await AppDB.setReplaceKv(Keys.setting$globalSettings, _globalSettings.toMap());

		if(notify) {
			EventNotifierService.notify(SettingsEvents.globalSettingsChange);
		}

		return;
	}

	static Future<GlobalSettingsModel?> requestGlobalSettings() async {
		if(!AppCache.canCallMethodAgain('requestGlobalSettings')){
			return _globalSettings;
		}

		final res = Completer<GlobalSettingsModel?>();
		final requester = Requester();

		requester.httpRequestEvents.onAnyState = (req) async {
			requester.dispose();
		};

		requester.httpRequestEvents.onFailState = (req, r) async {
			res.complete(null);
			return true;
		};

		requester.httpRequestEvents.onStatusOk = (req, data) async {
			final temp = GlobalSettingsModel.fromMap(data);
			_globalSettings.matchBy(temp);

			res.complete(_globalSettings);
		};

		final js = <String, dynamic>{};
		js[Keys.requestZone] = 'get_app_parameters';

		requester.bodyJson = js;
		requester.prepareUrl();
		requester.request(null, false);
		return res.future;
	}
}

enum SettingsEvents implements EventImplement {
	localSettingsChange(4),
	globalSettingsChange(5);

	final int _number;

	const SettingsEvents(this._number);

	int getNumber(){
		return _number;
	}
}
