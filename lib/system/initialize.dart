import 'package:iris_tools/api/appEventListener.dart';
import 'package:iris_tools/net/netManager.dart';
import 'package:vosate_zehn/system/lifeCycleApplication.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appCache.dart';
import 'package:vosate_zehn/tools/app/appDirectories.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/storageHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:vosate_zehn/tools/app/appLocale.dart';
import 'package:vosate_zehn/tools/netListenerTools.dart';
import 'package:vosate_zehn/tools/userLoginTools.dart';

import '/constants.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNotification.dart';
import '/tools/deviceInfoTools.dart';

class InitialApplication {
	InitialApplication._();

	static bool isCallInit = false;
	static bool isInitialOk = false;
	static bool isLaunchOk = false;

	static Future<bool> waitForImportant() async {
		await AppDirectories.prepareStoragePaths(Constants.appName);
		await DeviceInfoTools.prepareDeviceInfo();
		await DeviceInfoTools.prepareDeviceId();

		return true;
	}

	static Future<bool> oncePreparing(BuildContext context) async {
		if(isCallInit) {
			return true;
		}

		isCallInit = true;
		if(kIsWeb) {
		  AppManager.logger = Logger('${StorageHelper.getMemoryFileSystem().path.current}/events.txt');
		} else {
		  AppManager.logger = Logger('${AppDirectories.getTempDir$ex()}/events.txt');
		}

		await AppLocale.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'EE'));

		//await WsCenter.prepareWebSocket(SettingsManager.settingsModel.wsAddress!);
		/*PlayerTools.init();
		DownloadUpload.downloadManager = DownloadManager('${Constants.appName}DownloadManager');
		DownloadUpload.uploadManager = UploadManager('${Constants.appName}UploadManager');*/
		AppCache.screenBack = const AssetImage(AppImages.background);
		await precacheImage(AppCache.screenBack!, context);
		// ignore: unawaited_futures
		//CountryTools.fetchCountries();


		if(!kIsWeb) {
			//await AppNotification.initial();
		}

		isInitialOk = true;
		return true;
	}

	static void callOnLaunchUp(){
		if(isLaunchOk) {
			return;
		}

		isLaunchOk = true;

		final eventListener = AppEventListener();
		eventListener.addResumeListener(LifeCycleApplication.onResume);
		eventListener.addPauseListener(LifeCycleApplication.onPause);
		eventListener.addDetachListener(LifeCycleApplication.onDetach);
		WidgetsBinding.instance.addObserver(eventListener);

		//DownloadUpload.downloadManager.addListener(DownloadUpload.commonDownloadListener);
		//DownloadUpload.uploadManager.addListener(DownloadUpload.commonUploadListener);

		NetManager.addChangeListener(NetListenerTools.onNetListener);

		Session.addLoginListener(UserLoginTools.onLogin);
    Session.addLogoffListener(UserLoginTools.onLogoff);
    Session.addProfileChangeListener(UserLoginTools.onProfileChange);
	}
}
