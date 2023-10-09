import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/aid_page.dart';
import 'package:app/views/pages/pay_web_page.dart';

class AidService {
  AidService._();

  static void gotoAidPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const AidPage());
  }

  static Future<bool> gotoZarinpalPage(BuildContext ctx) async {
    RouteTools.pushPage(ctx, const PayWebPage(url: 'https://zarinp.al/vosatezehn.ir'));
    return false;
  }

  static void showAidDialog(){
    final msg = SettingsManager.globalSettings.aidPopMessage;

    if(msg == null){
      return;
    }

    final body = Column(
      children: [
        Text(msg, style: AppThemes.baseTextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.bold)),

        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: (){
                    RouteTools.popTopView();
                    gotoZarinpalPage(RouteTools.getTopContext()!);
                  },
                  child: Text(AppMessages.aid)
              ),
            ),

            const SizedBox(width: 30),
            TextButton(
                onPressed: (){
                  RouteTools.popTopView();
                },
                child: Text(AppMessages.later)
            )
          ],
        )
      ],
    );

    AppDialogIris.instance.showIrisDialog(
        RouteTools.getTopContext()!,
       title: AppMessages.aidUs,
      yesFn: gotoZarinpalPage,
      //desc: msg,
      descView: body,
    );

    AppDB.setReplaceKv(Keys.setting$lastAidDialogShowTime, DateHelper.nowMinusUtcOffsetToTimestamp());
  }

  static void checkShowDialog() async {
    await Future.delayed(const Duration(seconds: 15), (){});

    if(!SessionService.hasAnyLogin()){
      return;
    }

    final lastTime = AppDB.fetchKv(Keys.setting$lastAidDialogShowTime);
    var lastTimeDt = DateHelper.timestampToSystem(lastTime);

    if(lastTimeDt != null){
      lastTimeDt = lastTimeDt.toUtc();
    }
    else {
      AppDB.setReplaceKv(Keys.setting$lastAidDialogShowTime, DateHelper.nowMinusUtcOffsetToTimestamp());
      return;
    }

    if(lastTime == null
        || DateHelper.isPastOf(lastTimeDt, Duration(days: SettingsManager.globalSettings.aidRepeatDays))){
      showAidDialog();
    }
  }
}
