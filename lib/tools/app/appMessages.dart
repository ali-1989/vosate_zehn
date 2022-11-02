import 'package:app/tools/app/appRoute.dart';
import 'package:flutter/material.dart';
import '/system/extensions.dart';

class AppMessages {
  AppMessages._();

  static const _noText = 'n_n';

  static BuildContext getContext(){
    return AppRoute.getContext()!;
  }
  
  static String httpMessage(String? cause) {
    if(cause == null){
      return errorOccur;
    }

    return getContext().tInMap('httpCodes', cause)?? errorOccur;
  }

  static String get ok {
    return getContext().tC('ok')?? _noText;
  }

  static String get yes {
    return getContext().tC('yes')?? _noText;
  }

  static String get no {
    return getContext().tC('no')?? _noText;
  }

  static String get select {
    return getContext().tC('select')?? _noText;
  }

  static String get name {
    return getContext().tC('name')?? _noText;
  }

  static String get family {
    return getContext().tC('family')?? _noText;
  }

  static String get age {
    return getContext().tC('age')?? _noText;
  }

  static String get gender {
    return getContext().tC('gender')?? _noText;
  }

  static String get man {
    return getContext().tC('man')?? _noText;
  }

  static String get woman {
    return getContext().tC('woman')?? _noText;
  }

  static String get notice {
    return getContext().t('notice')?? _noText;
  }

  static String get send {
    return getContext().t('send')?? _noText;
  }

  static String get home {
    return getContext().t('home')?? _noText;
  }

  static String get contactUs {
    return getContext().t('contactUs')?? _noText;
  }

  static String get aboutUs {
    return getContext().t('aboutUs')?? _noText;
  }

  static String get userName {
    return getContext().t('userName')?? _noText;
  }

  static String get password {
    return getContext().t('password')?? _noText;
  }

  static String get pay {
    return getContext().t('pay')?? _noText;
  }

  static String get payWitIran {
    return getContext().t('payWitIran')?? _noText;
  }

  static String get payWitPaypal {
    return getContext().t('payWitPaypal')?? _noText;
  }

  static String get logout {
    return getContext().t('logout')?? _noText;
  }

  static String get exit {
    return getContext().t('exit')?? _noText;
  }

  static String get search {
    return getContext().t('search')?? _noText;
  }

  static String get later {
    return getContext().t('later')?? _noText;
  }

  static String get update {
    return getContext().t('update')?? _noText;
  }

  static String get validation {
    return getContext().tInMap('loginSection', 'validation')?? _noText;
  }

  static String get resendOtpCode {
    return getContext().tInMap('loginSection', 'resendOtpCode')?? _noText;
  }

  static String get otpCodeIsResend {
    return getContext().tInMap('loginSection', 'otpCodeIsResend')?? _noText;
  }

  static String get otpCodeIsInvalid {
    return getContext().tInMap('loginSection', 'otpCodeIsInvalid')?? _noText;
  }

  static String get pleaseWait {
    return getContext().t('pleaseWait')?? _noText;
  }

  static String get countrySelection {
    return getContext().tInMap('countrySection', 'countrySelection')?? _noText;
  }

  static String get doYouWantLogoutYourAccount {
    return getContext().tInMap('loginSection', 'doYouWantLogoutYourAccount')?? _noText;
  }

  static String get newAppVersionIsOk {
    return getContext().t('newAppVersionIsOk')?? _noText;
  }

  static String get terms {
    return 'سیاست حفظ حریم خصوصی';
  }

  static String get mobileNumber {
    return getContext().t('mobileNumber')?? _noText;
  }

  static String get loginBtn {
    return getContext().t('login')?? _noText;
  }

  static String get loginWithGoogle {
    return 'ورود با گوگل';
  }

  static String get adminPageTitle {
    return 'صفحه ی مدیریت وسعت ذهن';
  }

  static String get changeNumber {
    return 'شماره ی دیکر';
  }

  static String get enterVerifyCode {
    return 'کد ارسال شده به شماره ی # را وارد کنید';
  }

  static String get pleaseEnterMobileToSendCode {
    return 'لطفا شماره موبایل خود را جهت ارسال کد وارد کنید';
  }

  static String get errorOccur {
    return getContext().t('errorOccur')?? _noText;
  }

  static String get wantToLeave {
    return getContext().tC('wantToLeave')?? _noText;
  }

  static String get e404 {
    return getContext().tC('thisPageNotFound')?? _noText;
  }

  static String get tryAgain {
    return getContext().t('tryAgain')?? _noText;
  }

  static String get requestKeyNotExist {
    return "'request' key not exist";
  }

  static String get requestDataIsNotJson {
    return 'request data is not a json';
  }

  static String get tokenIsIncorrectOrExpire {
    return getContext().tInMap('httpCodes', 'tokenIsIncorrectOrExpire')?? _noText;
  }

  static String get databaseError {
    return getContext().tInMap('httpCodes', 'databaseError')?? _noText;
  }

  static String get userNameOrPasswordIncorrect {
    return getContext().tInMap('httpCodes', 'userNameOrPasswordIncorrect')?? _noText;
  }

  static String get errorOccurredInSubmittedParameters {
    return getContext().tInMap('httpCodes', 'errorOccurredInSubmittedParameters')?? _noText;
  }

  static String get dataNotFound {
    return getContext().tInMap('httpCodes', 'dataNotFound')?? _noText;
  }

  static String get thisRequestNotDefined {
    return getContext().tInMap('httpCodes', 'thisRequestNotDefined')?? _noText;
  }

  static String get informationWasSend {
    return getContext().tInMap('httpCodes', 'informationWasSend')?? _noText;
  }

  static String get errorUploadingData {
    return getContext().tInMap('httpCodes', 'errorUploadingData')?? _noText;
  }

  static String get netConnectionIsDisconnect {
    return getContext().tInMap('httpCodes', 'netConnectionIsDisconnect')?? _noText;
  }

  static String get errorCommunicatingServer {
    return getContext().tInMap('httpCodes', 'errorCommunicatingServer')?? _noText;
  }

  static String get serverNotRespondProperly {
    return getContext().tInMap('httpCodes', 'serverNotRespondProperly')?? _noText;
  }

  static String get accountIsBlock {
    return getContext().tInMap('httpCodes', 'accountIsBlock')?? _noText;
  }

  static String get operationCannotBePerformed {
    return getContext().tInMap('operationSection', 'operationCannotBePerformed')?? _noText;
  }

  static String get operationSuccess {
    return getContext().tInMap('operationSection', 'successOperation')?? _noText;
  }

  static String get operationFailed {
    return getContext().tInMap('operationSection', 'operationFailed')?? _noText;
  }

  static String get operationFailedTryAgain {
    return getContext().tInMap('operationSection','operationFailedTryAgain')?? _noText;
  }

  static String get operationCanceled {
    return getContext().tInMap('operationSection', 'operationCanceled')?? _noText;
  }

  static String get sorryYouDoNotHaveAccess {
    return getContext().tC('sorryYouDoNotHaveAccess')?? _noText;
  }

  static String get thereAreNoResults {
    return getContext().tC('thereAreNoResults')?? _noText;
  }

  static String get appName {
    return 'وسعت ذهن';
  }

  static String get profileTitle {
    return getContext().tC('profile')?? _noText;
  }

  static String get loginTitle {
    return 'ورود';
  }

  static String get registerTitle {
    return 'ثبت نام';
  }

  static String get aboutUsTitle {
    return 'درباره ما';
  }

  static String get termTitle {
    return 'سیاست حریم خصوصی';
  }

  static String get enterCountryCode {
    return 'کد کشور را وارد کنید';
  }

  static String get enterPhoneNumber {
    return 'شماره موبایل خود را وارد کنید';
  }

  static String get pleaseEnterVerifyCode {
    return 'لطفا کد ارسال شده را وارد کنید';
  }

  static String get pleaseEnterNameFamily {
    return 'لطفا نام و نام خانوادگی خود را کامل وارد کنید';
  }

  static String get enterName {
    return 'لطفا نام خود را وارد کنید';
  }

  static String get enterFamily {
    return 'لطفا نام خانوادگی خود را وارد کنید';
  }

  static String get pleaseSelectAge {
    return 'لطفا سن خود را انتخاب کنید';
  }

  static String get meditation {
    return 'مدیتیشن';
  }

  static String get focus {
    return 'تمرکز';
  }

  static String get motion {
    return 'حرکت';
  }

  static String get video {
    return 'فیلم';
  }

  static String get aid {
    return 'حمایت';
  }

  static String get aidUs {
    return 'حمایت از ما';
  }

  static String get favorites {
    return 'منتخب ها';
  }

  static String get lastSeenItem {
    return 'آخرین بازدیدها';
  }

  static String get sentencesTitle {
    return 'جملات روز';
  }

  static String get shareApp {
    return 'اشتراک اپلیکیشن';
  }

  static String get contactUsDescription {
    return 'سوال ، انتقاد و یا پیشنهاد خود را برای ما بنویسید';
  }

  static String get contactUsEmptyPrompt {
    return 'لطفا متن خود را بنویسید';
  }

  static String get pleaseKeepOrder {
    return 'لطفا ترتیب موارد را رعایت کنید';
  }

  static String get isAddToFavorite {
    return 'به منتخب ها اضافه شد';
  }

  static String get email {
    return 'ایمیل';
  }

  static String get mobile {
    return 'موبایل';
  }
}
