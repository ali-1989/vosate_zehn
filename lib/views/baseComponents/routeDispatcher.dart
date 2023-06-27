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
import 'package:iris_tools/api/cache/timeoutCache.dart';

class RouteDispatcher {
  RouteDispatcher._();

  static Widget dispatch(){

    if(!SessionService.hasAnyLogin()){
      if(kIsWeb){
        print('=============*==========================');
        print('cur path: ${IrisNavigatorObserver.currentPath()}');
        print('query: ${IrisNavigatorObserver.getPathQuery(IrisNavigatorObserver.currentUrl())}');

        final query = IrisNavigatorObserver.getPathQuery(IrisNavigatorObserver.currentUrl());
        bool contain = query.contains('verify=');

        if(contain){
          if(AppCache.canCallMethodAgain('request_verify_email')){
            final code = query.substring(7);
            print(code);
            LoginService.requestVerifyEmail(code: code);
          }

          return const WaitToLoad();
        }
      }

      final segments = IrisNavigatorObserver.pathSegments();
      final routes = IrisNavigatorObserver.currentRoutes();

      if(segments.isEmpty && routes.length == 1 && routes[0].startsWith('?email_login=')){

      }

      return LoginPage();
    }

    return LayoutPage(key: AppBroadcast.layoutPageKey);
  }
}
