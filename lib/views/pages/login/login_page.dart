import 'package:flutter/material.dart';

import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';
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
  late FlipCardController flipCardController;
  late final StopWatchTimer stopWatchTimer;
  CountryModel countryModel = CountryModel();
  String phoneNumber = '';
  String pinCode = '';
  int timerValueSec = 60;
  bool showResendOtpButton = false;
  bool mustLoginByMobileNumber = false;
  bool inRegisterEmailMode = false;
  String countryIso = WidgetsBinding.instance.platformDispatcher.locale.countryCode?? 'IR';
  late bool isIran;


  @override
  void initState(){
    super.initState();

    isIran = countryIso == 'IR';

    LoginService.findCountryWithIP().then((value) {
      countryIso = value;
      isIran = countryIso == 'IR';
      assistCtr.updateHead();
    });

    flipCardController = FlipCardController();
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
              child: Image.asset(AppImages.appIcon, width: 100, height: 100,),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Align(
                child: FlipCard(
                    rotateSide: RotateSide.bottom,
                    onTapFlipping: false,
                    axis: FlipAxis.horizontal,
                    controller: flipCardController,
                    frontWidget: buildFrontFlip(),
                    backWidget: buildBackFlip()
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFrontFlip() {
    if(inRegisterEmailMode){
      return buildFrontFlipForRegister();
    }

    if(mustLoginByMobileNumber && isIran){
      return buildFrontFlipWithMobile();
    }

    return buildFrontFlipWithEmail();
  }

  Widget buildFrontFlipWithMobile() {
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
              width: 200,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: onSendClick,
                  child: Text(AppMessages.loginBtn)
              ),
            ),
            /*SizedBox(
              width: double.maxFinite,
              child: ,
            ),*/

            const SizedBox(height: 10),
            UnconstrainedBox(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: AppThemes.instance.currentTheme.differentColor,
                  ),
                  onPressed: (){
                    signWithEmailClick();
                  },
                  child: const Text('ورود با ایمیل')
              ),
            ),

            TextButton(
              child: const Text('ورود مهمان'),
              onPressed: (){
                LoginService.loginGuestUser(context);
              },
            ),

            const SizedBox(height: 32,),
          ],
        ),
      ),
    );
  }

  Widget buildFrontFlipWithEmail() {
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
                  onPressed: onSendClick,
                  child: Text(AppMessages.loginBtn)
              ),
            ),
            /*SizedBox(
              width: double.maxFinite,
              child: ,
            ),*/

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

  Widget buildFrontFlipForRegister() {
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
              width: 200,
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
                    inRegisterEmailMode = false;
                    assistCtr.updateHead();
                  },
                  child: const Text('ورود')
              ),
            ),


            const SizedBox(height: 32,),
          ],
        ),
      ),
    );
  }

  Widget buildBackFlip(){
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

  void signWithEmailClick() {
    mustLoginByMobileNumber = false;
    assistCtr.updateHead();
  }

  void signWithMobileClick() {
    if(!isIran){
      AppToast.showToast(context, AppMessages.mustLiveInIran);
    }

    mustLoginByMobileNumber = true;
    assistCtr.updateHead();
  }

  void onChangeNumberCall() async {
    pinCode = '';
    flipCardController.flipcard();
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

  void onSendClick(){
    if(mustLoginByMobileNumber){
      prepareSendOtp();
    }
    else {
      loginWithEmail();
    }
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
    flipCardController.flipcard();
  }

  void loginWithEmail() async {
    final email = emailCtr.text.trim();
    final password = passwordCtr.text.trim();

    if(!Checker.isValidEmail(email)){
      AppSnack.showInfo(context, 'ایمیل وارد شده صحیح نیست');
      return;
    }

    if(password.length < 4 || password.length > 12){
      AppSnack.showInfo(context, 'طول روز عبور بین 4 تا 12 حرف می باشد');
      return;
    }

    showLoading();
    //await LoginService.requestCheckEmailAndSendVerify(email: email, password: password);
    hideLoading();
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
      AppSnack.showInfo(context, 'طول روز عبور بین 4 تا 12 حرف می باشد');
      return;
    }

    showLoading();
    await LoginService.requestCheckEmailAndSendVerify(email: email, password: password);
    hideLoading();
  }
}
