import 'package:flutter/material.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'dart:async';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/countryModel.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/pages/login/register_page.dart';
import 'package:app/pages/term_page.dart';
import 'package:app/services/google_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appLoading.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/countryTools.dart';
import 'package:app/views/phoneNumberInput.dart';
import 'package:app/views/screens/countrySelect.dart';

class LoginPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/login',
    name: (LoginPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => const LoginPage(),
  );

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
///=================================================================================================
class _LoginPageState extends StateBase<LoginPage> {
  TextEditingController pinCodeCtr = TextEditingController();
  late PhoneNumberInputController phoneNumberController;
  late FlipCardController flipCardController;
  late final StopWatchTimer stopWatchTimer;
  //ValueKey pinCodeKey = const ValueKey('1');
  CountryModel countryModel = CountryModel();
  String phoneNumber = '';
  String pinCode = '';
  int timerValueSec = 60;
  bool showResendOtpButton = false;


  @override
  void initState(){
    super.initState();

    flipCardController = FlipCardController();
    phoneNumberController = PhoneNumberInputController();
    phoneNumberController.setOnTapCountryArrow(onTapCountryArrow);

    CountryTools.fetchCountries().then((value) {
      countryModel = CountryTools.countryModelByCountryIso('IR');
      assistCtr.updateMain();
    });

    stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      isLapHours: false,
      presetMillisecond: timerValueSec*1000,
      onEnded: (){
        showResendOtpButton = true;
        assistCtr.updateMain();
      },
    );
  }

  @override
  void dispose(){
    stopWatchTimer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          /*appBar: GenAppBar(
            title: Text(AppMessages.loginTitle),
          ),*/
          backgroundColor: AppThemes.instance.currentTheme.primaryColor,
          body: SafeArea(
              child: buildBody()
          ),
        );
      }
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        SizedBox(
          height: MathHelper.percent(MediaQuery.of(context).size.height, 30),
          child: Center(
            child: Image.asset(AppImages.appIcon, width: 100, height: 100,),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Align(
              child: FlipCard(
                controller: flipCardController,
                fill: Fill.fillBack,
                flipOnTouch: false,
                front: buildFrontFlip(),
                back: buildBackFlip(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFrontFlip() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 30),
          Text(AppMessages.pleaseEnterMobileToSendCode,
            style: const TextStyle(fontWeight: FontWeight.bold),),

          const SizedBox(height: 30),

          PhoneNumberInput(
            controller: phoneNumberController,
            countryCode: countryModel.countryPhoneCode,
            numberHint: AppMessages.mobileNumber,
          ),

          const SizedBox(height: 30,),
          TextButton(
              onPressed: gotoTermPage,
              child: Text(AppMessages.terms)
          ),

          const SizedBox(height: 12,),

          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                onPressed: onSendCall,
                child: Text(AppMessages.send)
            ),
          ),

          const SizedBox(height: 10),
          UnconstrainedBox(
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: AppThemes.instance.currentTheme.differentColor,
                ),
                onPressed: (){
                  signWithGoogleCall();
                },
                icon: Image.asset(AppImages.googleIco, width: 20, height: 20,),
                label: Text(AppMessages.loginWithGoogle)
            ),
          ),

          const SizedBox(height: 32,),
        ],
      ),
    );
  }

  Widget buildBackFlip(){
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 30),
          Text(AppMessages.enterVerifyCode.replaceFirst('#', LocaleHelper.embedLtr('${countryModel.countryPhoneCode} $phoneNumber')),
            style: const TextStyle(fontWeight: FontWeight.bold),),

          const SizedBox(height: 10,),

          Directionality(
            textDirection: TextDirection.ltr,
            child: PinCodeTextField(
              controller: pinCodeCtr,
              //key: pinCodeKey,
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
                          child: Text(AppMessages.resendOtpCode, style: TextStyle(color: Colors.red))
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
    );
  }

  void signWithGoogleCall() async {
    final google = GoogleService();

    AppLoading.instance.showWaiting(context);
    GoogleSignInAccount? googleResult;

    final t = Timer(Duration(seconds: 60), (){
      AppLoading.instance.hideLoading(context);
      AppSheet.showSheet$OperationFailed(context);
      return;
    });

    try {
      googleResult = await google.signIn();

      if(t.isActive){
        t.cancel();
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
      final injectData = RegisterPageInjectData();
      injectData.email = googleResult.email;

      final result = await LoginService.requestVerifyEmail(email: googleResult.email);
      AppLoading.instance.cancel(context);

      if(result.connectionError){
        AppSheet.showSheet$ErrorCommunicatingServer(context);
        return;
      }

      if(result.isBlock){
        AppSheet.showSheet$AccountIsBlock(context);
        return;
      }

      if(result.isVerify) {
        final userId = result.jsResult![Keys.userId];

        if (userId == null) {
          AppRoute.push(context, RegisterPage.route.path, extra: injectData);
        }
        else {
          final userModel = await Session.login$newProfileData(result.jsResult!);

          if(userModel != null) {
            AppRoute.push(context, LayoutPage.route.path);
          }
          else {
            AppSheet.showSheet$OperationFailed(context);
          }
        }
      }
    }
  }

  void onChangeNumberCall() async {
    pinCode = '';
    flipCardController.toggleCard();
  }

  void resetTimer(){
    stopWatchTimer.setPresetTime(mSec: timerValueSec);
    stopWatchTimer.onResetTimer();
    stopWatchTimer.onStartTimer();

    reSendOtpCodeCall();

    showResendOtpButton = false;
    pinCodeCtr.clear();

    assistCtr.updateMain();
  }

  void onTapCountryArrow(){
    AppNavigator.pushNextPage(
        context,
        const CountrySelectScreen(),
        name: 'CountrySelect').then((value) {
          if(value is CountryModel){
            countryModel = value;
            phoneNumberController.getCountryController()?.text = countryModel.countryPhoneCode!;
          }
    });
  }

  void gotoTermPage(){
    AppRoute.pushNamed(context, TermPage.route.name!);
    /*AppNavigator.pushNextPage(
        context,
        const TermPage(),
        name: 'TermPage');*/
  }

  void onSendCall(){
    countryModel.countryPhoneCode = phoneNumberController.getCountryCode()!;
    phoneNumber = phoneNumberController.getPhoneNumber()!;

    if(countryModel.countryPhoneCode!.isEmpty){
      AppSnack.showInfo(context, AppMessages.enterCountryCode);
      return;
    }

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

    showResendOtpButton = false;
    stopWatchTimer.onResetTimer();
    stopWatchTimer.onStartTimer();

    //pinCodeKey = ValueKey(Generator.generateKey(2));
    callState();

    LoginService.requestSendOtp(countryModel: countryModel, phoneNumber: phoneNumber).then((value) {
      if(value == null){
        AppToast.showToast(context, AppMessages.errorCommunicatingServer);
      }
    });

    flipCardController.toggleCard();
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

    final result = await LoginService.requestVerifyOtp(countryModel: countryModel, phoneNumber: phoneNumber, code: pinCode);

    if(result.connectionError){
      AppSheet.showSheet$ErrorCommunicatingServer(context);
      return;
    }

    if(result.isBlock){
      AppSheet.showSheet$AccountIsBlock(context);
      return;
    }

    if(!result.isVerify){
      AppSheet.showSheetOk(context, AppMessages.otpCodeIsInvalid);
      return;
    }

    if(result.isVerify) {
      final userId = result.jsResult![Keys.userId];

      if (userId == null) {
        AppRoute.push(context, RegisterPage.route.path, extra: injectData);
      }
      else {
        final userModel = await Session.login$newProfileData(result.jsResult!);

        if(userModel != null) {
          AppRoute.replaceNamed(context, LayoutPage.route.name!);
        }
        else {
          AppSheet.showSheet$OperationFailed(context);
        }
      }
    }
  }
}
