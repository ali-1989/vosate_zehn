import 'package:flutter/material.dart';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';

class HttpTools {
  HttpTools._();

  static bool handler(BuildContext context, Map json) {
    final int causeCode = json[Keys.causeCode] ?? 0;
    final String cause = json[Keys.cause] ?? Keys.error;

    return handlerWithCause(context, causeCode, cause, json);
  }

  static bool handlerWithCause(BuildContext context, int causeCode, String? cause, Map json){
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
