import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/widgets/page_switcher.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/models/country_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/country_tools.dart';
import 'package:app/tools/http_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/components/countrySelect.dart';
import 'package:app/views/components/phoneNumberInput.dart';
import 'package:app/views/pages/login/register_page.dart';

class LoginMobilePart extends StatefulWidget{
  // ignore: prefer_const_constructors_in_immutables
  LoginMobilePart({super.key});

  @override
  State<LoginMobilePart> createState() => _LoginMobilePartState();
}
///=============================================================================
class _LoginMobilePartState extends StateSuper<LoginMobilePart> {
  TextEditingController pinCodeCtr = TextEditingController();
  PageSwitcherController pageCtr = PageSwitcherController();
  late final StopWatchTimer stopWatchTimer;
  CountryModel countryModel = CountryModel();
  late PhoneNumberInputController phoneNumberController;
  String phoneNumber = '';
  String pinCode = '';
  int timerValueSec = 60;
  bool showResendOtpButton = false;
  String countryIso = WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? 'IR';


  @override
  void initState() {
    super.initState();

    phoneNumberController = PhoneNumberInputController();
    phoneNumberController.setOnTapCountryArrow(onTapCountryArrow);

    CountryTools.fetchCountries().then((value) {
      countryModel = CountryTools.countryModelByCountryIso('IR');
      callState();
    });

    stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      isLapHours: false,
      presetMillisecond: timerValueSec * 1000,
      onEnded: () {
        showResendOtpButton = true;
        assistCtr.updateHead();
      },
    );
  }

  @override
  void dispose() {
    stopWatchTimer.dispose();
    pinCodeCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    return PageSwitcher(
      controller: pageCtr,
      pages: [
        buildFirstPage(),
        buildPinCodePage(),
      ],
    );
  }

  Widget buildFirstPage() {
    return Column(
      children: [
        const SizedBox(height: 20),

        Text(AppMessages.pleaseEnterMobileToSendCode,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        PhoneNumberInput(
          controller: phoneNumberController,
          countryCode: countryIso == 'IR' ? countryModel.countryPhoneCode : '',
          numberHint: AppMessages.mobileNumber,
          showCountrySection: countryIso == 'IR',
        ),

        const SizedBox(height: 20),

        /// send number Btn
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              onPressed: onSendNumberClick,
              child: Text(AppMessages.send)
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }

  Widget buildPinCodePage() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Text(AppMessages.enterVerifyCodeDesc.replaceFirst('#',
            LocaleHelper.overrideLtr(
                '${countryModel.countryPhoneCode} $phoneNumber')),
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
            onCompleted: (v) {},
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
                child: Text(AppMessages.otherNumber)
            ),

            Row(
              children: [
                Visibility(
                    visible: showResendOtpButton,
                    child: TextButton(
                        onPressed: resetTimer,
                        child: Text(AppMessages.resendOtpCode,
                            style: const TextStyle(color: Colors.red))
                    )
                ),

                Visibility(
                  visible: !showResendOtpButton,
                  child: StreamBuilder<int>(
                    stream: stopWatchTimer.rawTime,
                    initialData: 0,
                    builder: (context, snap) {
                      final value = snap.data;
                      final displayTime = StopWatchTimer.getDisplayTime(
                          value!, hours: false,
                          milliSecond: false,
                          minute: false);
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

        const SizedBox(height: 10),
      ],
    );
  }

  void onChangeNumberCall() async {
    pinCode = '';
    pageCtr.changePageTo(0);
  }

  void resetTimer() {
    stopWatchTimer.setPresetTime(mSec: timerValueSec);
    stopWatchTimer.onResetTimer();
    stopWatchTimer.onStartTimer();

    reSendOtpCodeCall();

    showResendOtpButton = false;
    pinCodeCtr.clear();

    assistCtr.updateHead();
  }

  void onTapCountryArrow() async {
    final value = await RouteTools.pushPage(
        context, const CountrySelectScreen(), name: 'CountrySelect-Page'.toLowerCase());

    if (value is CountryModel) {
      countryModel = value;
      phoneNumberController
          .getCountryController()
          ?.text = countryModel.countryPhoneCode!;
    }
  }

  void onSendNumberClick() {
    prepareSendOtp();
  }

  void prepareSendOtp() {
    //countryModel.countryPhoneCode = phoneNumberController.getCountryCode()!;
    phoneNumber = phoneNumberController.getPhoneNumber()!;

    /*if(countryModel.countryPhoneCode!.isEmpty){
      AppSnack.showInfo(context, AppMessages.enterCountryCode);
      return;
    }*/

    if (phoneNumber.isEmpty) {
      AppSnack.showInfo(context, AppMessages.enterPhoneNumber);
      return;
    }

    if (!countryModel.countryPhoneCode!.startsWith('+')) {
      countryModel.countryPhoneCode = '+${countryModel.countryPhoneCode}';
    }

    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    if (phoneNumber.startsWith('+')) {
      AppSnack.showInfo(context, AppMessages.notCorrectMobileInfo);
      return;
    }

    showResendOtpButton = false;
    stopWatchTimer.onResetTimer();
    stopWatchTimer.onStartTimer();

    callState();

    LoginService.requestSendOtp(countryModel: countryModel, phoneNumber: phoneNumber)
        .then((value) {
      if (value == null) {
        AppToast.showToast(context, AppMessages.errorCommunicatingServer);
      }
    });

    pinCodeCtr.text = '';
    pageCtr.changePageTo(1);
  }

  void reSendOtpCodeCall() async {
    LoginService.requestSendOtp(countryModel: countryModel, phoneNumber: phoneNumber);
    AppToast.showToast(context, AppMessages.otpCodeIsResend);
  }

  void onValidationCall() async {
    if (pinCode.length != 4) {
      AppSheet.showSheetOk(context, AppMessages.pleaseEnterVerifyCode);
      return;
    }

    final twoState = await LoginService.requestVerifyOtp(
        countryModel: countryModel, phoneNumber: phoneNumber, code: pinCode);

    if (twoState.hasResult1()) {
      final status = twoState.result1![Keys.status];

      if (status == Keys.error) {
        final causeCode = twoState.result1![Keys.causeCode] ?? 0;

        if (causeCode == HttpCodes.cCode$UserIsBlocked) {
          AppSheet.showSheetOk(context, AppMessages.accountIsBlock);
          return;
        }
      }
      else {
        final userId = twoState.result1![Keys.userId];

        if (userId == null) {
          final injectData = RegisterPageInjectData();
          injectData.countryModel = countryModel;
          injectData.mobileNumber = phoneNumber;

          RouteTools.pushPage(context, RegisterPage(injectData: injectData), name: 'Register-Page'.toLowerCase());
        }
        else {
          final userModel = await SessionService.loginByProfileData(
              twoState.result1!);

          if (userModel != null) {
            //RouteTools.pushPage(context, LayoutPage(key: AppBroadcast.layoutPageKey));
            AppBroadcast.reBuildApp();
          }
          else {
            AppSheet.showSheetOk(context, AppMessages.operationFailed);
          }
        }
      }
    }
    else {
      AppSheet.showSheetOk(context, AppMessages.errorCommunicatingServer);
      return;
    }
  }
}
