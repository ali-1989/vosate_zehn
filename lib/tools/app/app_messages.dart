import 'package:flutter/material.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/route_tools.dart';

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

  static String operationMessage(String key) {
    return _getContext().tInMap('operationSection', key)?? _noText;
  }

  static String loginMessage(String key) {
    return _getContext().tInMap('loginSection', key)?? _noText;
  }

  static String registerMessage(String key) {
    return _getContext().tInMap('registerSection', key)?? _noText;
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

  static String get next {
    return _getContext().t('next')?? _noText;
  }

  static String get home {
    return _getContext().t('home')?? _noText;
  }

  static String get start {
    return _getContext().t('start')?? _noText;
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
  
  static String get register {
    return _getContext().t('register')?? _noText;
  }

  static String get logout {
    return _getContext().t('logout')?? _noText;
  }

  static String get exit {
    return _getContext().t('exit')?? _noText;
  }

  static String get back {
    return _getContext().t('back')?? _noText;
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

  static String get save {
    return _getContext().t('save')?? _noText;
  }

  static String get downloadNewVersion {
    return _getContext().t('downloadNewVersion')?? _noText;
  }

  static String get directDownload {
    return _getContext().t('directDownload')?? _noText;
  }

  static String get validation {
    return loginMessage('validation');
  }

  static String get resendOtpCode {
    return loginMessage('resendOtpCode');
  }

  static String get otpCodeIsResend {
    return loginMessage('otpCodeIsResend');
  }

  static String get otpCodeIsInvalid {
    return loginMessage('otpCodeIsInvalid');
  }

  static String get doYouWantLogoutYourAccount {
    return loginMessage('doYouWantLogoutYourAccount');
  }

  static String get loginWithGoogle {
    return loginMessage('loginWithGoogle');
  }

  static String get countrySelection {
    return _getContext().tInMap('countrySection', 'countrySelection')?? _noText;
  }

  static String get newAppVersionIsOk {
    return _getContext().t('newAppVersionIsOk')?? _noText;
  }

  static String get pleaseWait {
    return _getContext().t('pleaseWait')?? _noText;
  }

  static String get termPolice {
    return _getContext().t('termPolice')?? _noText;
  }

  static String get mobileNumber {
    return _getContext().t('mobileNumber')?? _noText;
  }

  static String get loginBtn {
    return _getContext().t('login')?? _noText;
  }

  static String get otherNumber {
    return registerMessage('otherNumber');
  }

  static String get enterVerifyCodeDesc {
    return registerMessage('validationDescription');
  }

 static String get pleaseEnterAPassword {
    return registerMessage('selectPassword');
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

  static String get tokenIsIncorrectOrExpire {
    return httpMessage('tokenIsIncorrectOrExpire');
  }

  static String get databaseError {
    return httpMessage('databaseError');
  }

  static String get userNameOrPasswordIncorrect {
    return httpMessage('userNameOrPasswordIncorrect');
  }

  static String get errorOccurredInSubmittedParameters {
    return httpMessage('errorOccurredInSubmittedParameters');
  }

  static String get dataNotFound {
    return httpMessage('dataNotFound');
  }

  static String get thisRequestNotDefined {
    return httpMessage('thisRequestNotDefined');
  }

  static String get informationWasSend {
    return httpMessage('informationWasSend');
  }

  static String get errorUploadingData {
    return httpMessage('errorUploadingData');
  }

  static String get netConnectionIsDisconnect {
    return httpMessage('netConnectionIsDisconnect');
  }

  static String get errorCommunicatingServer {
    return httpMessage('errorCommunicatingServer');
  }

  static String get serverNotRespondProperly {
    return httpMessage('serverNotRespondProperly');
  }

  static String get accountIsBlock {
    return httpMessage('accountIsBlock');
  }

  static String get operationCannotBePerformed {
    return operationMessage('operationCannotBePerformed');
  }

  static String get operationSuccess {
    return operationMessage('successOperation');
  }

  static String get operationFailed {
    return operationMessage('operationFailed');
  }

  static String get operationFailedTryAgain {
    return operationMessage('operationFailedTryAgain');
  }

  static String get operationCanceled {
    return operationMessage('operationCanceled');
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
  
  static String get requestDataIsNotJson {
    return 'request data is not a json';
  }
  
  static String get requestKeyNotExist {
    return "'request' key not exist";
  }

  static String get unKnow {
    return _getContext().t('unknown')?? _noText;
  }

  static String get open {
    return _getContext().t('open')?? _noText;
  }

  static String get close {
    return _getContext().t('close')?? _noText;
  }

  ///-----------------------------------------------------------------------------------
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

  static String get notCorrectMobileInfo {
    return 'شماره موبایل پذیرفته نیست';
  }

  static String get mustLiveInIran {
    return 'فقط برای کاربران داخل ایران';
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
  
  static String get payWitIran {
    return _getContext().t('payWitIran')?? _noText;
  }

  static String get payWitPaypal {
    return _getContext().t('payWitPaypal')?? _noText;
  }
  
  static String get adminPageTitle {
    return 'صفحه ی مدیریت وسعت ذهن';
  }

  static String get pleaseSelectOneOption {
    return 'لطفا یکی از گزینه ها را انتخاب کنید';
  }

  static String get pleaseEnterMobileToSendCode {
    return 'لطفا شماره موبایل خود را جهت ارسال کد وارد کنید';
  }

  static String get pleaseEnterEmailToSendVerifyEmail {
    return 'لطفا آدرس ایمیل خود را جهت ورود وارد کنید';
  }

  static String get pleaseEnterEmailToRegistering {
    return 'لطفا آدرس ایمیل خود را جهت ثبت نام وارد کنید';
  }
}
