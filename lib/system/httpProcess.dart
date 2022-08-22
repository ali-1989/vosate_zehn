import 'package:flutter/material.dart';

import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import '/system/httpCodes.dart';
import '/system/keys.dart';

class HttpProcess {
  HttpProcess._();

  static bool processCommonRequestError(BuildContext context, Map json) {
    final int causeCode = json[Keys.causeCode] ?? 0;
    final String cause = json[Keys.cause] ?? Keys.error;

    return processCommonRequestErrors(context, causeCode, cause, json);
  }

  static bool processCommonRequestErrors(BuildContext context, int causeCode, String? cause, Map json){
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
      AppSheet.showSheet$YouDoNotHaveAccess(context);
      return true;
    }
    else if(causeCode == HttpCodes.error_operationCannotBePerformed){
      AppSheet.showSheet$OperationCannotBePerformed(context);
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
