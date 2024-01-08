import 'package:flutter/material.dart';

import 'package:app/services/login_service.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';

class HttpTools {
  HttpTools._();

  static bool handlerTokenOrBlock(BuildContext context, Map json) {
    final int causeCode = json[Keys.causeCode] ?? 0;

    if(causeCode == HttpCodes.cCode$TokenNotCorrect){
      AppSnack.showError(context, AppMessages.tokenIsIncorrectOrExpire);
      LoginService.forceLogoff();
      return true;
    }

    return false;
  }

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
    else if(causeCode == HttpCodes.cCode$TokenNotCorrect){
      AppSnack.showError(context, AppMessages.tokenIsIncorrectOrExpire);

      if(canChangeRoute){
        LoginService.forceLogoff();
      }

      return true;
    }


    return false;
  }
}
///=============================================================================
class HttpCodes {
  HttpCodes._();

  static int cCode$UserMessage = -1;
  static int cCode$SpacialError = 0;
  static int cCode$RequestWasNotSent = 15;
  static int cCode$NeedRequesterId = 16;
  static int cCode$needDeviceId = 17;
  static int cCode$HaveNotAccess = 19;
  static int cCode$UserIsBlocked = 20;
  static int cCode$DatabaseError = 35;
  static int cCode$UserNotFound = 25;
  static int cCode$ParametersNotCorrect = 30;
  static int cCode$internalError = 40;
  static int cCode$isNotJson = 45;
  static int cCode$DataNotExist = 50;
  static int cCode$TokenNotCorrect = 55;
  static int cCode$youMustRegisterForThis = 60;
  static int cCode$operationCannotBePerformed = 70;
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
