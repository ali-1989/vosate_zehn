import 'dart:async';

import 'package:app/managers/settingsManager.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/services/google_service.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:dio/dio.dart';

import 'package:app/structures/models/countryModel.dart';
import 'package:app/system/httpCodes.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:flutter/cupertino.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

class LoginService {
  LoginService._();

  static void onLoginObservable(UserModel user){
  }

  static void onLogoffObservable({dynamic data}){
    if(data is UserModel){
      sendLogoffState(data);
    }
  }

  static void sendLogoffState(UserModel user){
    if(AppBroadcast.isNetConnected){
      final reqJs = <String, dynamic>{};
      reqJs[Keys.requestZone] = 'Logoff_user_report';
      reqJs[Keys.requesterId] = user.userId;
      reqJs[Keys.forUserId] = user.userId;

      PublicAccess.addAppInfo(reqJs, curUser: user);

      final info = HttpItem();
      info.fullUrl = '${SettingsManager.settingsModel.httpAddress}/graph-v1';
      info.method = 'POST';
      info.body = JsonHelper.mapToJson(reqJs);
      info.setResponseIsPlain();

      AppHttpDio.send(info);
    }
  }

  static Future forceLogoff(String userId) async {
    final lastUser = Session.getLastLoginUser();

    if(lastUser != null) {
      final isCurrent = lastUser.userId == userId;

      if(lastUser.email != null){
        final google = GoogleService();
        await google.signOut();

        if(await google.isSignIn()){
          AppToast.showToast(AppRoute.getLastContext()!, AppMessages.inEmailSignOutError);
          return;
        }

        await Session.logoff(userId);
      }
      else {
        await Session.logoff(userId);
      }

      AppBroadcast.drawerMenuRefresher.update();
      AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

      if (isCurrent && AppRoute.materialContext != null) {
        AppRoute.backToRoot(AppRoute.getLastContext()!);

        Future.delayed(Duration(milliseconds: 400), (){
          AppRoute.replaceNamed(AppRoute.getLastContext()!, LoginPage.route.name!);
        });
      }
    }
  }

  static Future forceLogoffAll() async {
    while(Session.hasAnyLogin()){
      final lastUser = Session.getLastLoginUser();

      if(lastUser != null) {
        if (lastUser.email != null) {
          final google = GoogleService();
          await google.signOut();
        }
      }
    }

    await Session.logoffAll();

    AppBroadcast.drawerMenuRefresher.update();
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

    if (AppRoute.materialContext != null) {
      AppRoute.backToRoot(AppRoute.getLastContext()!);

      Future.delayed(Duration(milliseconds: 400), (){
        AppRoute.replaceNamed(AppRoute.getLastContext()!, LoginPage.route.name!);
      });
    }
  }

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

      return null;
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        result.complete(null);
        return;
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

      return null;
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        loginWrapper.connectionError = true;
        result.complete(loginWrapper);
        return;
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

      return null;
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        loginWrapper.connectionError = true;
        result.complete(loginWrapper);
        return;
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
  
  static Future<HttpRequester?> requestOnSplash() async {
    final http = HttpItem();
    final result = Completer<HttpRequester?>();

    http.fullUrl = '';
    http.method = 'GET';
    //http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(null);

      return null;
    });

    f = f.then((Response? response){
      if(response == null || response.statusCode == null) {
        result.complete(null);
        return;
      }

      result.complete(request);
      return null;
    });

    return result.future;
  }

  static loginGuestUser(BuildContext context) async {
    final gUser = Session.getGuestUser();
    final userModel = await Session.login$newProfileData(gUser.toMap());

    if(userModel != null) {
      AppRoute.replaceNamed(context, LayoutPage.route.name!);
    }
    else {
      AppSheet.showSheet$OperationFailed(context);
    }
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
