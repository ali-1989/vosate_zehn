import 'dart:async';

import 'package:dio/dio.dart';
import 'package:vosate_zehn/managers/settingsManager.dart';
import 'package:vosate_zehn/tools/app/appHttpDio.dart';

class LoginService {
  LoginService._();

  static Future<Map?> requestSendOtp({required String countryCode, required String phoneNumber}) async {
    final http = HttpItem();
    final result = Completer<Map?>();

    http.fullUrl = SettingsManager.settingsModel.httpAddress;
    http.method = 'POST';

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        result.complete(null);
      }

      result.complete(request.getBodyAsJson());
    });

    return result.future;
  }

  static Future<bool?> requestSendVerify({required String countryCode, required String phoneNumber, required String code}) async {
    final http = HttpItem();
    final result = Completer<bool?>();

    http.fullUrl = SettingsManager.settingsModel.httpAddress;
    http.method = 'POST';

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        result.complete(null);
      }

      result.complete(true);
    });

    return result.future;
  }
}