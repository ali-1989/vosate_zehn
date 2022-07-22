
import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:vosate_zehn/constants.dart';
import 'package:vosate_zehn/managers/settingsManager.dart';
import 'package:vosate_zehn/system/httpCodes.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appDialog.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/deviceInfoTools.dart';
import 'package:vosate_zehn/tools/userLoginTools.dart';

class PublicAccess {
  PublicAccess._();

  static String graphApi = '${SettingsManager.settingsModel.httpAddress}/graph-v1';

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

  static bool onResponse(Response response){
    final statusCode = response.statusCode?? 0;

    if(statusCode == 200){
      final isString = response.data is String;
      final json = isString? JsonHelper.jsonToMap(response.data): null;

      if(json != null){
        final causeCode = json[Keys.causeCode]?? 0;

        if(causeCode == HttpCodes.error_tokenNotCorrect){
          UserLoginTools.forceLogoff(Session.getLastLoginUser()?.userId?? '');

          AppDialog.instance.showInfoDialog(
              AppRoute.materialContext,
              null,
              AppMessages.tokenIsIncorrectOrExpire
          );
        }
      }
    }

    return true;
  }
}