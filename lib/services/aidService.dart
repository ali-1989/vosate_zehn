import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/systemParameterManager.dart';
import 'package:app/pages/aid_page.dart';
import 'package:app/pages/pay_web_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';

class AidService {
  AidService._();

  static void gotoAidPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushPage(AppRoute.getLastContext()!, AidPage());
  }

  static Future<bool> gotoZarinpalPage() async {
    AppRoute.pushPage(AppRoute.getLastContext()!, PayWebPage(url: 'https://zarinp.al/vosatezehn.ir'));
    return false;
  }

  static void showAidDialog(){
    final msg = SystemParameterManager.systemParameters.aidPopMessage;

    if(msg == null){
      return;
    }

    final body = Column(
      children: [
        Text(msg, style: AppThemes.bodyTextStyle()!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),

        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: (){
                    AppRoute.popTopView();
                    gotoZarinpalPage();
                  },
                  child: Text(AppMessages.aid)
              ),
            ),

            SizedBox(width: 30),
            TextButton(
                onPressed: (){
                  AppRoute.popTopView();
                },
                child: Text(AppMessages.later)
            )
          ],
        )
      ],
    );

    AppDialogIris.instance.showIrisDialog(
        AppRoute.getLastContext()!,
       title: AppMessages.aidUs,
      yesFn: gotoZarinpalPage,
      //desc: msg,
      descView: body,
    );

    AppDB.setReplaceKv(Keys.setting$lastAidDialogShowTime, DateHelper.getNowTimestampToUtc());
  }

  static void checkShowDialog() async {
    await Future.delayed(Duration(seconds: 20), (){});

    if(!Session.hasAnyLogin()){
      return;
    }

    final lastTime = AppDB.fetchKv(Keys.setting$lastAidDialogShowTime);
    var lastTimeDt = DateHelper.tsToSystemDate(lastTime);

    if(lastTimeDt != null){
      lastTimeDt = lastTimeDt.toUtc();
    }
    else {
      AppDB.setReplaceKv(Keys.setting$lastAidDialogShowTime, DateHelper.getNowTimestampToUtc());
      return;
    }

    if(lastTime == null
        || DateHelper.isPastOf(lastTimeDt, Duration(days: SystemParameterManager.systemParameters.aidRepeatDays))){
      showAidDialog();
    }
  }
}
