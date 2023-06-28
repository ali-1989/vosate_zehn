import 'package:app/managers/api_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/tools.dart';

import 'package:app/system/commonHttpHandler.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appHttpDio.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/deviceInfoTools.dart';

///=============================================================================================
enum MethodType {
  post,
  get,
  put,
  delete,
}

enum RequestPath {
  getData,
  setData,
  others
}
///=============================================================================================
class Requester {
  Map<String, dynamic>? _bodyJs;
  MethodType methodType = MethodType.post;
  late HttpRequester _httpRequester;
  late HttpRequestEvents httpRequestEvents;
  late HttpItem _http;
  bool debug = false;

  Requester(){
    _prepareHttp();
    httpRequestEvents = HttpRequestEvents();
    _httpRequester = HttpRequester();
  }

  HttpItem get httpItem => _http;

  HttpRequester? get httpRequester => _httpRequester;

  Map<String, dynamic>? get bodyJson => _bodyJs;

  set bodyJson(Map<String, dynamic>? js) {
    _bodyJs = js;

    if(js != null) {
      DeviceInfoTools.attachApplicationInfo(_bodyJs!);
    }
  }

  void _prepareHttp(){
    _http = HttpItem();
    _http.setResponseIsPlain();
    _http.fullUrl = ApiManager.graphApi;
  }

  void prepareUrl({String? fullUrl, String? pathUrl}){
    if(fullUrl != null){
      _http.fullUrl = fullUrl;
      return;
    }

    pathUrl ??= '';

    _http.fullUrl = ApiManager.graphApi + pathUrl;
  }

  void request([BuildContext? context, bool promptErrors = true]){
    _http.debugMode = debug;

    switch(methodType){
      case MethodType.get:
        _http.method = 'GET';
        break;
      case MethodType.post:
        _http.method = 'POST';
        break;
      case MethodType.delete:
        _http.method = 'DELETE';
        break;
      case MethodType.put:
        _http.method = 'PUT';
        break;
    }

    if(_bodyJs != null) {
      _http.body = JsonHelper.mapToJson(_bodyJs!);
    }

    AppHttpDio.cancelAndClose(_httpRequester);

    /*if(Session.hasAnyLogin()) {
      _http.headers.addAll({'authorization': 'Bearer ${Session.getLastLoginUser()!.token?.token}'});
    }*/

    _httpRequester = AppHttpDio.send(_http);

    var f = _httpRequester.response.catchError((e){
      if(debug){
        Logger.L.logToScreen(' dio catch Error --> $e');
      }

      if (_httpRequester.isDioCancelError){
        return _httpRequester.emptyResponse;
      }

      httpRequestEvents.onAnyState?.call(_httpRequester);
      httpRequestEvents.onFailState?.call(_httpRequester, null);
      httpRequestEvents.onNetworkError?.call(_httpRequester);

      return null;
    });

    f = f.then((val) async {
      if(kDebugMode && !kIsWeb) {
        final url = _httpRequester.requestOptions?.uri;
        var request = '';

        if (_httpRequester.requestOptions?.data is String){
          final str = _httpRequester.requestOptions!.data as String;

          if(str.contains(Keys.requestZone)) {
            int start = str.indexOf(Keys.requestZone)+15;

            request = str.substring(start, start+15);
          }
        }

        Tools.verbosePrint('@@@>> [$url] [$request]  response ======= [${_httpRequester.responseData?.statusCode}] $val');
      }

      /*if(_httpRequester.responseData?.statusCode == 401 && Session.getLastLoginUser() != null){
        final getNewToken = await JwtService.requestNewToken(Session.getLastLoginUser()!);

        /// try request old api again
        if(getNewToken) {
          request(context, promptErrors);
        }
        else {
          await httpRequestEvents.onAnyState?.call(_httpRequester);
          await httpRequestEvents.onFailState?.call(_httpRequester, val);
        }

        return;
      }*/

      await httpRequestEvents.onAnyState?.call(_httpRequester);

      if(!_httpRequester.isOk){
        if(debug){
          Logger.L.logToScreen('>> Response receive, but is not ok | $val');
        }

        await httpRequestEvents.onFailState?.call(_httpRequester, val);
        return;
      }

      final Map? js = _httpRequester.getBodyAsJson();

      if (js == null) {
        if(debug){
          Logger.L.logToScreen('>> Response receive, but is not json | $val');
        }

        await httpRequestEvents.onFailState?.call(_httpRequester, val);
        return;
      }

      if(debug){
        Logger.L.logToScreen('status is 200 >> result : $js');
      }

      if(httpRequestEvents.manageResponse != null){
        await httpRequestEvents.manageResponse?.call(_httpRequester, js);
        return;
      }

      final result = js[Keys.status]?? Keys.error;

      if(result == Keys.ok) {
        await httpRequestEvents.onStatusOk?.call(_httpRequester, js);
      }
      else {
        await httpRequestEvents.onFailState?.call(_httpRequester, val);

        if(context != null && context.mounted) {
          if (promptErrors && !CommonHttpHandler.handler(context, js)) {
            await AppSheet.showSheet$ServerNotRespondProperly(context);
          }
        }
      }

      return null;
    });
  }

  void dispose(){
    AppHttpDio.cancelAndClose(_httpRequester);
  }
}
///================================================================================================
class HttpRequestEvents {
  Future Function(HttpRequester)? onAnyState;
  Future Function(HttpRequester requester, Response? response)? onFailState;
  Future Function(HttpRequester)? onNetworkError;
  Future Function(HttpRequester, Map)? manageResponse;
  Future Function(HttpRequester, Map)? onStatusOk;
  
  void clear(){
    onAnyState = null;
    onFailState = null;
    onNetworkError = null;
    manageResponse = null;
    onStatusOk = null;
  }
}
