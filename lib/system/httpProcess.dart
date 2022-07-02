import 'package:vosate_zehn/tools/app/appSheet.dart';
import 'package:vosate_zehn/tools/app/appSnack.dart';
import 'package:flutter/material.dart';

import '/system/extensions.dart';
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
    if(causeCode == HttpCodes.error_requestKeyNotFound){
      AppSnack.showFlashBarError(context, "'request' key not exist");
      return true;
    }
    else if(causeCode == HttpCodes.error_tokenNotCorrect){
      AppSnack.showFlashBarError(context, context.tInMap('httpCodes', 'tokenIsIncorrect')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_databaseError){
      AppSnack.showFlashBarError(context, context.tInMap('httpCodes', 'databaseError')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_userIsBlocked){
      AppSnack.showFlashBarInfo(context, context.tInMap('httpCodes', 'accountIsBlock')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_userNotFound){
      AppSnack.showFlashBarInfo(context, context.tInMap('httpCodes', 'userNameOrPasswordIncorrect')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_userNamePassIncorrect){
      AppSnack.showFlashBarInfo(context, context.tInMap('httpCodes', 'userNameOrPasswordIncorrect')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_isNotJson){
      AppSnack.showFlashBarError(context,  'request data is not a json');
      return true;
    }
    else if(causeCode == HttpCodes.error_parametersNotCorrect){
      AppSnack.showFlashBarError(context, context.tInMap('httpCodes', 'errorOccurredInSubmittedParameters')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_notUpload){
      AppSnack.showFlashBarError(context, context.tInMap('httpCodes', 'errorUploadingData')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_internalError){
      AppSnack.showFlashBarError(context, context.tInMap('httpCodes', 'errorInServerSide')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_dataNotExist){
      AppSnack.showFlashBarInfo(context, context.tInMap('httpCodes', 'dataNotFound')!);
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
      AppSnack.showFlashBarInfo(context, context.tInMap('httpCodes', 'thisRequestNotDefined')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_toUserMessage){
      AppSnack.showFlashBarAction(context, cause!, TextButton(
          onPressed: (){AppSheet.closeSheet(context);},
          child: Text('${context.tC('ok')}')
      ),
        autoDismiss: false,
      );

      return true;
    }

    return false;
  }
}
