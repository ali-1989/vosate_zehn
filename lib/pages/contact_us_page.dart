import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appSheet.dart';
import 'package:vosate_zehn/tools/app/appSnack.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';

class ContactUsPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/ContactUsPage',
    name: (ContactUsPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => ContactUsPage(),
  );

  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}
///==================================================================================
class _ContactUsPageState extends StateBase<ContactUsPage> {
  TextEditingController textCtr = TextEditingController();
  Requester requester = Requester();

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    textCtr.dispose();
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
              title: Text(AppMessages.contactUs),
            ),
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text(AppMessages.contactUsDescription).bold().fsR(2),
        ),

        Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: TextField(
                controller: textCtr,
                minLines: 8,
                maxLines: 12,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
              ),
            ),
        ),

        SizedBox(height: 20,),
        MaxWidth(
            maxWidth: 300,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSendCall,
                child: Text(AppMessages.send),
              ),
            )
        )
      ],
    );
  }

  void onSendCall(){
    FocusHelper.hideKeyboardByUnFocus(context);
    final txt = textCtr.text.trim();

    if(txt.isEmpty){
      AppSnack.showError(context, AppMessages.contactUsEmptyPrompt);
      return;
    }

    requestSendData();
  }

  void requestSendData() async {
    final txt = textCtr.text.trim();

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'send_ticket_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.data] = txt;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req) async {
      hideLoading();

      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      hideLoading();

      AppSheet.showSheet$SuccessOperation(context, onBtn: (){
        AppRoute.pop(context);
      });
    };

    showLoading();
    requester.prepareUrl();
    requester.request(context);
  }
}
