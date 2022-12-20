import 'package:app/services/google_service.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appRoute.dart';

class UserLoginTools {
  UserLoginTools._();

  static void init(){
    Session.addLoginListener(UserLoginTools.onLogin);
    Session.addLogoffListener(UserLoginTools.onLogoff);
    Session.addProfileChangeListener(UserLoginTools.onProfileChange);
  }

  static void onLogin(UserModel user){
  }

  static void onLogoff(UserModel user){
    sendLogoffState(user);
  }

  // on new data for existUser
  static void onProfileChange(UserModel user, Map? old) async {
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
}
