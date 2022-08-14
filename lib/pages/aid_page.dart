import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:vosate_zehn/pages/zarinpal_page.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/notFetchData.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

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
      return WaitToLoad();
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
                  primary: AppThemes.instance.currentTheme.successColor,
                ),
                  onPressed: onPayCall,
                  child: Text(AppMessages.pay)
              ),
            ),
          ),

          SizedBox(height: 10,),
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

    requester.httpRequestEvents.onFailState = (req) async {
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

  void onPayCall() async {
    AppRoute.pushNamed(context, ZarinpalPage.route.name!);
  }
}
