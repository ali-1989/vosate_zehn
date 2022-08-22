// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app/models/settingsModel.dart';
import 'package:app/tools/app/appDb.dart';
import '/system/keys.dart';

class SettingsManager {
	SettingsManager._();

	static late final SettingsModel _settingsModel;
	static bool _isInit = false;
	static final List<void Function()> _settingsChangeListeners = [];


	static SettingsModel get settingsModel {
		if(!_isInit){
			loadSettings();
		}

		return _settingsModel;
	}

  static void addListeners(void Function() fn) {
		if(!_settingsChangeListeners.contains(fn)) {
		  _settingsChangeListeners.add(fn);
		}
  }

	static void removeListeners(Function fn){
		_settingsChangeListeners.remove(fn);
	}

	static void notify({BuildContext? context}){
		//context ??= AppRoute.getContext();
		Future((){
			for(final fun in _settingsChangeListeners){
				try{
					fun();
				}
				catch(e){/**/}
			}
		});
	}
	///===================================================================================
	static bool loadSettings() {
		final res = AppDB.fetchKv(Keys.setting$appSettings);

		if(!_isInit) {
			if (res == null) {
				_settingsModel = SettingsModel();
			}
			else {
				_settingsModel = SettingsModel.fromMap(res);
			}

			_isInit = true;
		}

		saveSettings();
		return true;
	}

	static Future<bool> saveSettings({BuildContext? context, bool delay = false}) async {
		if(delay){
			await Future.delayed(const Duration(seconds: 1));
		}

		final res = await AppDB.setReplaceKv(Keys.setting$appSettings, _settingsModel.toMap());

		notify(context: context);

		return res > 0;
	}
}

