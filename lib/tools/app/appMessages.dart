import '/system/extensions.dart';

import 'package:vosate_zehn/tools/app/appRoute.dart';

class AppMessages {
  AppMessages._();

  static const _noText = "nn";
  static const errorOccur = "خطایی رخ داده است";
  static const pleaseWait = 'چند لحظه صبر کنید...';

  static String get ok {
    return AppRoute.getContext().tC('ok')?? _noText;
  }

  static String get yes {
    return AppRoute.getContext().tC('yes')?? _noText;
  }

  static String get no {
    return AppRoute.getContext().tC('no')?? _noText;
  }

  static String get notice {
    return AppRoute.getContext().tC('notice')?? _noText;
  }

  static String get wantToLeave {
    return AppRoute.getContext().tC('wantToLeave')?? _noText;
  }

  static String get requestKeyNotExist {
    return "'request' key not exist";
  }

  static String get requestDataIsNotJson {
    return 'request data is not a json';
  }

  static String get tokenIsIncorrectOrExpire {
    return AppRoute.getContext().tInMap('httpCodes', 'tokenIsIncorrect')?? _noText;
  }

  static String get databaseError {
    return AppRoute.getContext().tInMap('httpCodes', 'databaseError')?? _noText;
  }

  static String get userNameOrPasswordIncorrect {
    return AppRoute.getContext().tInMap('httpCodes', 'userNameOrPasswordIncorrect')?? _noText;
  }

  static String get errorOccurredInSubmittedParameters {
    return AppRoute.getContext().tInMap('httpCodes', 'errorOccurredInSubmittedParameters')?? _noText;
  }

  static String get dataNotFound {
    return AppRoute.getContext().tInMap('httpCodes', 'dataNotFound')?? _noText;
  }

  static String get thisRequestNotDefined {
    return AppRoute.getContext().tInMap('httpCodes', 'thisRequestNotDefined')?? _noText;
  }

  static String get errorUploadingData {
    return AppRoute.getContext().tInMap('httpCodes', 'errorUploadingData')?? _noText;
  }

  static String get netConnectionIsDisconnect {
    return AppRoute.getContext().tC('netConnectionIsDisconnect')?? _noText;
  }

  static String get errorCommunicatingServer {
    return AppRoute.getContext().tC('errorCommunicatingServer')?? _noText;
  }

  static String get serverNotRespondProperly {
    return AppRoute.getContext().tC('serverNotRespondProperly')?? _noText;
  }

  static String get operationCannotBePerformed {
    return AppRoute.getContext().tC('operationCannotBePerformed')?? _noText;
  }

  static String get successOperation {
    return AppRoute.getContext().tC('successOperation')?? _noText;
  }

  static String get operationFailed {
    return AppRoute.getContext().tC('operationFailed')?? _noText;
  }

  static String get operationFailedTryAgain {
    return AppRoute.getContext().tC('operationFailedTryAgain')?? _noText;
  }

  static String get operationCanceled {
    return AppRoute.getContext().tC('operationCanceled')?? _noText;
  }

  static String get sorryYouDoNotHaveAccess {
    return AppRoute.getContext().tC('sorryYouDoNotHaveAccess')?? _noText;
  }

  static String get accountIsBlock {
    return AppRoute.getContext().tC('accountIsBlock')?? _noText;
  }

  static String get thereAreNoResults {
    return AppRoute.getContext().tC('thereAreNoResults')?? _noText;
  }
}