import 'dart:async';

import 'package:app/managers/api_manager.dart';
import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/models/twoStateReturn.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/google_service.dart';
import 'package:app/structures/models/countryModel.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/routeTools.dart';

class LoginService {
  LoginService._();

  static void onLoginObservable({dynamic data}){
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

      DeviceInfoTools.addAppInfo(reqJs, curUser: user);

      final info = HttpItem();
      info.fullUrl = '${SettingsManager.localSettings.httpAddress}/graph-v1';
      info.method = 'POST';
      info.body = JsonHelper.mapToJson(reqJs);
      info.setResponseIsPlain();

      AppHttpDio.send(info);
    }
  }

  static Future forceLogoff(String userId) async {
    final lastUser = SessionService.getLastLoginUser();

    if(lastUser != null) {
      final isCurrent = lastUser.userId == userId;

      if(lastUser.email != null){
        final google = GoogleService();
        await google.signOut();

        if(await google.isSignIn()){
          AppToast.showToast(RouteTools.getTopContext()!, AppMessages.inEmailSignOutError);
          return;
        }

        await SessionService.logoff(userId);
      }
      else {
        await SessionService.logoff(userId);
      }

      AppBroadcast.drawerMenuRefresher.update();
      AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

      if (isCurrent && RouteTools.materialContext != null) {
        RouteTools.backToRoot(RouteTools.getTopContext()!);

        Future.delayed(Duration(milliseconds: 400), (){
          AppBroadcast.reBuildMaterial();
        });
      }
    }
  }

  static Future forceLogoffAll() async {
    while(SessionService.hasAnyLogin()){
      final lastUser = SessionService.getLastLoginUser();

      if(lastUser != null) {
        if (lastUser.email != null) {
          final google = GoogleService();
          await google.signOut();
        }
      }
    }

    await SessionService.logoffAll();

    AppBroadcast.drawerMenuRefresher.update();
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();

    if (RouteTools.materialContext != null) {
      RouteTools.backToRoot(RouteTools.getTopContext()!);

      Future.delayed(Duration(milliseconds: 400), (){
        AppBroadcast.reBuildMaterial();
        //RouteTools.pushReplacePage(RouteTools.getTopContext()!, LoginPage());
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
    DeviceInfoTools.addAppInfo(js);

    http.fullUrl = ApiManager.graphApi;
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

  static Future<TwoStateReturn<Map, Exception>> requestVerifyOtp({required CountryModel countryModel, required String phoneNumber, required String code}) async {
    final http = HttpItem();
    final result = Completer<TwoStateReturn<Map, Exception>>();

    final js = {};
    js[Keys.requestZone] = 'verify_otp';
    js[Keys.mobileNumber] = phoneNumber;
    js['code'] = code;
    js.addAll(countryModel.toMap());
    js.addAll(DeviceInfoTools.getDeviceInfo());
    DeviceInfoTools.addAppInfo(js);

    http.fullUrl = ApiManager.graphApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(TwoStateReturn(r2: e));

      return null;
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        result.complete(TwoStateReturn(r2: Exception()));
        return;
      }

      final resJs = request.getBodyAsJson()!;
      result.complete(TwoStateReturn(r1: resJs));
      return null;
    });

    return result.future;
  }

  static Future<TwoStateReturn<Map, Exception>> requestVerifyEmail({required String email}) async {
    final http = HttpItem();
    final result = Completer<TwoStateReturn<Map, Exception>>();

    final js = {};
    js[Keys.requestZone] = 'verify_email';
    js['email'] = email;
    js.addAll(DeviceInfoTools.getDeviceInfo());
    DeviceInfoTools.addAppInfo(js);

    http.fullUrl = ApiManager.graphApi;
    http.method = 'POST';
    http.setBodyJson(js);

    final request = AppHttpDio.send(http);

    var f = request.response.catchError((e){
      result.complete(TwoStateReturn(r2: e));

      return null;
    });

    f = f.then((Response? response){
      if(response == null || !request.isOk) {
        result.complete(TwoStateReturn(r2: Exception()));
        return;
      }

      final resJs = request.getBodyAsJson()!;

      result.complete(TwoStateReturn(r1: resJs));
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
    final gUser = SessionService.getGuestUser();
    final userModel = await SessionService.login$newProfileData(gUser.toMap());

    if(userModel != null) {
      AppBroadcast.reBuildMaterial();
    }
    else {
      AppSheet.showSheet$OperationFailed(context);
    }
  }
}
