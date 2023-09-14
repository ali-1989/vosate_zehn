import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:iris_tools/api/cache/streamCach.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionTools {
	PermissionTools._();

	static bool isGranted(PermissionStatus status) {
		return status == PermissionStatus.granted;
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

		streamFn(String key, StreamController streamCtr) async {
			final res = await requestPermissions([Permission.camera, Permission.storage]);
			var allGrant = true;

			for(var p in res.entries) {
				if (p.value != PermissionStatus.granted) {
				  allGrant = false;
				}

				if (p.value == PermissionStatus.permanentlyDenied) {
					// ignore: unawaited_futures
					openAppSettings();
					streamCtr.add(PermissionStatus.permanentlyDenied);
					return;
				}
			}

			if(allGrant) {
			  streamCtr.add(PermissionStatus.granted);
			} else {
			  streamCtr.add(PermissionStatus.denied);
			}
		}

		return StreamCache.get<PermissionStatus>('requestCameraStoragePermissions', streamFn).then((value){
			if(value != null) {
			  return value;
			}

			return PermissionStatus.granted;
		});
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

	// status == PermissionStatus.granted
	static Future<PermissionStatus> requestStoragePermission() async {
		if (kIsWeb || !Platform.isAndroid || await Permission.storage.isGranted) {
		  return Future<PermissionStatus>.value(PermissionStatus.granted);
		}

		void streamFn(String key, StreamController streamCtr) async {
			if (await Permission.storage.isPermanentlyDenied) {
				// ignore: unawaited_futures
				openAppSettings();
				//return Future<PermissionStatus>.value(PermissionStatus.permanentlyDenied);
				streamCtr.add(PermissionStatus.permanentlyDenied);
			}
			else {
			  streamCtr.add(await Permission.storage.request());
			}
		}

		return StreamCache.get<PermissionStatus>('requestStoragePermission', streamFn).then((value){
			if(value != null) {
			  return value;
			}

			return PermissionStatus.granted;
		});
	}
}
