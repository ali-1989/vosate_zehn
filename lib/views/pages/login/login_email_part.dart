import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/widgets/page_switcher.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import 'package:app/services/google_sign_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/http_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/login/register_page.dart';
import 'package:app/views/sign_in/google_sign_button.dart';

class LoginEmailPart extends StatefulWidget{
  // ignore: prefer_const_constructors_in_immutables
  LoginEmailPart({super.key});

  @override
  State<LoginEmailPart> createState() => _LoginEmailPartState();
}
///=============================================================================
class _LoginEmailPartState extends StateSuper<LoginEmailPart> {
  TextEditingController emailCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();
  PageSwitcherController pageCtr = PageSwitcherController();


  @override
  void initState(){
    super.initState();

    if(kIsWeb){
      GoogleSignService().addListener(onGoogleSignInWeb);
      GoogleSignService().signInSilently();
    }
  }

  @override
  void dispose(){
    emailCtr.dispose();
    passwordCtr.dispose();
    GoogleSignService().removeListener(onGoogleSignInWeb);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody(){
    return PageSwitcher(
      controller: pageCtr,
      pages: [
        buildFirstPage(),
        buildRegisterEmail(),
      ],
    );
  }

  Widget buildFirstPage() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(AppMessages.pleaseEnterEmailToSendVerifyEmail,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),

        const SizedBox(height: 20),
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

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              onPressed: loginWithEmail,
              child: Text(AppMessages.loginBtn)
          ),
        ),

        Row(
          children: [
            Expanded(
              child: Builder(
                  builder: (_){
                    if(kIsWeb){
                      return FittedBox(
                        child: buildSignInButton(onPressed: onSignWithGoogleClick),
                      );
                    }

                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppDecoration.secondColor
                      ),
                      onPressed: onSignWithGoogleClick,
                      icon: Image.asset(AppImages.googleIco, height: 18* iconR),
                      label: const Text(''),
                    );
                  }
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDecoration.secondColor
                ),
                onPressed: (){pageCtr.next();},
                child: Text(AppMessages.register),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildRegisterEmail() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(AppMessages.pleaseEnterEmailToRegistering,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),

        const SizedBox(height: 10),
        TextField(
          controller: emailCtr,
          decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
            hintText: 'ایمیل',
          ),
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
        ),

        const SizedBox(height: 16),
        Align(
            alignment: Alignment.topRight,
            child: Text(AppMessages.pleaseEnterAPassword, style: const TextStyle(fontWeight: FontWeight.bold))),

        const SizedBox(height: 6),

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

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              onPressed: onRegisterEmailClick,
              child: Text(AppMessages.register)
          ),
        ),
        const SizedBox(height: 5),
        UnconstrainedBox(
          child: TextButton(
              onPressed: (){
                pageCtr.changePageTo(0);
              },
              child: Text(AppMessages.loginBtn)
          ),
        ),

        const SizedBox(height: 5),
      ],
    );
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
      AppSheet.showSheetOk(context, AppMessages.operationFailedTryAgain);
      return;
    }

    if(state == EmailVerifyStatus.mustLogin) {
      pageCtr.changePageTo(0);
      AppSheet.showSheetOk(context, 'این ایمیل وجود دارد، لطفا وارد شوید');
    }
    else if(state == EmailVerifyStatus.mustRegister){
      final injectData = RegisterPageInjectData();
      injectData.email = email;

      RouteTools.pushPage(context, RegisterPage(injectData: injectData), name: 'register-Page'.toLowerCase());
    }
    else if(state == EmailVerifyStatus.waitToVerify){
      AppSheet.showSheetOk(context, 'ایمیلی جهت فعال ساری برای شما ارسال شد، لطفا روی لینک فعال سازی کلیک کنید.');
      pageCtr.changePageTo(0);
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
      AppSheet.showSheetOk(context, AppMessages.operationFailedTryAgain);
    }
    else if(status == EmailLoginStatus.inCorrectUserPass) {
      AppSheet.showSheetOk(context, 'ایمیل یا رمز اشتباه است');
    }
    else if(status == EmailLoginStatus.mustRegister){
      final injectData = RegisterPageInjectData();
      injectData.email = email;

      RouteTools.pushPage(context, RegisterPage(injectData: injectData), name: 'register-Page'.toLowerCase());
    }
    else if(status == EmailLoginStatus.waitToVerify){
      AppSheet.showSheetOk(context, 'ایمیلی جهت فعال ساری برای شما ارسال شد، لطفا روی لینک فعال سازی کلیک کنید.');
    }
  }

  void onGoogleSignInWeb(GoogleSignInAccount? signInAccount) {
    if(signInAccount == null){
      return;
    }

    showLoading();
    requestSignWithGoogle(signInAccount.email);
  }

  Future<void> onSignWithGoogleClick() async {
    showLoading();

    final google = GoogleSignService();
    (GoogleSignInAccount?, Object?) googleResult = await google.signIn();

    if(googleResult.$1 == null){
      await hideLoading();
      AppSheet.showSheetOk(context, AppMessages.operationFailed);
      return;
    }

    requestSignWithGoogle(googleResult.$1!.email);
  }

  Future<void> requestSignWithGoogle(String email) async {
    //final reLaunch = await LoginService.loginWithAuthEmail(email: res.$1!.email);
    final twoState = await LoginService.requestVerifyGmail(email: email);
    await hideLoading();

    if(twoState.hasResult1()){
      final status = twoState.result1![Keys.status];
      final causeCode = twoState.result1![Keys.causeCode]?? 0;

      if(status == Keys.error){
        if(causeCode == HttpCodes.cCode$UserIsBlocked){
          AppSheet.showSheetOk(context, AppMessages.accountIsBlock);
        }
        else {
          AppSheet.showSheetOk(context, AppMessages.errorOccurTryAgain);
        }
      }
      else {
        GoogleSignService().getCredentialInfo();
        final userId = twoState.result1![Keys.userId];

        if (userId == null) {
          final injectData = RegisterPageInjectData();
          injectData.email = email;

          RouteTools.pushPage(context, RegisterPage(injectData: injectData), name: 'register-Page'.toLowerCase());
        }
        else {
          final userModel = await SessionService.loginByProfileData(twoState.result1!);

          if(userModel != null) {
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
    }
  }
}
