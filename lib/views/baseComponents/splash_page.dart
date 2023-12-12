import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:app/managers/splash_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/views/baseComponents/splash_widget.dart';
import 'package:app/views/states/wait_to_load.dart';

class SplashPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}
///=============================================================================
class SplashPageState extends StateSuper<SplashPage> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    splashWaitTimer();

    //System.hideBothStatusBarOnce();

    if(kIsWeb){
      return const WaitToLoad();
    }

    return const SplashView();
  }

  void splashWaitTimer() async {
    if(!SplashManager.mustWaitToSplashTimer || timer != null){
      return;
    }

    final dur = Duration(milliseconds: SplashManager.splashWaitingMil);

    timer = Timer(dur, (){
      SplashManager.mustWaitToSplashTimer = false;
      timer = null;

      AppBroadcast.reBuildApp();
    });
  }
}
