import 'package:vosate_zehn/models/userModel.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appCache.dart';
import 'package:vosate_zehn/tools/app/appHttpDio.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:iris_tools/api/helpers/boolHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';

import '/constants.dart';
import '/system/httpCodes.dart';
import '/system/keys.dart';

import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';
import '/tools/deviceInfoTools.dart';

class UserLoginTools {
  UserLoginTools._();

  static void onLogin(UserModel user){
    //DrawerMenuTool.prepareAvatar(user);
  }

  static void onLogoff(UserModel user){
    user.profileImageUrl = null;
    sendLogoffState(user);
  }

  // on new data for existUser
  static void onProfileChange(UserModel user, Map? old) async {
    //DrawerMenuTool.prepareAvatar(user);
  }

  static void sendLogoffState(UserModel user){
    if(AppBroadcast.isNetConnected){
      final reqJs = <String, dynamic>{};
      reqJs[Keys.requestZone] = 'LogoffUserReport';
      reqJs[Keys.id] = user.userId;

      AppManager.addAppInfo(reqJs, curUser: user);

      final info = HttpItem();
      info.fullUrl = '/set-data';
      info.method = 'POST';
      info.addBodyField('Json', JsonHelper.mapToJson(reqJs));
      info.setResponseIsPlain();

      AppHttpDio.send(info);
    }
  }

  static void prepareRequestUsersProfileData() async {
    for(var user in Session.currentLoginList) {
      if(!AppCache.timeoutCache.addTimeout('updateProfileInfo_${user.userId}', const Duration(seconds: 12))){
        continue;
      }

      requestProfileInfo(user.userId).then((value){
        if(BoolHelper.itemToBool(value)) {
        }
      });
    }
  }

  static Future<bool> requestProfileInfo(String userId) async{
    final reqJs = <String, dynamic>{};
    reqJs[Keys.requestZone] = 'GetProfileInfo';
    reqJs[Keys.id] = userId;

    AppManager.addAppInfo(reqJs);

    final request = HttpItem();
    request.fullUrl = '/get-data';
    request.method = 'POST';
    request.setBodyJson(reqJs);
    request.setResponseIsPlain();

    final f = Future<bool>((){
      final response = AppHttpDio.send(request);

      var res = response.response.catchError((err){
				return err;
			});

      return res.then((value) async {
        if (!response.isOk) {
          return false;
        }

        final json = response.getBodyAsJson();

        if (json == null) {
          return false;
        }

        final String result = json[Keys.status] ?? Keys.error;

        if (result == Keys.ok) {
          await Session.newProfileData(json);
        }
        else {
          final causeCode = json[Keys.causeCode]?? 0;

          if(causeCode == HttpCodes.error_tokenNotCorrect || causeCode == HttpCodes.error_userNotFound) {
            await forceLogoff(userId);
            await Session.deleteUserInfo(userId);
          }
        }

        return true;
      });
    });

    return f;
  }

  static Future forceLogoff(String userId) async {
    final isCurrent = Session.getLastLoginUser()?.userId == userId;
    await Session.logoff(userId);

    if (isCurrent) {
      AppNavigator.popRoutesUntilRoot(AppRoute.getContext());
    }
  }

  static Future forceLogoffAll() async {
    await Session.logoffAll();
    AppNavigator.popRoutesUntilRoot(AppRoute.getContext());
  }

  ///----------- HowIs ----------------------------------------------------
  static Map<String, dynamic> getHowIsMap() {
    final howIs = <String, dynamic>{
      'how_is': 'HowIs',
      Keys.deviceId: DeviceInfoTools.deviceId,
      Keys.languageIso: System.getLocalizationsLanguageCode(AppRoute.getContext()),
      'app_version_code': Constants.appVersionCode,
      'app_version_name': Constants.appVersionName,
      'app_name': Constants.appName,
    };

    final users = [];

    for(var um in Session.currentLoginList) {
      users.add(um.userId);
    }

    howIs['users'] = users;

    return howIs;
  }

  static Map<String, dynamic> getHeartMap() {
    final heart = <String, dynamic>{
      'heart': 'Heart',
      Keys.deviceId: DeviceInfoTools.deviceId,
      Keys.languageIso: System.getLocalizationsLanguageCode(AppRoute.getContext()),
      'app_version_code': Constants.appVersionCode,
      'app_version_name': Constants.appVersionName,
      'app_name': Constants.appName,
    };

    final users = [];

    for(var um in Session.currentLoginList) {
      users.add(um.userId);
    }

    heart['users'] = users;

    return heart;
  }
}
