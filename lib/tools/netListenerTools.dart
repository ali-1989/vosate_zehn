import 'package:app/services/event_dispatcher_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:app/managers/advertisingManager.dart';
import 'package:app/managers/appParameterManager.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appCache.dart';

/// this listener not work on start app, work on new event

class NetListenerTools {
  NetListenerTools._();

  /// this fn call on app launch: if (wifi/cell data) is on.
  static void onNetListener(ConnectivityResult connectivityResult) async {
    EventDispatcherService.notify(EventDispatcher.networkStateChange);

    if(connectivityResult != ConnectivityResult.none) {
      AppBroadcast.isNetConnected = true;
      EventDispatcherService.notify(EventDispatcher.networkConnected);
      //await ServerTimeTools.requestUtcTimeOfServer();
      AppParameterManager.requestParameters();
      AdvertisingManager.check();

      if (Session.hasAnyLogin()) {
        //final user = Session.getLastLoginUser()!;

        /*if (user.isSetProfileImage) {
          DrawerMenuTool.prepareAvatar(user);
        }*/
      }
    }
    else {
      AppBroadcast.isNetConnected = false;
      EventDispatcherService.notify(EventDispatcher.networkDisConnected);

      AppCache.clearDownloading();
    }
  }

  static void onWsConnectedListener(){
    AppBroadcast.isWsConnected = true;
    EventDispatcherService.notify(EventDispatcher.webSocketStateChange);
    EventDispatcherService.notify(EventDispatcher.webSocketConnected);
  }

  static void onWsDisConnectedListener(){
    AppBroadcast.isWsConnected = false;
    EventDispatcherService.notify(EventDispatcher.webSocketDisConnected);
  }
}
