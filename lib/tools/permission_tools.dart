import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:iris_tools/api/cache/future_cache.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionTools {
	PermissionTools._();

	static bool isGranted(PermissionStatus status) {
		return status == PermissionStatus.granted;
	}

	static Future<bool> isGrantedMicPermission() async {
		return await Permission.microphone.isGranted;
	}

	static Future<bool> isGrantedCameraPermission() async {
		return await Permission.camera.isGranted;
	}

	static Future<bool> isGrantedStoragePermission() async {
		return await Permission.storage.isGranted;
	}

	static void openAppSettingsScreen() async {
		await openAppSettings();
	}

	static Future<PermissionStatus> forceRequestPermission(Permission permission) async {
		return await permission.request();
	}

	static Future<PermissionStatus> requestPermission(Permission permission) async {
		if (await permission.isGranted) {
		  return Future<PermissionStatus>.value(PermissionStatus.granted);
		}

		if (await permission.isPermanentlyDenied) {
			// ignore: unawaited_futures
			openAppSettings();
			return Future<PermissionStatus>.value(PermissionStatus.permanentlyDenied);
		}
		else {
		  return await permission.request();
		}
	}

	static Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) async {
		return await permissions.request();
	}

	static Future<bool> isEnableServiceLocationWhenInUse() async {
		return await Permission.locationWhenInUse.serviceStatus.isEnabled;
	}

	static Future<PermissionStatus> requestCameraPermission() async {
		if (await Permission.camera.isGranted) {
		  return Future<PermissionStatus>.value(PermissionStatus.granted);
		}

		if (await Permission.camera.isPermanentlyDenied) {
			// ignore: unawaited_futures
			openAppSettings();
			return Future<PermissionStatus>.value(PermissionStatus.permanentlyDenied);
		}
		else {
		  return await Permission.camera.request();
		}
	}

	static Future<PermissionStatus> requestMicPermission() async {
		if (await Permission.microphone.isGranted) {
		  return Future<PermissionStatus>.value(PermissionStatus.granted);
		}

		if (await Permission.microphone.isPermanentlyDenied) {
			// ignore: unawaited_futures
			openAppSettings();
			return Future<PermissionStatus>.value(PermissionStatus.permanentlyDenied);
		}
		else {
		  return await Permission.microphone.request();
		}
	}

	static Future<PermissionStatus> requestCameraStoragePermissions() async {
		if (kIsWeb || !Platform.isAndroid) {
		  return Future<PermissionStatus>.value(PermissionStatus.granted);
		}

		Future<PermissionStatus> handler(String key) async {
			final pList = [Permission.camera, Permission.storage];

			final androidInfo = await DeviceInfoPlugin().androidInfo;
			final sdkInt = androidInfo.version.sdkInt;

			if(sdkInt > 10){
				pList.insert(0, Permission.manageExternalStorage);
			}

			final res = await requestPermissions(pList);
			var allGrant = true;
			var needOpenSettings = false;

			for(final p in res.entries) {
				if (p.value != PermissionStatus.granted) {
				  allGrant = false;
				}

				if (p.value == PermissionStatus.permanentlyDenied) {
					needOpenSettings = true;
				}
			}

			if (needOpenSettings) {
				// ignore: unawaited_futures
				openAppSettings();
				return PermissionStatus.permanentlyDenied;
			}

			if(allGrant) {
			  return PermissionStatus.granted;
			}
			else {
			  return PermissionStatus.denied;
			}
		}

		return FutureCache.get<PermissionStatus>('requestCameraStoragePermissions', handler).then((value){
			if(value != null) {
			  return value;
			}

			return PermissionStatus.granted;
		});
	}

	static Future<PermissionStatus> requestStoragePermissionWithOsVersion() async {
		if (Platform.isAndroid) {
			final androidInfo = await DeviceInfoPlugin().androidInfo;
			final sdkInt = androidInfo.version.sdkInt;

			if(sdkInt < 11){
				return requestStoragePermissionOnly();
			}

			return requestStorageAndManagerPermission();
		}

		return requestStoragePermissionOnly();
	}

	// status == PermissionStatus.granted
	static Future<PermissionStatus> requestStoragePermissionOnly() async {
		if (kIsWeb || !Platform.isAndroid || await Permission.storage.isGranted) {
		  return Future<PermissionStatus>.value(PermissionStatus.granted);
		}

		Future<PermissionStatus> handler(String key) async {
			if (await Permission.storage.isPermanentlyDenied) {
				// ignore: unawaited_futures
				openAppSettings();
				return PermissionStatus.permanentlyDenied;
			}
			else {
			  return (await Permission.storage.request());
			}
		}

		return FutureCache.get<PermissionStatus>('requestStoragePermission', handler).then((value){
			if(value != null) {
			  return value;
			}

			return PermissionStatus.granted;
		});
	}

	static Future<PermissionStatus> requestStorageAndManagerPermission() async {
		if (kIsWeb || !Platform.isAndroid || await Permission.storage.isGranted) {
			return Future<PermissionStatus>.value(PermissionStatus.granted);
		}

		Future<PermissionStatus> handler(String key) async {
			if (await Permission.storage.isPermanentlyDenied) {
				// ignore: unawaited_futures
				openAppSettings();
				return PermissionStatus.permanentlyDenied;
			}
			else {
				final r1 = await Permission.manageExternalStorage.request();
				final r2 = await Permission.storage.request();

				if(r1.isGranted && r2.isGranted){
					return PermissionStatus.granted;
				}

				return PermissionStatus.denied;
			}
		}

		return FutureCache.get<PermissionStatus>('manageExternalStorage', handler).then((value){
			if(value != null) {
				return value;
			}

			return PermissionStatus.granted;
		});
	}
}
