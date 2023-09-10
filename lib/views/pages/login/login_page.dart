import 'dart:async';

import 'package:app/services/google_service.dart';
import 'package:app/tools/app/appLoading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';
import 'package:iris_tools/widgets/page_switcher.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/countryModel.dart';
import 'package:app/system/commonHttpHandler.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/countryTools.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/countrySelect.dart';
import 'package:app/views/components/phoneNumberInput.dart';
import 'package:app/views/pages/login/register_page.dart';
import 'package:app/views/pages/term_page.dart';

class LoginPage extends StatefulWidget{

  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
///=================================================================================================
class _LoginPageState extends StateBase<LoginPage> {
  TextEditingController pinCodeCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();
  late PhoneNumberInputController phoneNumberController;
  PageSwitcherController pageCtr = PageSwitcherController();
  late final StopWatchTimer stopWatchTimer;
  CountryModel countryModel = CountryModel();
  String phoneNumber = '';
  String pinCode = '';
  int timerValueSec = 60;
  bool showResendOtpButton = false;
  late final bool isWeb;
  String countryIso = WidgetsBinding.instance.platformDispatcher.locale.countryCode?? 'IR';
  late bool isIran;


  @override
  void initState(){
    super.initState();

    isWeb = kIsWeb;
    isIran = countryIso == 'IR';

    LoginService.findCountryWithIP().then((value) {
      countryIso = value;
      isIran = countryIso == 'IR';
      assistCtr.updateHead();
    });

    phoneNumberController = PhoneNumberInputController();
    phoneNumberController.setOnTapCountryArrow(onTapCountryArrow);

    CountryTools.fetchCountries().then((value) {
      countryModel = CountryTools.countryModelByCountryIso('IR');
      assistCtr.updateHead();
    });

    stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      isLapHours: false,
      presetMillisecond: timerValueSec*1000,
      onEnded: (){
        showResendOtpButton = true;
        assistCtr.updateHead();
      },
    );
  }

  @override
  void dispose(){
    stopWatchTimer.dispose();
    emailCtr.dispose();
    passwordCtr.dispose();
    pinCodeCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          backgroundColor: AppThemes.instance.currentTheme.primaryColor,
          body: SafeArea(
              child: buildBody()
          ),
        );
      }
    );
  }

  Widget buildBody(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MathHelper.percent(sh, 30),
            child: Center(
              child: Image.asset(AppImages.appIcon, width: 100, height: 100),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Align(
                child: PageSwitcher(
                  controller: pageCtr,
                  pages: [
                    buildFirstPage(),
                    buildEnterWithEmailForWeb(),
                    buildRegisterEmailForWeb(),
                    buildEnterWithMobileForWeb(),
                    buildPinCodePage(),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFirstPage(){
    if(isWeb || !isIran){
      return buildStartPageForWebOrMobileOutSideIran();
    }

    return buildFirstPageForMobileInIran();
  }

  Widget buildStartPageForWebOrMobileOutSideIran() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(AppMessages.welcome).fsR(2).bold(),

            Text(AppMessages.pleaseSelectOneOption,
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onEnterWithEmailClick,
                  child: Text('ورود با ایمیل')
              ),
            ),

            const SizedBox(height: 8),
            Builder(builder: (_){
              if(canShowEnterWithMobile()){
                return SizedBox(
                  width: 200,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      onPressed: onEnterWithMobileForWebClick,
                      child: Text('ورود با شماره موبایل')
                  ),
                );
              }

              /// sign by Gmail
              return SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: AppThemes.instance.currentTheme.differentColor,
                    ),
                    onPressed: (){
                      signWithGoogleClick();
                    },
                    icon: Image.asset(AppImages.googleIco, width: 20, height: 20,),
                    label: Text(AppMessages.loginWithGoogle)
                ),
              );
            }),

            const SizedBox(height: 8),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: AppThemes.instance.currentTheme.differentColor,
                  ),
                  onPressed: onEnterToRegisterEmailForWebClick,
                  child: Text('ثبت نام با ایمیل')
              ),
            ),

            /// enter guest
            const SizedBox(height: 8),
            TextButton(
              child: const Text('ورود مهمان'),
              onPressed: (){
                LoginService.loginGuestUser(context);
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildFirstPageForMobileInIran() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          //shrinkWrap: true,
          //padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 30),
            Text(AppMessages.pleaseEnterMobileToSendCode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            PhoneNumberInput(
              controller: phoneNumberController,
              countryCode: countryIso == 'IR'? countryModel.countryPhoneCode : '',
              numberHint: AppMessages.mobileNumber,
              showCountrySection: countryIso == 'IR',
            ),

            const SizedBox(height: 30),

            /// send Btn
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: onSendBtnForPinClick,
                  child: Text(AppMessages.send)
              ),
            ),
            /*SizedBox(
              width: double.maxFinite,
              child: ,
            ),*/

            /// sign by Gmail
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: AppThemes.instance.currentTheme.differentColor,
                  ),
                  onPressed: (){
                    signWithGoogleClick();
                  },
                  icon: Image.asset(AppImages.googleIco, width: 20, height: 20,),
                  label: Text(AppMessages.loginWithGoogle)
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
                onPressed: gotoTermPage,
                child: Text(AppMessages.terms).fsR(-3)
            ),

            /// enter guest
            const SizedBox(height: 2),
            TextButton(
              child: const Text('ورود مهمان').fsR(-1),
              onPressed: (){
                LoginService.loginGuestUser(context);
              },
            ),


            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildFirstPageForMobileOutSideIran() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          //shrinkWrap: true,
          //padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 30),
            Text(AppMessages.pleaseEnterMobileToSendCode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            PhoneNumberInput(
              controller: phoneNumberController,
              countryCode: countryIso == 'IR'? countryModel.countryPhoneCode : '',
              numberHint: AppMessages.mobileNumber,
              showCountrySection: countryIso == 'IR',
            ),

            const SizedBox(height: 10),

            /// send Btn
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: onSendBtnForPinClick,
                  child: Text(AppMessages.send)
              ),
            ),

            /// sign by Gmail
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: AppThemes.instance.currentTheme.differentColor,
                  ),
                  onPressed: (){
                    signWithGoogleClick();
                  },
                  icon: Image.asset(AppImages.googleIco, width: 20, height: 20,),
                  label: Text(AppMessages.loginWithGoogle)
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
                onPressed: gotoTermPage,
                child: Text(AppMessages.terms).fsR(-3)
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildEnterWithEmailForWeb() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(AppMessages.pleaseEnterEmailToSendVerifyEmail,
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 30),
            TextField(
              controller: emailCtr,
              decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                hintText: 'ایمیل',
              ),
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
            ),

            const SizedBox(height: 8),

            AutoDirection(
              builder: (BuildContext context, AutoDirectionController direction) {
                return TextField(
                  controller: passwordCtr,
                  decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                    hintText: 'رمز عبور',
                  ),
                  keyboardType: TextInputType.text,
                  textDirection: direction.getTextDirection(passwordCtr.text),
                  onChanged: (v){
                    direction.onChangeText(v);
                  },
                );
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: loginWithEmail,
                  child: Text(AppMessages.loginBtn)
              ),
            ),

            TextButton(
              child: Text(AppMessages.back),
              onPressed: (){
                pageCtr.changePageTo(0);
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildRegisterEmailForWeb() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(AppMessages.pleaseEnterEmailToRegistering,
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 30),
            TextField(
              controller: emailCtr,
              decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                hintText: 'ایمیل',
              ),
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
            ),

            const SizedBox(height: 20),

            Align(
                alignment: Alignment.topRight,
                child: Text(AppMessages.pleaseEnterAPassword, style: const TextStyle(fontWeight: FontWeight.bold))),

            const SizedBox(height: 8),

            AutoDirection(
              builder: (BuildContext context, AutoDirectionController direction) {
                return TextField(
                  controller: passwordCtr,
                  decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                    hintText: 'رمز عبور',
                  ),
                  keyboardType: TextInputType.text,
                  textDirection: direction.getTextDirection(passwordCtr.text),
                  onChanged: (v){
                    direction.onChangeText(v);
                  },
                );
              },
            ),

            const SizedBox(height: 25),
            TextButton(
                onPressed: gotoTermPage,
                child: Text(AppMessages.terms).fsR(-3)
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: onRegisterEmailClick,
                  child: Text(AppMessages.register)
              ),
            ),
            const SizedBox(height: 10),
            UnconstrainedBox(
              child: TextButton(
                  onPressed: (){
                    pageCtr.changePageTo(0);
                  },
                  child: Text(AppMessages.back)
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildEnterWithMobileForWeb() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          //shrinkWrap: true,
          //padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 30),
            Text(AppMessages.pleaseEnterMobileToSendCode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            PhoneNumberInput(
              controller: phoneNumberController,
              countryCode: countryIso == 'IR'? countryModel.countryPhoneCode : '',
              numberHint: AppMessages.mobileNumber,
              showCountrySection: countryIso == 'IR',
            ),

            const SizedBox(height: 25),
            TextButton(
                onPressed: gotoTermPage,
                child: Text(AppMessages.terms).fsR(-3)
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: onSendBtnForPinClick,
                  child: Text(AppMessages.send)
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              child: Text(AppMessages.back),
              onPressed: (){
                pageCtr.changePageTo(0);
              },
            ),

            const SizedBox(height: 32,),
          ],
        ),
      ),
    );
  }

  Widget buildPinCodePage(){
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          //shrinkWrap: true,
          //padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 30),
            Text(AppMessages.enterVerifyCode.replaceFirst('#', LocaleHelper.overrideLtr('${countryModel.countryPhoneCode} $phoneNumber')),
              style: const TextStyle(fontWeight: FontWeight.bold),),

            const SizedBox(height: 10,),

            Directionality(
              textDirection: TextDirection.ltr,
              child: PinCodeTextField(
                controller: pinCodeCtr,
                autoDisposeControllers: false,
                appContext: context,
                length: 4,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.grey[200],
                ),
                animationDuration: const Duration(milliseconds: 400),
                backgroundColor: Colors.transparent,
                enableActiveFill: false,
                keyboardType: TextInputType.number,
                onCompleted: (v) {
                },
                onChanged: (value) {
                  pinCode = value;
                },
                beforeTextPaste: (text) {
                  //if return true then it will show the paste confirmation dialog. Otherwise nothing will happen.
                  return true;
                },
              ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: onChangeNumberCall,
                    child: Text(AppMessages.changeNumber)
                ),

                Row(
                  children: [
                    Visibility(
                        visible: showResendOtpButton,
                        child: TextButton(
                            onPressed: resetTimer,
                            child: Text(AppMessages.resendOtpCode, style: const TextStyle(color: Colors.red))
                        )
                    ),

                    Visibility(
                      visible: !showResendOtpButton,
                      child: StreamBuilder<int>(
                        stream: stopWatchTimer.rawTime,
                        initialData: 0,
                        builder: (context, snap) {
                          final value = snap.data;
                          final displayTime = StopWatchTimer.getDisplayTime(value!, hours: false, milliSecond: false, minute: false);
                          return Text('  $displayTime  ',);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 25),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: onValidationCall,
                  child: Text(AppMessages.validation)
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  /*Widget buildFrontFlipWithEmail() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(AppMessages.pleaseEnterEmailToSendVerifyEmail,
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 30),
            TextField(
              controller: emailCtr,
              decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                hintText: 'ایمیل',
              ),
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
            ),

            const SizedBox(height: 8),

            AutoDirection(
              builder: (BuildContext context, AutoDirectionController direction) {
                return TextField(
                  controller: passwordCtr,
                  decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                    hintText: 'رمز عبور',
                  ),
                  keyboardType: TextInputType.text,
                  textDirection: direction.getTextDirection(passwordCtr.text),
                  onChanged: (v){
                    direction.onChangeText(v);
                  },
                );
              },
            ),

            const SizedBox(height: 25),
            TextButton(
                onPressed: gotoTermPage,
                child: Text(AppMessages.terms).fsR(-3)
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: 200,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: onSendBtnForPinClick,
                  child: Text(AppMessages.loginBtn)
              ),
            ),
            *//*SizedBox(
              width: double.maxFinite,
              child: ,
            ),*//*

            const SizedBox(height: 10),
            UnconstrainedBox(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: AppThemes.instance.currentTheme.differentColor,
                  ),
                  onPressed: signWithMobileClick,
                  child: const Text('ورود با شماره موبایل')
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text('ورود مهمان'),
                  onPressed: (){
                    LoginService.loginGuestUser(context);
                  },
                ),

                Visibility(
                  visible: !mustLoginByMobileNumber,
                    child: Row(
                      children: [
                        Text('  /  '),

                        TextButton(
                          child: const Text('ثبت نام'),
                          onPressed: (){
                            inRegisterEmailMode = true;
                            assistCtr.updateHead();
                          },
                        ),
                      ],
                    )
                )
              ],
            ),

            const SizedBox(height: 32,),
          ],
        ),
      ),
    );
  }
  */

  /*void signWithMobileClick() {
    if(!isIran){
      AppToast.showToast(context, AppMessages.mustLiveInIran);
    }

    mustLoginByMobileNumber = true;
    assistCtr.updateHead();
  }*/

  void onChangeNumberCall() async {
    pinCode = '';
    pageCtr.changePageTo(0);
  }

  void resetTimer(){
    stopWatchTimer.setPresetTime(mSec: timerValueSec);
    stopWatchTimer.onResetTimer();
    stopWatchTimer.onStartTimer();

    reSendOtpCodeCall();

    showResendOtpButton = false;
    pinCodeCtr.clear();

    assistCtr.updateHead();
  }

  void onTapCountryArrow() async {
    final value = await RouteTools.pushPage(context, const CountrySelectScreen());

    if(value is CountryModel){
      countryModel = value;
      phoneNumberController.getCountryController()?.text = countryModel.countryPhoneCode!;
    }
  }

  void gotoTermPage(){
    RouteTools.pushPage(context, const TermPage());
  }

  void onSendBtnForPinClick(){
    prepareSendOtp();
  }

  void prepareSendOtp(){
    countryModel.countryPhoneCode = phoneNumberController.getCountryCode()!;
    phoneNumber = phoneNumberController.getPhoneNumber()!;

    /*if(countryModel.countryPhoneCode!.isEmpty){
      AppSnack.showInfo(context, AppMessages.enterCountryCode);
      return;
    }*/

    if(phoneNumber.isEmpty){
      AppSnack.showInfo(context, AppMessages.enterPhoneNumber);
      return;
    }

    if(!countryModel.countryPhoneCode!.startsWith('+')){
      countryModel.countryPhoneCode = '+${countryModel.countryPhoneCode}';
    }

    if(phoneNumber.startsWith('0')){
      phoneNumber = phoneNumber.substring(1);
    }

    if(phoneNumber.startsWith('+')){
      AppSnack.showInfo(context, AppMessages.notCorrectMobileInfo);
      return;
    }

    showResendOtpButton = false;
    stopWatchTimer.onResetTimer();
    stopWatchTimer.onStartTimer();

    callState();

    LoginService.requestSendOtp(countryModel: countryModel, phoneNumber: phoneNumber).then((value) {
      if(value == null){
        AppToast.showToast(context, AppMessages.errorCommunicatingServer);
      }
    });

    pinCodeCtr.text = '';
    pageCtr.changePageTo(4);
  }

  void reSendOtpCodeCall() async {
    LoginService.requestSendOtp(countryModel: countryModel, phoneNumber: phoneNumber);
    AppToast.showToast(context, AppMessages.otpCodeIsResend);
  }

  void onValidationCall() async {
    if(pinCode.length != 4){
      AppSheet.showSheetOk(context, AppMessages.pleaseEnterVerifyCode);
      return;
    }

    final injectData = RegisterPageInjectData();
    injectData.countryModel = countryModel;
    injectData.mobileNumber = phoneNumber;

    final twoState = await LoginService.requestVerifyOtp(countryModel: countryModel, phoneNumber: phoneNumber, code: pinCode);

    if(twoState.hasResult1()){
      final status = twoState.result1![Keys.status];

      if(status == Keys.error){
        final causeCode = twoState.result1![Keys.causeCode]?? 0;

        if(causeCode == HttpCodes.error_dataNotExist){
          /**/
        }
        else if(causeCode == HttpCodes.error_userIsBlocked){
          AppSheet.showSheet$AccountIsBlock(context);
          return;
        }
      }
      else {
        final userId = twoState.result1![Keys.userId];

        if (userId == null) {
          RouteTools.pushPage(context, RegisterPage(injectData: injectData));
        }
        else {
          final userModel = await SessionService.login$newProfileData(twoState.result1!);

          if(userModel != null) {
            //RouteTools.pushPage(context, LayoutPage(key: AppBroadcast.layoutPageKey));
            AppBroadcast.reBuildMaterial();
          }
          else {
            AppSheet.showSheet$OperationFailed(context);
          }
        }
      }
    }
    else {
      AppSheet.showSheet$ErrorCommunicatingServer(context);
      return;
    }
  }

  void onRegisterEmailClick() async {
    final email = emailCtr.text.trim();
    final password = passwordCtr.text.trim();

    if(!Checker.isValidEmail(email)){
      AppSnack.showInfo(context, 'ایمیل وارد شده صحیح نیست');
      return;
    }

    if(password.length < 4 || password.length > 12){
      AppSnack.showInfo(context, 'طول رمز عبور بین 4 تا 12 حرف می باشد');
      return;
    }

    showLoading();
    final (state, mEmail) = await LoginService.requestCheckEmailAndSendVerify(email: email, password: password);
    await hideLoading();
    await System.wait(const Duration(milliseconds: 300));

    if(state == EmailVerifyStatus.error){
      AppSheet.showSheet$OperationFailedTryAgain(context);
      return;
    }

    if(state == EmailVerifyStatus.mustLogin) {
      pageCtr.changePageTo(1);
      AppSheet.showSheetOk(context, 'این ایمیل وجود دارد، لطفا وارد شوید');
    }
    else if(state == EmailVerifyStatus.mustRegister){
      final injectData = RegisterPageInjectData();
      injectData.email = email;

      RouteTools.pushPage(context, RegisterPage(injectData: injectData));
    }
    else if(state == EmailVerifyStatus.waitToVerify){
      AppSheet.showSheetOk(context, 'ایمیلی جهت فعال ساری برای شما ارسال شد، لطفا روی لینک فعال سازی کلیک کنید.');
      pageCtr.changePageTo(1);
    }
  }

  void loginWithEmail() async {
    final email = emailCtr.text.trim();
    final password = passwordCtr.text.trim();

    if(!Checker.isValidEmail(email)){
      AppSnack.showInfo(context, 'ایمیل وارد شده صحیح نیست');
      return;
    }

    if(password.length < 4 || password.length > 12){
      AppSnack.showInfo(context, 'طول رمز عبور بین 4 تا 12 حرف می باشد');
      return;
    }

    showLoading();
    final (status, txt) = await LoginService.requestLoginWithEmail(email: email, password: password);
    await hideLoading();
    await System.wait(const Duration(milliseconds: 300));

    if(status == EmailLoginStatus.error){
      AppSheet.showSheet$OperationFailedTryAgain(context);
    }
    else if(status == EmailLoginStatus.inCorrectUserPass) {
      AppSheet.showSheetOk(context, 'ایمیل یا رمز اشتباه است');
    }
    else if(status == EmailLoginStatus.mustRegister){
      final injectData = RegisterPageInjectData();
      injectData.email = email;

      RouteTools.pushPage(context, RegisterPage(injectData: injectData));
    }
    else if(status == EmailLoginStatus.waitToVerify){
      AppSheet.showSheetOk(context, 'ایمیلی جهت فعال ساری برای شما ارسال شد، لطفا روی لینک فعال سازی کلیک کنید.');
    }
  }

  void signWithGoogleClick() async {
    final google = GoogleService();

    AppLoading.instance.showWaiting(context);
    GoogleSignInAccount? googleResult;

    final timer = Timer(const Duration(seconds: kIsWeb? 300: 60), (){
      AppLoading.instance.hideLoading(context);
      AppSheet.showSheet$OperationFailed(context);
      return;
    });

    try {
      googleResult = await google.signIn();

      if(timer.isActive){
        timer.cancel();
      }
    }
    catch(e){
      AppLoading.instance.hideLoading(context);
      AppSheet.showSheet$OperationFailed(context);
      return;
    }

    if(googleResult == null){
      AppLoading.instance.hideLoading(context);
      AppSheet.showSheet$OperationFailed(context);
    }
    else {
      final twoState = await LoginService.requestVerifyGmail(email: googleResult.email);
      AppLoading.instance.cancel(context);

      if(twoState.hasResult1()){
        final status = twoState.result1![Keys.status];
        final causeCode = twoState.result1![Keys.causeCode]?? 0;

        if(status == Keys.error){
          if(causeCode == HttpCodes.error_dataNotExist){
            /**/
          }
          else if(causeCode == HttpCodes.error_userIsBlocked){
            AppSheet.showSheet$AccountIsBlock(context);
            return;
          }
        }
        else {
          final userId = twoState.result1![Keys.userId];

          if (userId == null) {
            final injectData = RegisterPageInjectData();
            injectData.email = googleResult.email;

            RouteTools.pushPage(context, RegisterPage(injectData: injectData));
          }
          else {
            final userModel = await SessionService.login$newProfileData(twoState.result1!);

            if(userModel != null) {
              //RouteTools.pushPage(context, LayoutPage(key: AppBroadcast.layoutPageKey));
              AppBroadcast.reBuildMaterial();
            }
            else {
              AppSheet.showSheet$OperationFailed(context);
            }
          }
        }
      }
      else {
        AppSheet.showSheet$ErrorCommunicatingServer(context);
        return;
      }
    }
  }

  bool canShowEnterWithMobile() {
    return !isWeb || isIran;
  }

  void onEnterWithEmailClick() {
    pageCtr.changePageTo(1);
  }

  void onEnterWithMobileForWebClick() {
    pageCtr.changePageTo(3);
  }

  void onEnterToRegisterEmailForWebClick() {
    pageCtr.changePageTo(2);
  }
}
