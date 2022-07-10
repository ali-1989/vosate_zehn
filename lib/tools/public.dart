
import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:vosate_zehn/system/httpCodes.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/tools/app/appDialog.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/userLoginTools.dart';

class Public {
  Public._();

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