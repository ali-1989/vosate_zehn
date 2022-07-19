import 'dart:async';

import 'package:dio/dio.dart';
import 'package:vosate_zehn/models/userModel.dart';
import 'package:vosate_zehn/system/httpCodes.dart';
import 'package:vosate_zehn/system/httpProcess.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/tools/app/appHttpDio.dart';
import 'package:vosate_zehn/tools/app/appManager.dart';

class LoginService {
  LoginService._();

  static Future<Map?> requestSendOtp({required String countryCode, required String phoneNumber}) async {
    final http = HttpItem();
    final result = Completer<Map?>();

    final js = {};
    js[Keys.requestZone] = 'send_otp';
    js[Keys.phoneCode] = countryCode;
    js[Keys.mobileNumber] = phoneNumber;
    AppManager.addAppInfo(js);

    http.fullUrl = HttpProcess.graphApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        result.complete(null);
      }

      result.complete(request.getBodyAsJson());
      return null;
    });

    return result.future;
  }

  static Future<LoginResultWrapper> requestSendVerify({required String countryCode, required String phoneNumber, required String code}) async {
    final http = HttpItem();
    final result = Completer<LoginResultWrapper>();

    final js = {};
    js[Keys.requestZone] = 'verify_otp';
    js[Keys.phoneCode] = countryCode;
    js[Keys.mobileNumber] = phoneNumber;
    js['code'] = code;
    AppManager.addAppInfo(js);

    http.fullUrl = HttpProcess.graphApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);
    final loginWrapper = LoginResultWrapper();

    var f = request.response.catchError((e){
      loginWrapper.connectionError = true;
      result.complete(loginWrapper);
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        loginWrapper.connectionError = true;
        result.complete(loginWrapper);
      }


      final resJs = request.getBodyAsJson()!;
      final status = resJs[Keys.status];
      loginWrapper.causeCode = resJs[Keys.causeCode]?? 0;

      if(status == Keys.error){
        loginWrapper.hasError = true;

        if(loginWrapper.causeCode == HttpCodes.error_dataNotExist){
          /**/
        }
        else if(loginWrapper.causeCode == HttpCodes.error_userIsBlocked){
          loginWrapper.isBlock = true;
        }
      }
      else {
        loginWrapper.isVerify = true;
      }

      final userId = resJs[Keys.userId];

      if(userId != null){
        loginWrapper.userModel = UserModel.fromMap(resJs);
      }

      result.complete(loginWrapper);
      return null;
    });

    return result.future;
  }
}
///============================================================================
class LoginResultWrapper {
  UserModel? userModel;
  bool isVerify = false;
  bool isBlock = false;
  bool hasError = false;
  bool connectionError = false;
  int causeCode = 0;
}