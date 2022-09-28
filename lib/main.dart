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

  void onErrorCatch(FlutterErrorDetails errorDetails) {
    var data = 'on Error catch: ${errorDetails.exception.toString()}';
    data += '\n stack: ${errorDetails.stack}\n------------------...-------------------';

    PublicAccess.logger.logToAll(data);
  }
  ///-------------------------
  zonedGuardedCatch(error, sTrace) {
    final txt = 'on ZonedGuarded catch: ${error.toString()}\n------------------...-------------------';
    PublicAccess.logger.logToAll(txt);

    if(kDebugMode) {
      throw error;
    }
  }
  ///-------------------------
  Future<bool> appInitialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    SchedulerBinding.instance.ensureVisualUpdate();
    SchedulerBinding.instance.window.scheduleFrame();
    final initOk = await InitialApplication.importantInit();

    if(!initOk){
      return false;
    }

    FlutterError.onError = onErrorCatch;
    GoRouter.setUrlPathStrategy(UrlPathStrategy.path);

    FireBaseService.init().then((value){
      FireBaseService.subscribeToTopic('daily_text');
    });
    
    return true;
  }


  ///===== call on any hot reload
  runZonedGuarded(() async {
    final isOk = await appInitialize();

    if (isOk) {
      runApp(const MyApp());
    }
    else {
      runApp(const MyErrorApp());
    }
  }, zonedGuardedCatch);

  //await appInitialize();
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
///==============================================================================================
class MyErrorApp extends StatelessWidget {
  const MyErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.expand(
          child: ColoredBox(
              color: Colors.brown,
            child: Text('Error in init.'),
          ),
        ),
      ),
    );
  }
}


/*if(kIsWeb){
    flutterBindingInitialize();
  }
  else {
    Timer(const Duration(milliseconds: 100), flutterBindingInitialize);
  }*/