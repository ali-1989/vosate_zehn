import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/dailyTextModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';

class DailyTextService {
  DailyTextService._();

  static void checkShowDialog(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 10), (){});

    if(!SessionService.hasAnyLogin()){
      return;
    }

    final list = await _requestData();

    if(list == null){
      return;
    }

    final ids = AppDB.fetchAsList<int>(Keys.setting$dailyIdsList);

    for(final k in list){
     if(k.date != null && DateHelper.isToday(k.date!)){
        if(!ids.contains(k.id)){
          showDailyDialog(context, k.text);
          AppDB.addToList(Keys.setting$dailyIdsList, k.id);
        }
      }
    }
  }

  static void showDailyDialog(BuildContext context, String msg){
    final body = Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
              onPressed: (){
                RouteTools.popTopView(context: context);
              },
              icon: const Icon(AppIcons.close)
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical:8.0),
          child: Text(msg, style: AppThemes.baseTextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 10),
      ],
    );

    final decoration = AppDialogIris.instance.dialogDecoration.copy();
    decoration.padding = EdgeInsets.zero;

    AppDialogIris.instance.showIrisDialog(
      context,
      descView: body,
      decoration: decoration,
    );
  }

  static Future<List<DailyTextModel>?> _requestData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_daily_text_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;

    final List<DailyTextModel> result = [];
    final comp = Completer<List<DailyTextModel>?>();
    final requester = Requester();

    requester.httpRequestEvents.onFailState = (req, r) async {
      comp.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final List tList = data[Keys.dataList]?? [];

      for(final m in tList){
        result.add(DailyTextModel.fromMap(m));
      }

      comp.complete(result);
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(null, false);

    return comp.future;
  }
}
