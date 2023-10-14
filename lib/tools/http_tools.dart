import 'package:flutter/material.dart';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';

class CommonHttpHandler {
  CommonHttpHandler._();

  static bool handler(BuildContext context, Map json) {
    final int causeCode = json[Keys.causeCode] ?? 0;
    final String cause = json[Keys.cause] ?? Keys.error;

    return handlerWithCause(context, causeCode, cause, json);
  }

  static bool handlerWithCause(BuildContext context, int causeCode, String? cause, Map json){
    if(causeCode == HttpCodes.error_zoneKeyNotFound){
      AppSnack.showError(context, AppMessages.requestKeyNotExist);
      return true;
    }
    else if(causeCode == HttpCodes.error_tokenNotCorrect){
      AppSnack.showError(context, AppMessages.tokenIsIncorrectOrExpire);
      return true;
    }
    else if(causeCode == HttpCodes.error_databaseError){
      AppSnack.showError(context, AppMessages.databaseError);
      return true;
    }
    else if(causeCode == HttpCodes.error_userIsBlocked){
      AppSnack.showInfo(context, AppMessages.accountIsBlock);
      return true;
    }
    else if(causeCode == HttpCodes.error_userNotFound){
      AppSnack.showInfo(context, AppMessages.userNameOrPasswordIncorrect);
      return true;
    }
    else if(causeCode == HttpCodes.error_parametersNotCorrect){
      AppSnack.showError(context, AppMessages.errorOccurredInSubmittedParameters);
      return true;
    }
    else if(causeCode == HttpCodes.error_requestNotDefined){
      AppSnack.showInfo(context, AppMessages.thisRequestNotDefined);
      return true;
    }

    return false;
  }
}
///=============================================================================
class HttpCodes {
  HttpCodes._();

  static int error_zoneKeyNotFound = 10;
  static int error_requestNotDefined = 15;
  static int error_userIsBlocked = 20;
  static int error_userNotFound = 25;
  static int error_parametersNotCorrect = 30;
  static int error_databaseError = 35;
  static int error_internalError = 40;
  static int error_tokenNotCorrect = 55;
  //------------ sections -----------------------------------------------------
  static const sec_command = 'command';
  static const sec_userData = 'UserData';
  //------------ commands -----------------------------------------------------
  static const com_forceLogOff = 'ForceLogOff';
  static const com_forceLogOffAll = 'ForceLogOffAll';
  static const com_talkMeWho = 'TalkMeWho';
  static const com_sendDeviceInfo = 'SendDeviceInfo';
  static const com_messageForUser = 'messageForUser';
  static const com_dailyText = 'dailyText';
  static const com_updateProfileSettings = 'UpdateProfileSettings';
}
