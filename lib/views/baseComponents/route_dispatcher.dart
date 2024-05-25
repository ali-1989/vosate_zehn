import 'package:app/tools/route_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/views/pages/layout_page.dart';
import 'package:app/views/pages/login/login_page.dart';
import 'package:app/views/states/wait_to_load.dart';

class RouteDispatcher {
  RouteDispatcher._();

  static Widget dispatch(){
    if(!SessionService.hasAnyLogin()){
      if(kIsWeb){
        final queryMap = RouteTools.oneNavigator.queryMap;
        bool contain = queryMap.keys.contains('register');

        if(contain){
          if(AppCache.canCallMethodAgain('request_is_verify_email')){
            final code = queryMap['register'];
            LoginService.requestCanRegisterWithEmail(code: code);
          }

          return const WaitToLoad();
        }
      }

      return LoginPage();
    }

    return LayoutPage(key: AppBroadcast.layoutPageKey);
  }
}
