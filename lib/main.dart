import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:go_router/go_router.dart';

import 'package:app/pages/splash_page.dart';
import 'package:app/tools/app/appManager.dart';
import 'package:app/tools/app/appRoute.dart';

bool _isInit = false;

///===== call on any hot restart ================================================================
Future<void> main() async {

  Future<void> flutterBindingInitialize() async {
    AppManager.widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    SchedulerBinding.instance.ensureVisualUpdate();
    SchedulerBinding.instance.window.scheduleFrame();

    GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  }

  if(kIsWeb){
    flutterBindingInitialize();
  }
  else {
    Timer(const Duration(milliseconds: 100), flutterBindingInitialize);
  }

  ///===== call on any hot reload
  runApp(const MyApp());
}
///==============================================================================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppRoute.materialContext = context;
    init();

    return const Material(
      child: SplashPage(),
    );
  }

  void init(){
    if(_isInit){
      return;
    }

    _isInit = true;
  }
}
