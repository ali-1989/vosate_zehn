import 'package:iris_tools/api/helpers/boolHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

import 'package:vosate_zehn/models/userModel.dart';
import 'package:vosate_zehn/pages/login/login_page.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appCache.dart';
import 'package:vosate_zehn/tools/app/appHttpDio.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import '/system/httpCodes.dart';
import '/system/keys.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';

class UserLoginTools {
  UserLoginTools._();

  static void onLogin(UserModel user){
    //DrawerMenuTool.prepareAvatar(user);
  }

  static void onLogoff(UserModel user){
    sendLogoffState(user);
  }

  // on new data for existUser
  static void onProfileChange(UserModel user, Map? old) async {
    //DrawerMenuTool.prepareAvatar(user);
  }

  static void sendLogoffState(UserModel user){
    if(AppBroadcast.isNetConnected){
      final reqJs = <String, dynamic>{};
      reqJs[Keys.requestZone] = 'Logoff_user_report';
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

    AppBroadcast.drawerMenuRefresher.update();
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();

    if (isCurrent) {
      AppRoute.backToRoot(AppRoute.getContext());

      Future.delayed(Duration(seconds: 1), (){
        AppRoute.pushNamed(AppRoute.getContext(), LoginPage.route.name!);
      });

    }
  }

  static Future forceLogoffAll() async {
    await Session.logoffAll();
    AppNavigator.popRoutesUntilRoot(AppRoute.getContext());
  }


}
