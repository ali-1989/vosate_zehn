import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_tools/api/appEventListener.dart';
import 'package:iris_tools/net/netManager.dart';
import 'package:vosate_zehn/managers/settingsManager.dart';
import 'package:vosate_zehn/system/lifeCycleApplication.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appCache.dart';
import 'package:vosate_zehn/tools/app/appDirectories.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:vosate_zehn/tools/app/appLocale.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appWebsocket.dart';
import 'package:vosate_zehn/tools/app/downloadUpload.dart';
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

	static Future<bool> importantInit() async {
		if(kIsWeb){
			AppDirectories.prepareStoragePathsWeb(Constants.appName);
		}
		else {
			await AppDirectories.prepareStoragePathsOs(Constants.appName);
		}

		await DeviceInfoTools.prepareDeviceInfo();
		await DeviceInfoTools.prepareDeviceId();

		return true;
	}

	static Future<bool> onceInit(BuildContext context) async {
		if(isCallInit) {
			return true;
		}

		isCallInit = true;
		if(!kIsWeb) {
			AppManager.logger = Logger('${AppDirectories.getTempDir$ex()}/events.txt');
		}

		AppRoute.init();
		await AppLocale.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'EE'));

		AppCache.screenBack = const AssetImage(AppImages.background);
		await precacheImage(AppCache.screenBack!, context);
		//PlayerTools.init();

		if(!kIsWeb) {
			await AppNotification.initial();
			AppNotification.startListenTap();
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

		AppWebsocket.prepareWebSocket(SettingsManager.settingsModel.wsAddress);
		NetManager.addChangeListener(NetListenerTools.onNetListener);

		DownloadUpload.downloadManager = DownloadManager('${Constants.appName}DownloadManager');
		DownloadUpload.uploadManager = UploadManager('${Constants.appName}UploadManager');

		DownloadUpload.downloadManager.addListener(DownloadUpload.commonDownloadListener);
		DownloadUpload.uploadManager.addListener(DownloadUpload.commonUploadListener);

		// ignore: unawaited_futures
		//CountryTools.fetchCountries();

		Session.addLoginListener(UserLoginTools.onLogin);
    Session.addLogoffListener(UserLoginTools.onLogoff);
    Session.addProfileChangeListener(UserLoginTools.onProfileChange);
	}
}
