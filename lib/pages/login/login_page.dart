import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:vosate_zehn/models/countryModel.dart';
import 'package:vosate_zehn/services/google.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appNavigator.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appSheet.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';
import 'package:vosate_zehn/views/genAppBar.dart';
import 'package:vosate_zehn/views/phoneNumberInput.dart';
import 'package:vosate_zehn/views/screens/countrySelect.dart';

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
  late PhoneNumberInputController phoneNumberController;


  @override
  void initState(){
    super.initState();

    phoneNumberController = PhoneNumberInputController();
    phoneNumberController.setOnTapCountryArrow(onTapCountryArrow);
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
          child: DecoratedBox(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  PhoneNumberInput(
                      controller: phoneNumberController,
                    countryCode: '+98',
                  ),

                  const SizedBox(height: 30,),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                          primary: AppThemes.instance.currentTheme.differentColor,
                        ),
                        onPressed: (){
                          signWithGoogleCall();
                        },
                        icon: Image.asset(AppImages.googleIco, width: 20, height: 20,),
                        label: Text(AppMessages.loginWithGoogle)
                    ),
                  ),

                  const SizedBox(height: 30,),

                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                        onPressed: (){},
                        child: Text(AppMessages.send)
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void signWithGoogleCall() async {
    final google = Google();
    final result = await google.signIn();

    if(result == null){
      AppSheet.showSheet$OperationFailed(context);
      return;
    }
  }

  void onTapCountryArrow(){
    print('click');
    AppNavigator.pushNextPage(
        context,
        const CountrySelectScreen(),
        name: 'CountrySelect').then((value) {
          if(value is CountryModel){
            phoneNumberController.getCountryController()?.text = '${value.countryPhoneCode}';
          }
    });
  }
}
