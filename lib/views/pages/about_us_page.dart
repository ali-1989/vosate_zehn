import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/error_occur.dart';
import 'package:app/views/states/wait_to_load.dart';

class AboutUsPage extends StatefulWidget{

  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}
///=================================================================================================
class _AboutUsPageState extends StateSuper<AboutUsPage> {
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
      isHead: true,
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
      },
    );
  }

  Widget buildBody(){
    if(isInFetchData) {
      return WaitToLoad();
    }

    if(!assistCtr.hasState(state$fetchData)){
      return ErrorOccur(onTryAgain: tryLoadClick);
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
    assistCtr.updateHead();

    requestAboutUs();
  }

  void requestAboutUs() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_about_us_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdateHead(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;
      htmlData = data[Keys.data];
      assistCtr.addStateAndUpdateHead(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }
}
