import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/appParameterManager.dart';
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
    AppRoute.pushNamed(AppRoute.getLastContext()!, AidPage.route.name!);
  }

  static void gotoZarinpalPage() async {
    AppRoute.pushNamed(AppRoute.getLastContext()!, PayWebPage.route.name!);
  }

  static void showAidDialog(){
    final msg = AppParameterManager.parameterModel?.aidPopMessage;

    if(msg == null){
      return;
    }

    final body = Column(
      children: [
        Text(msg, style: AppThemes.body2TextStyle()!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),

        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: (){
                    Navigator.of(AppRoute.getLastContext()!).pop();
                    gotoZarinpalPage();
                  },
                  child: Text(AppMessages.aid)
              ),
            ),

            SizedBox(width: 30),
            TextButton(
                onPressed: (){
                  Navigator.of(AppRoute.getLastContext()!).pop();
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
        || DateHelper.isPastOf(lastTimeDt, Duration(days: AppParameterManager.parameterModel?.aidRepeatDays?? 30))){
      showAidDialog();
    }
  }
}
