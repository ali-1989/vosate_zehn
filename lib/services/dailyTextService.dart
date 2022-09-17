import 'dart:async';

import 'package:app/models/dailyTextModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class DailyTextService {
  DailyTextService._();

  static void showDailyDialog(String msg){
    final body = Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
              onPressed: (){
                Navigator.of(AppRoute.getContext()).pop();
              },
              icon: Icon(AppIcons.close)
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical:8.0),
          child: Text(msg, style: AppThemes.body2TextStyle()!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
        ),

        SizedBox(height: 10),
      ],
    );

    final decoration = AppDialogIris.instance.dialogDecoration.copy();
    decoration.padding = EdgeInsets.zero;
    decoration.titlePadding = EdgeInsets.zero;

    AppDialogIris.instance.showIrisDialog(
        AppRoute.getContext(),
       descView: body,
      decoration: decoration,
    );
  }

  static void checkShowDialog() async {
    await Future.delayed(Duration(seconds: 10), (){});

    if(!Session.hasAnyLogin()){
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
          showDailyDialog(k.text);
          AppDB.addToList(Keys.setting$dailyIdsList, k.id);
        }
      }
    }
  }

  static Future<List<DailyTextModel>?> _requestData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_daily_text_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    final List<DailyTextModel> result = [];
    final comp = Completer<List<DailyTextModel>?>();
    final requester = Requester();

    requester.httpRequestEvents.onFailState = (req) async {
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