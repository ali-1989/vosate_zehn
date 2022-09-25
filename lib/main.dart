import 'dart:async';

import 'package:app/services/firebase_service.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:go_router/go_router.dart';

import 'package:app/pages/splash_page.dart';
import 'package:app/tools/app/appRoute.dart';

bool _isInit = false;

///===== call on any hot restart ================================================================
Future<void> main() async {

  Future<void> appInitialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    SchedulerBinding.instance.ensureVisualUpdate();
    SchedulerBinding.instance.window.scheduleFrame();
    await InitialApplication.importantInit();

    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      var data = 'on Error catch: ${errorDetails.exception.toString()}';
      data += '\n stack: ${errorDetails.stack} \n---------------...----------------';

      PublicAccess.logger.logToAll(data);
    };

    GoRouter.setUrlPathStrategy(UrlPathStrategy.path);

    FireBaseService.init().then((value){
      FireBaseService.subscribeToTopic('daily_text');
    });
  }

  ///===== call on any hot reload
  runZonedGuarded((){
    appInitialize();
    runApp(const MyApp());
    }, (error, sTrace) {
    var txt = 'catch on ZonedGuarded: ${error.toString()}\n---------------...----------------';
    PublicAccess.logger.logToAll(txt);

      if(kDebugMode) {
        throw error;
      }
    }
  );

  //appInitialize();
  //runApp(const MyApp());
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


/*if(kIsWeb){
    flutterBindingInitialize();
  }
  else {
    Timer(const Duration(milliseconds: 100), flutterBindingInitialize);
  }*/