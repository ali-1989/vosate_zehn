import 'package:flutter/material.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/notifiers/appEventListener.dart';
import 'package:iris_tools/net/netManager.dart';

import 'package:app/structures/enums/app_events.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_cache.dart';

class ApplicationSignal {
  ApplicationSignal._();

  static void start(){
    final eventListener = AppEventListener();
    eventListener.addResumeListener(ApplicationSignal.onResume);
    eventListener.addPauseListener(ApplicationSignal.onPause);
    eventListener.addDetachListener(ApplicationSignal.onDetach);
    WidgetsBinding.instance.addObserver(eventListener);

    /// net & websocket
    NetManager.addChangeListener(onNetListener);
  }

  static void onPause() async {
    if(!AppCache.timeoutCache.addTimeout('onPause', const Duration(seconds: 3))) {
      return;
    }

    EventNotifierService.notify(AppEvents.appPause);
  }

  static void onDetach() async {
    if(!AppCache.timeoutCache.addTimeout('onDetach', const Duration(seconds: 3))) {
      return;
    }

    EventNotifierService.notify(AppEvents.appDeAttach);
  }

  static void onResume() {
    EventNotifierService.notify(AppEvents.appResume);
  }

  /// this fn call on app launch: if (wifi/cell data) is on. on Web not call
  static void onNetListener(List<ConnectivityResult> connectivityResult) async {
    EventNotifierService.notify(AppEvents.networkStateChange);

    if(connectivityResult.isEmpty || connectivityResult.contains(ConnectivityResult.none)) {
      AppBroadcast.isNetConnected = false;
      EventNotifierService.notify(AppEvents.networkDisConnected);

      AppCache.clearDownloading();
    }
    else {
      AppBroadcast.isNetConnected = true;
      EventNotifierService.notify(AppEvents.networkConnected);
    }
  }

  static void onWsConnectedListener(){
    AppBroadcast.isWsConnected = true;
    EventNotifierService.notify(AppEvents.webSocketStateChange);
    EventNotifierService.notify(AppEvents.webSocketConnected);
  }

  static void onWsDisConnectedListener(){
    AppBroadcast.isWsConnected = false;
    EventNotifierService.notify(AppEvents.webSocketStateChange);
    EventNotifierService.notify(AppEvents.webSocketDisConnected);
  }
}
