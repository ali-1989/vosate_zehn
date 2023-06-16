import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/system.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'package:app/constants.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';

class DeviceInfoTools {
  DeviceInfoTools._();

  static String? deviceId;
  static AndroidDeviceInfo? androidDeviceInfo;
  static IosDeviceInfo? iosDeviceInfo;
  static WebBrowserInfo? webDeviceInfo;
  static WindowsDeviceInfo? windowInfo;
  static LinuxDeviceInfo? linuxInfo;
  static MacOsDeviceInfo? macOsInfo;

  static Future<void> prepareDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if(System.isWeb()) {
      webDeviceInfo = await deviceInfoPlugin.webBrowserInfo;
    }
    else if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    }
    else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
    }
    else if (Platform.isWindows) {
      windowInfo = await deviceInfoPlugin.windowsInfo;
    }
    else if (Platform.isLinux) {
      linuxInfo = await deviceInfoPlugin.linuxInfo;
    }
    else if (Platform.isMacOS) {
      macOsInfo = await deviceInfoPlugin.macOsInfo;
    }
  }

  static Future<void> prepareDeviceId() async {
    deviceId = await getDeviceId();
  }

  static Future<String> getDeviceId() async {
    if(deviceId != null) {
      return SynchronousFuture<String>(deviceId!);
    }

    try {
      if(kIsWeb){
        deviceId = AppDB.fetchKv(Keys.setting$webDeviceId);

        if(deviceId == null) {
          final vendor = webDeviceInfo?.vendor ?? '';
          deviceId = 'web_${Generator.hashMd5('$vendor.${Generator.generateKey(25)}')}'; // 40 char

          AppDB.setReplaceKv(Keys.setting$webDeviceId, deviceId);
        }
      }
      else if (Platform.isWindows) {
        deviceId = windowInfo?.deviceId;
      }
      else if (Platform.isLinux) {
        deviceId = linuxInfo?.machineId;
      }
      else if (Platform.isMacOS) {
        deviceId = macOsInfo?.systemGUID;
      }
      else {
        deviceId = await PlatformDeviceId.getDeviceId;
      }
    }
    on PlatformException {
      deviceId = 'unKnow_${Generator.generateDateIsoId(4)}';
    }

    return SynchronousFuture<String>(deviceId!);
  }

  static Map<String, dynamic> mapDeviceInfo() {
    final js = <String, dynamic>{};

    if(kIsWeb){
      final uAgent = webDeviceInfo?.userAgent;

      js['device_type'] = 'Web';
      js['model'] = webDeviceInfo?.appName;
      js['brand'] = uAgent?.substring(0, min(50, uAgent.length));
      js['api'] = webDeviceInfo?.platform;

      return js;
    }

    if (System.isAndroid()) {
      js['device_type'] = 'Android';
      js['model'] = androidDeviceInfo?.model;
      js['brand'] = androidDeviceInfo?.brand;
      js['api'] = androidDeviceInfo?.version.sdkInt.toString();
    }
    else if (System.isIOS()) {
      js['device_type'] = 'iOS';
      js['model'] = iosDeviceInfo?.model; //utsname.machine
      js['brand'] = iosDeviceInfo?.systemName;
      js['api'] = iosDeviceInfo?.utsname.version.toString();
    }
    else {
      js['device_type'] = 'unKnow';
    }

    return js;
  }

  static Map<String, dynamic> mapApplicationInfo() {
    final res = <String, dynamic>{};
    res[Keys.deviceId] = deviceId;
    res[Keys.appName] = Constants.appName;
    res['app_version_code'] = Constants.appVersionCode;
    res['app_version_name'] = Constants.appVersionName;

    return res;
  }

  static Map attachApplicationInfo(Map src, {UserModel? curUser}) {
    final token = curUser?.token ?? SessionService.getLastLoginUser()?.token;

    src.addAll(mapApplicationInfo());

    if (token?.token != null) {
      src[Keys.token] = token?.token;
      src['fcm_token'] = FireBaseService.token;
    }

    return src;
  }
}
