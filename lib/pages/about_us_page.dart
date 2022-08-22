import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/system/stateBase.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/notFetchData.dart';
import 'package:app/views/waitToLoad.dart';

class AboutUsPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/about_us',
    name: (AboutUsPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => const AboutUsPage(),
  );

  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}
///=================================================================================================
class _AboutUsPageState extends StateBase<AboutUsPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String? htmlData;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    requestAboutUs();
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
            title: Text(AppMessages.aboutUsTitle),
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

    requestAboutUs();
  }

  void requestAboutUs() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_about_us_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;
      htmlData = data[Keys.data];
      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }
}
