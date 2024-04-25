import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/tools.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/services/websocket_service.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_http_dio.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/http_tools.dart';
import 'package:app/tools/route_tools.dart';

enum MethodType {
  post,
  get,
  put,
  delete,
}
///=============================================================================
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
      DeviceInfoTools.attachDeviceAndTokenInfo(_bodyJs!);
    }
  }

  void _prepareHttp(){
    _http = HttpItem();
    _http.setResponseIsPlain();
    _http.fullUrl = ApiManager.serverApi;
  }

  void prepareUrl({String? fullUrl, String? pathUrl}){
    if(fullUrl != null){
      _http.fullUrl = fullUrl;
      return;
    }

    pathUrl ??= '';

    _http.fullUrl = ApiManager.serverApi + pathUrl;
  }

  void request(){
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

    /*if(SessionService.hasAnyLogin()) {
      _http.headers.addAll({'authorization': 'Bearer ${SessionService.getLastLoginUser()!.token?.token}'});
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

    f = f.then((response) async {
      if(kDebugMode && !kIsWeb) {
        final url = _httpRequester.requestOptions?.uri;
        var request = '';

        if(_http.method != 'GET') {
          if (_http.body is String) {
            request = _http.body as String;
          }

          if (_http.body is Map) {
            request = _http.body.toString();
          }

          if (request.length > 500) {
            request = request.substring(0, 500);
          }
        }
        else {
          request = 'GET';
        }

        var pr = '>_._._._._._._.__._._ API CALLED __._._._._._._._'
            '\nurl:[$url]'
            '\n\nrequest:[$request]'
            '\n\n >>> status code:[${_httpRequester.responseData?.statusCode}]'
            '\nresponse >:$response'
            '\n_._._._._._._.__._._._._._._.__._._._ End';

        Tools.verboseLog(pr);
      }

      /* refresh token
       if(_httpRequester.responseData?.statusCode == 401 && SessionService.getLastLoginUser() != null){
        JwtService.stopRefreshService();
        final getNewToken = await JwtService.requestNewToken(SessionService.getLastLoginUser()!);

        /// try request old api again
        if(getNewToken) {
          request(context, promptErrors);
        }
        else {
          await httpRequestEvents.onAnyState?.call(_httpRequester);
          await httpRequestEvents.onFailState?.call(_httpRequester, response);
        }

        return;
      }*/

      await httpRequestEvents.onAnyState?.call(_httpRequester);

      if(!_httpRequester.isOk){
        if(debug){
          Logger.L.logToScreen('>> Response receive, but is not ok | $response');
        }

        await httpRequestEvents.onFailState?.call(_httpRequester, response);
        await httpRequestEvents.manageResponse?.call(_httpRequester, {});
        return;
      }

      WebsocketService.connect();
      final Map? js = _httpRequester.getBodyAsJson();

      if (js == null) {
        if(debug){
          Logger.L.logToScreen('>> Response receive, but is not json | $response');
        }

        await httpRequestEvents.onFailState?.call(_httpRequester, response);
        await httpRequestEvents.manageResponse?.call(_httpRequester, {});
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
        final stop = HttpTools.handlerTokenOrBlock(RouteTools.materialContext!, js);

        if(stop){
         return;
        }

        final process = await httpRequestEvents.onFailState?.call(_httpRequester, response);

        if(process == null || !process) {
          HttpTools.handler(RouteTools.materialContext!, js);
        }
      }

      return null;
    });
  }

  void dispose(){
    AppHttpDio.cancelAndClose(_httpRequester);
  }
}
///=============================================================================
/// HttpTools.handler(RouteTools.getTopContext()!, req.getBodyAsJson()?? {});
class HttpRequestEvents {
  Future Function(HttpRequester req)? onAnyState;
  Future<bool?> Function(HttpRequester req, Response? response)? onFailState;
  Future Function(HttpRequester req)? onNetworkError;
  Future Function(HttpRequester req, Map response)? manageResponse;
  Future Function(HttpRequester req, Map response)? onStatusOk;
  
  void clear(){
    onAnyState = null;
    onFailState = null;
    onNetworkError = null;
    manageResponse = null;
    onStatusOk = null;
  }
}
