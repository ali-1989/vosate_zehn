import 'package:flutter/material.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/routeTools.dart';

class AppMessages {
  AppMessages._();

  static const _noText = 'NaT';

  static BuildContext _getContext(){
    return RouteTools.getTopContext()!;
  }
  
  static String httpMessage(String? cause) {
    if(cause == null){
      return errorOccur;
    }

    return _getContext().tInMap('httpCodes', cause)?? errorOccur;
  }

  static String get ok {
    return _getContext().tC('ok')?? _noText;
  }

  static String get yes {
    return _getContext().tC('yes')?? _noText;
  }

  static String get no {
    return _getContext().tC('no')?? _noText;
  }

  static String get select {
    return _getContext().tC('select')?? _noText;
  }

  static String get name {
    return _getContext().tC('name')?? _noText;
  }

  static String get family {
    return _getContext().tC('family')?? _noText;
  }

  static String get age {
    return _getContext().tC('age')?? _noText;
  }

  static String get gender {
    return _getContext().tC('gender')?? _noText;
  }

  static String get man {
    return _getContext().tC('man')?? _noText;
  }

  static String get woman {
    return _getContext().tC('woman')?? _noText;
  }

  static String get notice {
    return _getContext().t('notice')?? _noText;
  }

  static String get send {
    return _getContext().t('send')?? _noText;
  }

  static String get home {
    return _getContext().t('home')?? _noText;
  }

  static String get contactUs {
    return _getContext().t('contactUs')?? _noText;
  }

  static String get aboutUs {
    return _getContext().t('aboutUs')?? _noText;
  }

  static String get userName {
    return _getContext().t('userName')?? _noText;
  }

  static String get password {
    return _getContext().t('password')?? _noText;
  }

  static String get pay {
    return _getContext().t('pay')?? _noText;
  }

  static String get payWitIran {
    return _getContext().t('payWitIran')?? _noText;
  }

  static String get payWitPaypal {
    return _getContext().t('payWitPaypal')?? _noText;
  }

  static String get logout {
    return _getContext().t('logout')?? _noText;
  }

  static String get exit {
    return _getContext().t('exit')?? _noText;
  }

  static String get search {
    return _getContext().t('search')?? _noText;
  }

  static String get later {
    return _getContext().t('later')?? _noText;
  }

  static String get update {
    return _getContext().t('update')?? _noText;
  }

  static String get validation {
    return _getContext().tInMap('loginSection', 'validation')?? _noText;
  }

  static String get resendOtpCode {
    return _getContext().tInMap('loginSection', 'resendOtpCode')?? _noText;
  }

  static String get otpCodeIsResend {
    return _getContext().tInMap('loginSection', 'otpCodeIsResend')?? _noText;
  }

  static String get otpCodeIsInvalid {
    return _getContext().tInMap('loginSection', 'otpCodeIsInvalid')?? _noText;
  }

  static String get pleaseWait {
    return _getContext().t('pleaseWait')?? _noText;
  }

  static String get countrySelection {
    return _getContext().tInMap('countrySection', 'countrySelection')?? _noText;
  }

  static String get doYouWantLogoutYourAccount {
    return _getContext().tInMap('loginSection', 'doYouWantLogoutYourAccount')?? _noText;
  }

  static String get newAppVersionIsOk {
    return _getContext().t('newAppVersionIsOk')?? _noText;
  }

  static String get terms {
    return 'سیاست حفظ حریم خصوصی';
  }

  static String get mobileNumber {
    return _getContext().t('mobileNumber')?? _noText;
  }

  static String get loginBtn {
    return _getContext().t('login')?? _noText;
  }

  static String get loginWithGoogle {
    return 'ورود با گوگل';
  }

  static String get adminPageTitle {
    return 'صفحه ی مدیریت وسعت ذهن';
  }

  static String get changeNumber {
    return 'شماره ی دیگر';
  }

  static String get enterVerifyCode {
    return 'کد ارسال شده به شماره ی # را وارد کنید';
  }

  static String get pleaseEnterMobileToSendCode {
    return 'لطفا شماره موبایل خود را جهت ارسال کد وارد کنید';
  }

  static String get errorOccur {
    return _getContext().t('errorOccur')?? _noText;
  }

  static String get errorOccurTryAgain {
    return _getContext().t('errorOccurTryAgain')?? _noText;
  }

  static String get wantToLeave {
    return _getContext().tC('wantToLeave')?? _noText;
  }

  static String get e404 {
    return _getContext().tC('thisPageNotFound')?? _noText;
  }

  static String get tryAgain {
    return _getContext().t('tryAgain')?? _noText;
  }

  static String get requestKeyNotExist {
    return "'request' key not exist";
  }

  static String get requestDataIsNotJson {
    return 'request data is not a json';
  }

  static String get tokenIsIncorrectOrExpire {
    return _getContext().tInMap('httpCodes', 'tokenIsIncorrectOrExpire')?? _noText;
  }

  static String get databaseError {
    return _getContext().tInMap('httpCodes', 'databaseError')?? _noText;
  }

  static String get userNameOrPasswordIncorrect {
    return _getContext().tInMap('httpCodes', 'userNameOrPasswordIncorrect')?? _noText;
  }

  static String get errorOccurredInSubmittedParameters {
    return _getContext().tInMap('httpCodes', 'errorOccurredInSubmittedParameters')?? _noText;
  }

  static String get dataNotFound {
    return _getContext().tInMap('httpCodes', 'dataNotFound')?? _noText;
  }

  static String get thisRequestNotDefined {
    return _getContext().tInMap('httpCodes', 'thisRequestNotDefined')?? _noText;
  }

  static String get informationWasSend {
    return _getContext().tInMap('httpCodes', 'informationWasSend')?? _noText;
  }

  static String get errorUploadingData {
    return _getContext().tInMap('httpCodes', 'errorUploadingData')?? _noText;
  }

  static String get netConnectionIsDisconnect {
    return _getContext().tInMap('httpCodes', 'netConnectionIsDisconnect')?? _noText;
  }

  static String get errorCommunicatingServer {
    return _getContext().tInMap('httpCodes', 'errorCommunicatingServer')?? _noText;
  }

  static String get serverNotRespondProperly {
    return _getContext().tInMap('httpCodes', 'serverNotRespondProperly')?? _noText;
  }

  static String get accountIsBlock {
    return _getContext().tInMap('httpCodes', 'accountIsBlock')?? _noText;
  }

  static String get operationCannotBePerformed {
    return _getContext().tInMap('operationSection', 'operationCannotBePerformed')?? _noText;
  }

  static String get operationSuccess {
    return _getContext().tInMap('operationSection', 'successOperation')?? _noText;
  }

  static String get operationFailed {
    return _getContext().tInMap('operationSection', 'operationFailed')?? _noText;
  }

  static String get operationFailedTryAgain {
    return _getContext().tInMap('operationSection','operationFailedTryAgain')?? _noText;
  }

  static String get operationCanceled {
    return _getContext().tInMap('operationSection', 'operationCanceled')?? _noText;
  }

  static String get sorryYouDoNotHaveAccess {
    return _getContext().tC('sorryYouDoNotHaveAccess')?? _noText;
  }

  static String get youMustRegister {
    return _getContext().tC('youMustRegister')?? _noText;
  }

  static String get thereAreNoResults {
    return _getContext().tC('thereAreNoResults')?? _noText;
  }

  static String get appName {
    return 'وسعت ذهن';
  }

  static String get profileTitle {
    return _getContext().tC('profile')?? _noText;
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
    return 'چندبخشی';
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

  static String get welcome {
    return 'خوش آمدید';
  }

  static String get inEmailSignOutError {
    return 'هنگام خروج از ایمیل خطایی رخ داده است';
  }
}
