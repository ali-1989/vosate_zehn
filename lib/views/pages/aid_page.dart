import 'package:app/system/build_flavor.dart';
import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/error_occur.dart';
import 'package:app/views/states/wait_to_load.dart';

/// zone: to catch all unhandled-asynchronous-errors
/// FlutterError.onError: to catch all unhandled-flutter-framework-errors

class AidPage extends StatefulWidget{

  const AidPage({super.key});

  @override
  State<AidPage> createState() => _AidPageState();
}
///=============================================================================
class _AidPageState extends StateSuper<AidPage> {
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
      isHead: true,
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
      return const WaitToLoad();
    }

    if(!assistCtr.hasState(state$fetchData)){
      return ErrorOccur(onTryAgain: tryLoadClick);
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

          const SizedBox(height: 100,),

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

          const SizedBox(height: 15),

          /// for bazar: hidden paypal
          Visibility(
            visible: !BuildFlavor.isForBazar(),
              child: MaxWidth(
                maxWidth: 300,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //minimumSize: Size(180, 46),
                        backgroundColor: AppThemes.instance.currentTheme.successColor,
                      ),
                      onPressed: onPayPalCall,
                      child: Text(AppMessages.payWitPaypal, textDirection: TextDirection.ltr)
                  ),
                ),
              ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void tryLoadClick() async {
    isInFetchData = true;
    assistCtr.updateHead();

    requestAidData();
  }

  void requestAidData() async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'get_aid_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdateHead(state$fetchData);
      return true;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;
      htmlData = data[Keys.data]?? '_';
      assistCtr.addStateAndUpdateHead(state$fetchData);
    };

    requester.prepareUrl();
    requester.request();
  }

  void onPayIranCall() async {
    //RouteTools.pushNamed(context, PayWebPage.route.name!, extra: 'https://zarinp.al/vosatezehn.ir');
    UrlHelper.launchLink('https://zarinp.al/vosatezehn.ir', mode: LaunchMode.externalApplication);
  }

  void onPayPalCall() async {
    //RouteTools.pushNamed(context, PayWebPage.route.name!, extra: 'https://www.paypal.com/donate/?hosted_button_id=K75F6ZADA3YCW');
    UrlHelper.launchLink('https://www.paypal.com/donate/?hosted_button_id=K75F6ZADA3YCW', mode: LaunchMode.externalApplication);
  }
}
