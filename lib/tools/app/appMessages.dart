import '/system/extensions.dart';

import 'package:vosate_zehn/tools/app/appRoute.dart';

class AppMessages {
  AppMessages._();

  static const _noText = "n_n";

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
    return AppRoute.getContext().t('notice')?? _noText;
  }

  static String get pleaseWait {
    return AppRoute.getContext().t('pleaseWait')?? _noText;
  }

  static String get errorOccur {
    return AppRoute.getContext().t('errorOccur')?? _noText;
  }

  static String get wantToLeave {
    return AppRoute.getContext().tC('wantToLeave')?? _noText;
  }

  static String get e404 {
    return AppRoute.getContext().tC('thisPageNotFound')?? _noText;
  }

  static String get requestKeyNotExist {
    return "'request' key not exist";
  }

  static String get requestDataIsNotJson {
    return 'request data is not a json';
  }

  static String get tokenIsIncorrectOrExpire {
    return AppRoute.getContext().tInMap('httpCodes', 'tokenIsIncorrectOrExpire')?? _noText;
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

  static String get informationWasSend {
    return AppRoute.getContext().tInMap('httpCodes', 'informationWasSend')?? _noText;
  }

  static String get errorUploadingData {
    return AppRoute.getContext().tInMap('httpCodes', 'errorUploadingData')?? _noText;
  }

  static String get netConnectionIsDisconnect {
    return AppRoute.getContext().tInMap('httpCodes', 'netConnectionIsDisconnect')?? _noText;
  }

  static String get errorCommunicatingServer {
    return AppRoute.getContext().tInMap('httpCodes', 'errorCommunicatingServer')?? _noText;
  }

  static String get serverNotRespondProperly {
    return AppRoute.getContext().tInMap('httpCodes', 'serverNotRespondProperly')?? _noText;
  }

  static String get accountIsBlock {
    return AppRoute.getContext().tInMap('httpCodes', 'accountIsBlock')?? _noText;
  }

  static String get operationCannotBePerformed {
    return AppRoute.getContext().tInMap('operationSection', 'operationCannotBePerformed')?? _noText;
  }

  static String get operationSuccess {
    return AppRoute.getContext().tInMap('operationSection', 'successOperation')?? _noText;
  }

  static String get operationFailed {
    return AppRoute.getContext().tInMap('operationSection', 'operationFailed')?? _noText;
  }

  static String get operationFailedTryAgain {
    return AppRoute.getContext().tInMap('operationSection','operationFailedTryAgain')?? _noText;
  }

  static String get operationCanceled {
    return AppRoute.getContext().tInMap('operationSection', 'operationCanceled')?? _noText;
  }

  static String get sorryYouDoNotHaveAccess {
    return AppRoute.getContext().tC('sorryYouDoNotHaveAccess')?? _noText;
  }

  static String get thereAreNoResults {
    return AppRoute.getContext().tC('thereAreNoResults')?? _noText;
  }

  static String get loginTitle {
    return 'ورود';
  }
}