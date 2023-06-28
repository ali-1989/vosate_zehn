import 'package:app/services/login_service.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:app/pages/layout_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:iris_route/iris_route.dart';

class RouteDispatcher {
  RouteDispatcher._();

  static Widget dispatch(){

    if(!SessionService.hasAnyLogin()){
      if(kIsWeb){
        final query = IrisNavigatorObserver.getPathQuery(IrisNavigatorObserver.currentUrl());
        bool contain = query.contains('register=');

        if(contain){
          if(AppCache.canCallMethodAgain('request_is_verify_email')){
            final code = query.substring(9);
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
