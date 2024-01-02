import 'package:app/services/login_service.dart';
import 'package:flutter/material.dart';

import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';

class HttpTools {
  HttpTools._();

  static bool handler(BuildContext context, Map json, {bool canChangeRoute = true}) {
    final int causeCode = json[Keys.causeCode] ?? 0;
    final String cause = json[Keys.cause] ?? Keys.error;

    return handlerWithCause(context, causeCode, cause, json, canChangeRoute: canChangeRoute);
  }

  static bool handlerWithCause(BuildContext context, int causeCode, String? cause, Map json, {bool canChangeRoute = true}){
    if(causeCode == HttpCodes.cCode$UserMessage && cause != null){
      AppSnack.showInfo(context, cause);
      return true;
    }

    if(causeCode == HttpCodes.cCode$RequestWasNotSent){
      AppSnack.showError(context, AppMessages.requestKeyNotExist);
      return true;
    }
    else if(causeCode == HttpCodes.cCode$TokenNotCorrect){
      AppSnack.showError(context, AppMessages.tokenIsIncorrectOrExpire);

      if(canChangeRoute){
        LoginService.forceLogoff();
      }

      return true;
    }
    else if(causeCode == HttpCodes.cCode$DatabaseError){
      AppSnack.showError(context, AppMessages.databaseError);
      return true;
    }
    else if(causeCode == HttpCodes.cCode$UserIsBlocked){
      AppSnack.showError(context, AppMessages.accountIsBlock);
      return true;
    }
    else if(causeCode == HttpCodes.cCode$LoginDataIncorrect){
      AppSnack.showError(context, AppMessages.userNameOrPasswordIncorrect);
      return true;
    }
    else if(causeCode == HttpCodes.cCode$ParametersNotCorrect){
      AppSnack.showError(context, AppMessages.errorOccurredInSubmittedParameters);
      return true;
    }
    else if(causeCode == HttpCodes.cCode$UserNotFound){
      AppSnack.showError(context, AppMessages.accountNotFound.capitalize);
      return true;
    }


    return false;
  }
}
///=============================================================================
class HttpCodes {
  HttpCodes._();

  static const databaseError = 'Database error';
  static const noDataFound = 'No data found';
  static const needDeviceId = 'Need to Device-ID';
  static const needRequesterId = 'Need to Requester-ID';
  static const requestWasNotSent = 'The request was not sent';
  static const haveNotAccess = 'You do not have access';
  static int cCode$SpacialError = 0;
  static int cCode$UserMessage = -1;
  static int cCode$RequestWasNotSent = 15;
  static int cCode$NeedRequesterId = 16;
  static int cCode$needDeviceId = 17;
  static int cCode$HaveNotAccess = 19;
  static int cCode$DatabaseError = 35;
  static int cCode$UserIsBlocked = 20;
  static int cCode$UserNotFound = 25;
  static int cCode$ParametersNotCorrect = 30;
  static int cCode$DataNotExist = 50;
  static int cCode$TokenNotCorrect = 55;
  static int cCode$NotUpload = 75;
  static int cCode$LoginDataIncorrect = 80;
  //------------ sections -----------------------------------------------------
  static const command$section = 'command';
  static const userData$section = 'UserData';
  //------------ commands -----------------------------------------------------
  static const forceLogOff$command = 'ForceLogOff';
  static const forceLogOffAll$command = 'ForceLogOffAll';
  static const talkMeWho$command = 'TalkMeWho';
  static const sendDeviceInfo$command = 'SendDeviceInfo';
  static const messageForUser$command = 'messageForUser';
  static const updateProfileSettings$command = 'UpdateProfileSettings';
    static const dailyText$command = 'dailyText';
}
