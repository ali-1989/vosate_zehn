import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:iris_tools/api/system.dart';
import 'package:platform_device_id/platform_device_id.dart';

class DeviceInfoTools {
  DeviceInfoTools._();

  static String? deviceId;
  static AndroidDeviceInfo? androidDeviceInfo;
  static IosDeviceInfo? iosDeviceInfo;
  static WebBrowserInfo? webDeviceInfo;

  static Future<void> prepareDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if(System.isWeb()) {
      webDeviceInfo = await deviceInfoPlugin.webBrowserInfo;
    } else if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
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
      deviceId = await PlatformDeviceId.getDeviceId;
    }
    on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }

    return SynchronousFuture<String>(deviceId!);
  }

  static Map<String, dynamic> getDeviceInfo() {
    final js = <String, dynamic>{};

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
      js['device_type'] = 'Web';
      js['model'] = webDeviceInfo?.appName;
      js['brand'] = webDeviceInfo?.userAgent;
      js['api'] = webDeviceInfo?.appVersion;
    }

    return js;
  }
}
