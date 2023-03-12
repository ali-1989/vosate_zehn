import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/homeComponents/appBarBuilder.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

/// zone: to catch all unhandled-asynchronous-errors
/// FlutterError.onError: to catch all unhandled-flutter-framework-errors

class AidPage extends StatefulWidget{

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
      return WaitToLoad();
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

          /// for bazar:comment
          /*MaxWidth(
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
          ),*/

          SizedBox(height: 10),
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
    js[Keys.requestZone] = 'get_aid_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdateHead(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;
      htmlData = data[Keys.data]?? '_';
      assistCtr.addStateAndUpdateHead(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }

  void onPayIranCall() async {
    //AppRoute.pushNamed(context, PayWebPage.route.name!, extra: 'https://zarinp.al/vosatezehn.ir');
    UrlHelper.launchLink('https://zarinp.al/vosatezehn.ir', mode: LaunchMode.externalApplication);
  }

  void onPayPalCall() async {
    //AppRoute.pushNamed(context, PayWebPage.route.name!, extra: 'https://www.paypal.com/donate/?hosted_button_id=K75F6ZADA3YCW');
    UrlHelper.launchLink('https://www.paypal.com/donate/?hosted_button_id=K75F6ZADA3YCW', mode: LaunchMode.externalApplication);
  }
}
