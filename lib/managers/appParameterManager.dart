import 'dart:async';

import 'package:app/models/appParameterModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';

class AppParameterManager {
  static AppParameterModel? parameterModel;

  AppParameterManager._();

  static Future<AppParameterModel?> requestParameters() async {
    final res = Completer<AppParameterModel?>();
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      res.complete(null);
      return true;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      parameterModel = AppParameterModel.fromMap(data);

      res.complete(parameterModel);
    };

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_app_parameters';

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(null, false);
    return res.future;
  }
}
