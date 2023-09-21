import 'package:flutter/material.dart';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
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
    else if(causeCode == HttpCodes.error_userNamePassIncorrect){
      AppSnack.showInfo(context, AppMessages.userNameOrPasswordIncorrect);
      return true;
    }
    else if(causeCode == HttpCodes.error_isNotJson){
      AppSnack.showError(context,  AppMessages.requestDataIsNotJson);
      return true;
    }
    else if(causeCode == HttpCodes.error_parametersNotCorrect){
      AppSnack.showError(context, AppMessages.errorOccurredInSubmittedParameters);
      return true;
    }
    else if(causeCode == HttpCodes.error_notUpload){
      AppSnack.showError(context, AppMessages.errorUploadingData);
      return true;
    }
    else if(causeCode == HttpCodes.error_spacialError){ //90
      AppSnack.showError(context, AppMessages.httpMessage(cause));
      return true;
    }
    else if(causeCode == HttpCodes.error_dataNotExist){
      AppSnack.showInfo(context, AppMessages.dataNotFound);
      return true;
    }
    else if(causeCode == HttpCodes.error_canNotAccess){
      AppSheet.showSheetOk(context, AppMessages.sorryYouDoNotHaveAccess);
      return true;
    }
    else if(causeCode == HttpCodes.error_youMustRegisterForThis){
      AppSheet.showSheetOk(context, AppMessages.youMustRegister);
      return true;
    }
    else if(causeCode == HttpCodes.error_operationCannotBePerformed){
      AppSheet.showSheetOk(context, AppMessages.operationCannotBePerformed);
      return true;
    }
    else if(causeCode == HttpCodes.error_requestNotDefined){
      AppSnack.showInfo(context, AppMessages.thisRequestNotDefined);
      return true;
    }
    else if(causeCode == HttpCodes.error_userMessage){
      final action = SnackBarAction(
        label: AppMessages.ok,
        onPressed: (){AppSheet.closeSheet(context);},
      );
      AppSnack.showAction(context, cause!, action, /*autoDismiss: false*/);

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
  static int error_mustSendRequesterUserId = 33;
  static int error_databaseError = 35;
  static int error_internalError = 40;
  static int error_isNotJson = 45;
  static int error_dataNotExist = 50;
  static int error_tokenNotCorrect = 55;
  static int error_existThis = 60;
  static int error_canNotAccess = 65;
  static int error_youMustRegisterForThis = 66;
  static int error_operationCannotBePerformed = 70;
  static int error_notUpload = 75;
  static int error_userNamePassIncorrect = 80;
  static int error_userMessage = 85;
  static int error_translateMessage = 86;
  static int error_spacialError = 90;

  //------------ sections -----------------------------------------------------
  static const sec_command = 'command';
  static const sec_userData = 'UserData';
  //static const sec_ticketData = 'TicketData';
  //------------ commands -----------------------------------------------------
  static const com_forceLogOff = 'ForceLogOff';
  static const com_forceLogOffAll = 'ForceLogOffAll';
  static const com_talkMeWho = 'TalkMeWho';
  static const com_sendDeviceInfo = 'SendDeviceInfo';
  static const com_messageForUser = 'messageForUser';
  static const com_dailyText = 'dailyText';
  static const com_updateProfileSettings = 'UpdateProfileSettings';
}
