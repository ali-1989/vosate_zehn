import 'dart:async';

import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/systemParameterModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appCache.dart';

class SystemParameterManager {
  static SystemParameterModel systemParameters = SystemParameterModel();

  SystemParameterManager._();

  static Future<SystemParameterModel?> requestParameters() async {
    if(!AppCache.canCallMethodAgain('requestParameters')){
      return systemParameters;
    }

    final res = Completer<SystemParameterModel?>();
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      res.complete(null);
      return true;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      systemParameters = SystemParameterModel.fromMap(data);

      res.complete(systemParameters);
    };

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_app_parameters';

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(null, false);
    return res.future;
  }
}
