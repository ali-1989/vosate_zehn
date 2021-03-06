import '/system/extensions.dart';

import 'package:vosate_zehn/tools/app/appRoute.dart';

class AppMessages {
  AppMessages._();

  static const _noText = 'n_n';

  static String httpMessage(String? cause) {
    if(cause == null){
      return errorOccur;
    }

    return AppRoute.getContext().tInMap('httpCodes', cause)?? errorOccur;
  }

  static String get ok {
    return AppRoute.getContext().tC('ok')?? _noText;
  }

  static String get yes {
    return AppRoute.getContext().tC('yes')?? _noText;
  }

  static String get no {
    return AppRoute.getContext().tC('no')?? _noText;
  }

  static String get select {
    return AppRoute.getContext().tC('select')?? _noText;
  }

  static String get name {
    return AppRoute.getContext().tC('name')?? _noText;
  }

  static String get family {
    return AppRoute.getContext().tC('family')?? _noText;
  }

  static String get age {
    return AppRoute.getContext().tC('age')?? _noText;
  }

  static String get gender {
    return AppRoute.getContext().tC('gender')?? _noText;
  }

  static String get man {
    return AppRoute.getContext().tC('man')?? _noText;
  }

  static String get woman {
    return AppRoute.getContext().tC('woman')?? _noText;
  }

  static String get notice {
    return AppRoute.getContext().t('notice')?? _noText;
  }

  static String get send {
    return AppRoute.getContext().t('send')?? _noText;
  }

  static String get home {
    return AppRoute.getContext().t('home')?? _noText;
  }

  static String get contactUs {
    return AppRoute.getContext().t('contactUs')?? _noText;
  }

  static String get aboutUs {
    return AppRoute.getContext().t('aboutUs')?? _noText;
  }

  static String get validation {
    return AppRoute.getContext().tInMap('loginSection', 'validation')?? _noText;
  }

  static String get resendOtpCode {
    return AppRoute.getContext().tInMap('loginSection', 'resendOtpCode')?? _noText;
  }

  static String get otpCodeIsResend {
    return AppRoute.getContext().tInMap('loginSection', 'otpCodeIsResend')?? _noText;
  }

  static String get otpCodeIsInvalid {
    return AppRoute.getContext().tInMap('loginSection', 'otpCodeIsInvalid')?? _noText;
  }

  static String get pleaseWait {
    return AppRoute.getContext().t('pleaseWait')?? _noText;
  }

  static String get countrySelection {
    return AppRoute.getContext().tInMap('countrySection', 'countrySelection')?? _noText;
  }

  static String get terms {
    return '?????????? ?????? ???????? ??????????';
  }

  static String get mobileNumber {
    return AppRoute.getContext().t('mobileNumber')?? _noText;
  }

  static String get loginWithGoogle {
    return '???????? ???? ????????';
  }

  static String get changeNumber {
    return '?????????? ?? ????????';
  }

  static String get enterVerifyCode {
    return '???? ?????????? ?????? ???? ?????????? ?? # ???? ???????? ????????';
  }

  static String get pleaseEnterMobileToSendCode {
    return '???????? ?????????? ???????????? ?????? ???? ?????? ?????????? ???? ???????? ????????';
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

  static String get appName {
    return '???????? ??????';
  }

  static String get loginTitle {
    return '????????';
  }

  static String get registerTitle {
    return '?????? ??????';
  }

  static String get termTitle {
    return '?????????? ???????? ??????????';
  }

  static String get enterCountryCode {
    return '???? ???????? ???? ???????? ????????';
  }

  static String get enterPhoneNumber {
    return '?????????? ???????????? ?????? ???? ???????? ????????';
  }

  static String get pleaseEnterVerifyCode {
    return '???????? ???? ?????????? ?????? ???? ???????? ????????';
  }

  static String get pleaseEnterNameFamily {
    return '???????? ?????? ?? ?????? ???????????????? ?????? ???? ???????? ???????? ????????';
  }

  static String get pleaseSelectAge {
    return '???????? ???? ?????? ???? ???????????? ????????';
  }

  static String get meditation {
    return '??????????????';
  }

  static String get tamarkoz {
    return '??????????';
  }

  static String get motion {
    return '????????';
  }

  static String get video {
    return '????????';
  }

  static String get hematat {
    return '??????????';
  }

  static String get hematatUs {
    return '?????????? ???? ????';
  }

  static String get favorites {
    return '?????????? ????';
  }

  static String get lastSeenItem {
    return '?????????? ????????????????';
  }

  static String get shareApp {
    return '???????????? ????????????????';
  }
}