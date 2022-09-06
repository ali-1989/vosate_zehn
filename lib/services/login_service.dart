import 'dart:async';

import 'package:dio/dio.dart';

import 'package:app/models/countryModel.dart';
import 'package:app/system/httpCodes.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/deviceInfoTools.dart';

class LoginService {
  LoginService._();

  static Future<Map?> requestSendOtp({required CountryModel countryModel, required String phoneNumber}) async {
    final http = HttpItem();
    final result = Completer<Map?>();

    final js = {};
    js[Keys.requestZone] = 'send_otp';
    js[Keys.mobileNumber] = phoneNumber;
    js.addAll(countryModel.toMap());
    PublicAccess.addAppInfo(js);

    http.fullUrl = PublicAccess.graphApi;
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

  static Future<LoginResultWrapper> requestVerifyOtp({required CountryModel countryModel, required String phoneNumber, required String code}) async {
    final http = HttpItem();
    final result = Completer<LoginResultWrapper>();

    final js = {};
    js[Keys.requestZone] = 'verify_otp';
    js[Keys.mobileNumber] = phoneNumber;
    js['code'] = code;
    js.addAll(countryModel.toMap());
    js.addAll(DeviceInfoTools.getDeviceInfo());
    PublicAccess.addAppInfo(js);

    http.fullUrl = PublicAccess.graphApi;
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
      loginWrapper.jsResult = resJs;

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

      result.complete(loginWrapper);
      return null;
    });

    return result.future;
  }

  static Future<LoginResultWrapper> requestVerifyEmail({required String email}) async {
    final http = HttpItem();
    final result = Completer<LoginResultWrapper>();

    final js = {};
    js[Keys.requestZone] = 'verify_email';
    js['email'] = email;
    js.addAll(DeviceInfoTools.getDeviceInfo());
    PublicAccess.addAppInfo(js);

    http.fullUrl = PublicAccess.graphApi;
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
      loginWrapper.jsResult = resJs;

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

      result.complete(loginWrapper);
      return null;
    });

    return result.future;
  }
}
///============================================================================
class LoginResultWrapper {
  Map? jsResult;
  bool isVerify = false;
  bool isBlock = false;
  bool hasError = false;
  bool connectionError = false;
  int causeCode = 0;
}
