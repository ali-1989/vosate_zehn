import 'dart:async';

import 'package:app/views/pages/login/login_email_part.dart';
import 'package:app/views/pages/login/login_mobile_part.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/page_switcher.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:app/services/google_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/models/country_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_loading.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/country_tools.dart';
import 'package:app/tools/http_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/components/countrySelect.dart';
import 'package:app/views/components/phoneNumberInput.dart';
import 'package:app/views/pages/login/register_page.dart';
import 'package:app/views/pages/term_page.dart';

class LoginPage extends StatefulWidget{
  // ignore: prefer_const_constructors_in_immutables
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
///=============================================================================
class _LoginPageState extends StateSuper<LoginPage> {
  PageSwitcherController pageCtr = PageSwitcherController();
  CountryModel countryModel = CountryModel();
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

    CountryTools.fetchCountries().then((value) {
      countryModel = CountryTools.countryModelByCountryIso('IR');
      assistCtr.updateHead();
    });
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.instance.currentTheme.primaryColor,
      body: SafeArea(
          child: buildBody()
      ),
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        SizedBox(
          height: MathHelper.percent(hs, 25),
          child: Center(
            child: Image.asset(AppImages.appIcon, width: 100, height: 100),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Align(
                child: Column(
                  children: [
                    Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: PageSwitcher(
                        controller: pageCtr,
                        pages: [
                          LoginEmailPart(),
                          LoginMobilePart(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                ),
                                  onPressed: (){
                                    LoginService.loginGuestUser(context);
                                  },
                                  child: const Text('ورود مهمان')
                              ),
                            ),

                            const SizedBox(height: 5),
                            TextButton(
                                onPressed: gotoTermPage,
                                child: Text(AppMessages.termPolice).fsR(-2)
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
            ),
          ),
        ),
      ],
    );
  }

  void gotoTermPage(){
    RouteTools.pushPage(context, const TermPage());
  }


}
