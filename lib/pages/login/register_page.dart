import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/countryModel.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/dateViews/selectDateCalendarView.dart';

class RegisterPageInjectData {
  String? email;
  CountryModel? countryModel;
  String? mobileNumber;
}
///=================================================================================
class RegisterPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/register',
    name: (RegisterPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => RegisterPage(injectData: state.extra! as RegisterPageInjectData,),
  );

  final RegisterPageInjectData injectData;

  const RegisterPage({
  super.key,
  required this.injectData,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
///=================================================================================================
class _RegisterPageState extends StateBase<RegisterPage> {
  late TextEditingController nameCtr;
  late TextEditingController familyCtr;
  DateTime? birthDate;
  late Requester requester;
  late InputDecoration inputDecor;
  int gender = 1;

  @override
  void initState(){
    super.initState();

    nameCtr = TextEditingController();
    familyCtr = TextEditingController();
    requester = Requester();

    inputDecor = InputDecoration(
      isDense: true,
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
    );
  }

  @override
  void dispose(){
    super.dispose();

    requester.dispose();
    nameCtr.dispose();
    familyCtr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          appBar: AppBarCustom(
            title: Text(AppMessages.registerTitle),
          ),
          //backgroundColor: AppThemes.instance.currentTheme.primaryColor,
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            children: [
              SizedBox(
                height: MathHelper.percent(MediaQuery.of(context).size.height, 30),
                child: Center(
                  child: Image.asset(AppImages.appIcon, width: 100, height: 100,),
                ),
              ),
              //Text('${AppMessages.name}:'),

              TextField(
                controller: nameCtr,
                textInputAction: TextInputAction.next,
                decoration: inputDecor.copyWith(
                  hintText: AppMessages.name,
                  label: Text(AppMessages.name),
                ),
              ),

              SizedBox(height: 20),

              TextField(
                controller: familyCtr,
                decoration: inputDecor.copyWith(
                  hintText: AppMessages.family,
                  alignLabelWithHint: true,
                  label: Text(AppMessages.family),
                ),
              ),

              SizedBox(height: 20),
              Text('${AppMessages.gender}:'),

              SizedBox(height: 10),
              Row(
                children: [
                  ToggleSwitch(
                    initialLabelIndex: gender-1,
                    totalSwitches: 2,
                    animate: true,
                    textDirectionRTL: true,
                    animationDuration: 400,
                    labels: [AppMessages.man, AppMessages.woman],
                    onToggle: (index) {
                      if(index != null){
                        gender = index+1;
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: 10),
              Row(
                children: [
                  Text('${AppMessages.age}:'),

                  SizedBox(width: 15),
                  TextButton(
                    onPressed: (){
                      onSelectDateCall();
                    },
                    child: Text(genBirthDateText()),
                  ),
                ],
              ),

              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: onRegisterCall,
                  child: Text(AppMessages.registerTitle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onRegisterCall() async {
    final name = nameCtr.text.trim();
    final family = familyCtr.text.trim();

    if(name.isEmpty || family.isEmpty){
      AppSheet.showSheetOk(context, AppMessages.pleaseEnterNameFamily);
      return;
    }

    if(birthDate == null){
      AppSheet.showSheetOk(context, AppMessages.pleaseSelectAge);
      return;
    }

    requestRegister();
  }

  String genBirthDateText() {
    if(birthDate == null){
      return AppMessages.select;
    }

    return '${DateHelper.calculateAge(birthDate)}';
  }

  void onSelectDateCall() {
    AppSheet.showModalBottomSheet$(
        context,
        builder: (context){
          return SelectDateCalendarView(
            onSelect: (dt){
              birthDate = dt;
              assistCtr.updateMain();
              AppSheet.closeSheet(context);
            },
            //title: 'تاریخ تولد',
            onChange: (dt){
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal:10.0),
                child: Text('${AppMessages.age}: ${DateHelper.calculateAge(dt)}',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              );
            },
            currentDate: birthDate,
            minYearAsGregorian: 1922,
            maxYearAsGregorian: GregorianDate().getYear(),
          );
        }
    );
  }

  void requestRegister(){
    final name = nameCtr.text.trim();
    final family = familyCtr.text.trim();

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'register_user';
    js[Keys.name] = name;
    js[Keys.family] = family;
    js[Keys.birthdate] = DateHelper.toTimestampDate(birthDate!);
    js[Keys.sex] = gender;

    if(widget.injectData.countryModel != null) {
      js[Keys.mobileNumber] = widget.injectData.mobileNumber;
      js.addAll(widget.injectData.countryModel!.toMap());
    }
    else {
      js['email'] = widget.injectData.email;
    }

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final userModel = await Session.login$newProfileData(data);

      if(userModel != null) {
        AppRoute.pop(context);
        AppRoute.replaceNamed(context, LayoutPage.route.name!);
      }
      else {
        AppSheet.showSheet$OperationFailed(context);
      }
    };

    showLoading();
    requester.request(context);
  }
}
