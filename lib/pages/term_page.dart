import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/system/session.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/notFetchData.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

class TermPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/term',
    name: (TermPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => TermPage(),
  );

  const TermPage({Key? key}) : super(key: key);

  @override
  State<TermPage> createState() => _TermPageState();
}
///==================================================================================
class _TermPageState extends StateBase<TermPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String? htmlData;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    requestTerm();
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
              title: Text(AppMessages.termTitle),
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
      child: SingleChildScrollView(
        child: Html(
          data: htmlData,
        ),
      ),
    );
  }

  void tryLoadClick() async {
    isInFetchData = true;
    assistCtr.updateMain();

    requestTerm();
  }

  void requestTerm() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_term_data';
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
}
