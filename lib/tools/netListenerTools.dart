import 'package:app/managers/advertisingManager.dart';
import 'package:app/managers/appParameterManager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:iris_tools/net/netManager.dart';

import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appCache.dart';

/// this listener not work on start app, work on new event

class NetListenerTools {
  NetListenerTools._();

  static final List<void Function(bool isConnected)> _wsConnectListeners = [];

  static void addNetListener(void Function(ConnectivityResult) fn){
    NetManager.addChangeListener(fn);
  }

  static void removeNetListener(void Function(ConnectivityResult) fn){
    NetManager.removeChangeListener(fn);
  }

  static void addWsListener(void Function(bool) fn){
    if(!_wsConnectListeners.contains(fn)) {
      _wsConnectListeners.add(fn);
    }
  }

  static void removeWsListener(void Function(bool) fn){
    _wsConnectListeners.remove(fn);
  }

  // this call if (wifi/cell data) is connected(is on), else not call
  static void onNetListener(ConnectivityResult connectivityResult) async {

    if(connectivityResult != ConnectivityResult.none) {
      AppBroadcast.isNetConnected = true;

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
      AppCache.clearDownloading();
    }
  }

  static void onWsConnectedListener(){
    AppBroadcast.isWsConnected = true;

    /*todo if (Session.hasAnyLogin()) {
      final user = Session.getLastLoginUser()!;

      UserLoginTools.prepareRequestUsersProfileData();
    }*/

    for(final fn in _wsConnectListeners){
      fn.call(true);
    }
  }

  static void onWsDisConnectedListener(){
    AppBroadcast.isWsConnected = false;

    for(final fn in _wsConnectListeners){
      fn.call(false);
    }
  }
}
