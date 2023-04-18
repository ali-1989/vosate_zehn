import 'package:flutter/material.dart';

import 'package:app/pages/layout_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';


class RouteDispatcher {
  RouteDispatcher._();

  static Widget dispatch(){

    if(!Session.hasAnyLogin()){
      return LoginPage();
    }

    return LayoutPage(key: AppBroadcast.layoutPageKey);
  }
}
