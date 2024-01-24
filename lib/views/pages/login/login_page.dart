
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/find_country_ip.dart';
import 'package:app/views/pages/login/login_email_part.dart';
import 'package:app/views/pages/login/login_mobile_part.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/widgets/page_switcher.dart';

import 'package:app/services/login_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
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
  String countryIso = WidgetsBinding.instance.platformDispatcher.locale.countryCode?? 'IR';
  late bool isIran;
  Color selectedTabColor = AppDecoration.differentColor;
  int selectedTabIndex = 0;


  @override
  void initState(){
    super.initState();

    isIran = countryIso == 'IR';

    FindCountryIp.findCountryWithIP().then((value) {
      countryIso = value;
      isIran = countryIso == 'IR';
      callState();
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MathHelper.percent(hs, 25),
            child: Center(
              child: Image.asset(AppImages.appIcon, width: 100, height: 100),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              children: [
                /// email / mobile
                Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                  children: [
                    /// email / mobile tab
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                selectedTabIndex = 0;
                                pageCtr.changePageTo(0);
                                callState();
                              },
                              child: ColoredBox(
                                color: selectedTabIndex == 0? selectedTabColor : Colors.transparent,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text('ایمیل',
                                    style: TextStyle(color: selectedTabIndex == 0? Colors.white: Colors.blue)),
                                  ),
                                ),
                              ),
                            ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              selectedTabIndex = 1;
                              pageCtr.changePageTo(1);
                              callState();
                            },
                            child: ColoredBox(
                              color: selectedTabIndex == 1? selectedTabColor : Colors.transparent,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('موبایل',
                                      style: TextStyle(color: selectedTabIndex == 1? Colors.white: Colors.blue)
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      color: Colors.black12,
                    ),

                    /// email / mobile page
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: PageSwitcher(
                        controller: pageCtr,
                        pages: [
                          LoginEmailPart(),
                          LoginMobilePart(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

                const SizedBox(height: 20),

                /// guest user / terms
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

                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void gotoTermPage(){
    RouteTools.pushPage(context, const TermPage());
  }
}
