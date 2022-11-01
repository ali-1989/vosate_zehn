import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/pages/pay_web_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/notFetchData.dart';
import 'package:app/views/progressView.dart';

class AidPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/aid',
    name: (AidPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => AidPage(),
  );

  const AidPage({Key? key}) : super(key: key);

  @override
  State<AidPage> createState() => _AidPageState();
}
///==================================================================================
class _AidPageState extends StateBase<AidPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String? htmlData;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    requestAidData();
  }

  @override
  void dispose(){
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (context, ctr, data) {
          return Scaffold(
            appBar: AppBarCustom(
              title: Text(AppMessages.aidUs),
            ),
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    if(isInFetchData) {
      return ProgressView();
    }

    if(!assistCtr.hasState(state$fetchData)){
      return NotFetchData(tryClick: tryLoadClick,);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Html(
                data: htmlData,
              ),
            ),
          ),

          SizedBox(height: 100,),

          MaxWidth(
            maxWidth: 300,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    //minimumSize: Size(180, 46),
                  backgroundColor: AppThemes.instance.currentTheme.successColor,
                ),
                  onPressed: onPayIranCall,
                  child: Text(AppMessages.payWitIran)
              ),
            ),
          ),

          SizedBox(height: 15),

          MaxWidth(
            maxWidth: 300,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    //minimumSize: Size(180, 46),
                    backgroundColor: AppThemes.instance.currentTheme.successColor,
                  ),
                  onPressed: onPayPalCall,
                  child: Text(AppMessages.payWitPaypal)
              ),
            ),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }

  void tryLoadClick() async {
    isInFetchData = true;
    assistCtr.updateMain();

    requestAidData();
  }

  void requestAidData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_aid_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;
      htmlData = data[Keys.data]?? '_';
      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }

  void onPayIranCall() async {
    AppRoute.pushNamed(context, PayWebPage.route.name!, extra: 'https://zarinp.al/vosatezehn.ir');
  }

  void onPayPalCall() async {
    AppRoute.pushNamed(context, PayWebPage.route.name!, extra: 'https://www.paypal.com/donate/?hosted_button_id=K75F6ZADA3YCW');
  }
}
