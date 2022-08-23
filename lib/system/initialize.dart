import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_tools/api/appEventListener.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/net/netManager.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/system/lifeCycleApplication.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appManager.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appWebsocket.dart';
import 'package:app/services/downloadUpload.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/netListenerTools.dart';
import 'package:app/tools/userLoginTools.dart';

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
		AppManager.logger = Logger('${AppDirectories.getTempDir$ex()}/events.txt');

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

		DownloadUploadService.downloadManager = DownloadManager('${Constants.appName}DownloadManager');
		DownloadUploadService.uploadManager = UploadManager('${Constants.appName}UploadManager');

		DownloadUploadService.downloadManager.addListener(DownloadUploadService.commonDownloadListener);
		DownloadUploadService.uploadManager.addListener(DownloadUploadService.commonUploadListener);

		if(System.isWeb()){
			void onSizeCheng(oldW, oldH, newW, newH){
				AppDialogIris.prepareDialogDecoration();
			}

			AppSizes.instance.addMetricListener(onSizeCheng);
		}
		
		// ignore: unawaited_futures
		//CountryTools.fetchCountries();

		Session.addLoginListener(UserLoginTools.onLogin);
    		Session.addLogoffListener(UserLoginTools.onLogoff);
    		Session.addProfileChangeListener(UserLoginTools.onProfileChange);
	}
}
