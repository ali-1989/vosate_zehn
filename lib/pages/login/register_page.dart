import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:vosate_zehn/pages/termPage.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appNavigator.dart';
import 'package:vosate_zehn/tools/app/appSheet.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';
import 'package:vosate_zehn/views/genAppBar.dart';

class RegisterPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/register',
    name: (RegisterPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => const RegisterPage(),
  );

  final String? email;
  final String? countryCode;
  final String? mobileNumber;

  const RegisterPage({
  super.key,
  this.email,
  this.countryCode,
  this.mobileNumber,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
///=================================================================================================
class _RegisterPageState extends StateBase<RegisterPage> {
  late TextEditingController nameCtr;
  late TextEditingController familyCtr;


  @override
  void initState(){
    super.initState();

    nameCtr = TextEditingController();
    familyCtr = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();

    nameCtr.dispose();
    familyCtr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          appBar: GenAppBar(
            title: Text(AppMessages.registerTitle),
          ),
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
            child: Center(),
            ),
        ),
      ],
    );
  }

  void gotoTermPage(){
    AppNavigator.pushNextPage(
        context,
        const TermPage(),
        name: 'TermPage');
  }

  void onValidationCall() async {


    final result = true;

    if(result == null){
      AppSheet.showSheet$ErrorCommunicatingServer(context);
      return;
    }

    if(result){

    }
    else {
      AppSheet.showSheetOk(context, AppMessages.otpCodeIsInvalid);
    }
  }
}
