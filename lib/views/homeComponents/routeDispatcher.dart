import 'package:flutter/material.dart';

import 'package:app/pages/layout_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';

import 'package:app/tools/app/appRouteNoneWeb.dart'
 if (dart.library.html) 'package:app/tools/app/appRouteWeb.dart' as web;

class RouteDispatcher {
  RouteDispatcher._();

  static Widget dispatch(){
    if(web.getCurrentWebAddress() != web.getBaseWebAddress()) {
      //log('dispatch >>>>>>>>>>>>>>>>> ${web.getCurrentWebAddress()}');
    }

    if(!Session.hasAnyLogin()){
      return LoginPage();
    }

    return LayoutPage(key: AppBroadcast.layoutPageKey);
  }
}
