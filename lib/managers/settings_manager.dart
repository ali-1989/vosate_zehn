import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';

import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/globalSettingsModel.dart';
import 'package:app/structures/models/settingsModel.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/app/appDb.dart';
import '/system/keys.dart';

class SettingsManager {
	SettingsManager._();

	static late final SettingsModel _localSettings;
	static final GlobalSettingsModel _globalSettings = GlobalSettingsModel();
	static bool _isInit = false;
	static final List<VoidCallback> _localSettingsListeners = [];

	static void init(){
		if(_isInit){
			return;
		}

		loadSettings();
		EventNotifierService.addListener(AppEvents.networkConnected, _listener);
	}

	static void _listener({data}) {
		requestGlobalSettings();
	}

	static SettingsModel get localSettings {
		if(!_isInit){
			loadSettings();
		}

		return _localSettings;
	}

  static GlobalSettingsModel get globalSettings {
		return _globalSettings;
	}

  static void addListeners(VoidCallback fn) {
		if(!_localSettingsListeners.contains(fn)) {
		  _localSettingsListeners.add(fn);
		}
  }

	static void removeListeners(VoidCallback fn){
		_localSettingsListeners.remove(fn);
	}

	static void notify({BuildContext? context}){
		//context ??= RouteTools.getContext();
		Future((){
			for(final fun in _localSettingsListeners){
				try{
					fun();
				}
				catch(e){/**/}
			}
		});
	}
	///===================================================================================
	static bool loadSettings() {
		if(!_isInit) {
			_isInit = true;
			final res = AppDB.fetchKv(Keys.setting$appSettings);

			if (res == null) {
				_localSettings = SettingsModel();
				saveSettings();
			}
			else {
				_localSettings = SettingsModel.fromMap(res);
			}
		}

		return true;
	}

	static Future<bool> saveSettings({BuildContext? context, bool delay = false}) async {
		if(delay){
			await Future.delayed(const Duration(seconds: 1));
		}

		final res = await AppDB.setReplaceKv(Keys.setting$appSettings, _localSettings.toMap());

		notify(context: (context?.mounted?? false)? context : null);

		return res > 0;
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

