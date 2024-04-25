import 'dart:async';

import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:iris_db/iris_db.dart';

import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/app_tools.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/tools/route_tools.dart';

class CafeBazarService {
  static const rsa = 'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwChOAjldybANd57CEWIGCUPxqFoMoPYIxnLrxpuA8p0zvI9cuITW7fG4QgvCxRHf76K/0FvEnQgHrplisOxufqhQaDJVcBWYp6Lf44gI3u5hdK5i+6O4/MVcJrtVOwmmL5uMf9/vOjm1pHFFM8PWjIazlfpTsB9YJL7UWojHgv9O18dtww9sKuqmpRA23Ni6AMinahMm7DtQHYeCBYtBSX54+X/gUnzvGW93UaN4M8CAwEAAQ==';
  static CafeBazarService? _instance;
  bool _isConnected = false;

  CafeBazarService._init();

  factory CafeBazarService(){
    _instance ??= CafeBazarService._init();

    return _instance!;
  }

  bool get isConnected => _isConnected;

  FutureOr<bool> connect(){
    if(_isConnected){
      return _isConnected;
    }

    return FlutterPoolakey.connect(rsa, onDisconnected: () {
      _isConnected = false;
    }).catchError((e){
      if(e.toString().contains('BazaarNotFoundException')){
        AppToast.showToast(RouteTools.materialContext!, 'لطقا برنامه ی بازار را نصب یا به روز رسانی کنید.');
        return false;
      }

      LogTools.reportLogToServer(LogTools.buildServerLog('BazarConnect', error: e.toString()));
      AppToast.showToast(RouteTools.materialContext!, '$e');

      return false;
    });
  }

  /// for InApp buy (coin,...)
  Future<PurchaseInfo?> purchase(String productId, {String payload = ''}) async {
    return FlutterPoolakey.purchase(productId, payload: payload)
        .then<PurchaseInfo?>((value) => value)
        .catchError((e){
          if(e.toString().contains('PURCHASE_CANCELLED')){
            return null;
          }

          LogTools.reportLogToServer(LogTools.buildServerLog('BazarPurchase', error: e.toString()));
          return null;
    });
  }

  /// for subscription (30 days, 1 year,...)
  Future<PurchaseInfo?> doSubscribe(String productId, {String payload = ''}) async {
    return FlutterPoolakey.subscribe(productId, payload: payload)
        .then<PurchaseInfo?>((value) => value)
        .catchError((e){
          if(e.toString().contains('PURCHASE_CANCELLED')){
            return null;
          }

          LogTools.reportLogToServer(LogTools.buildServerLog('BazarSubscribe', error: e.toString()));
          return null;
    });
  }

  /// all user's subscriptions, must user be login in bazar app.
  Future<List<PurchaseInfo>> getAllSubscribedProducts() async {
    return FlutterPoolakey.getAllSubscribedProducts();
  }

  Future<List<SkuDetails>> getSubscriptionSkuDetails(List<String> products) async {
    return FlutterPoolakey.getSubscriptionSkuDetails(products);
  }

  Future<int> sinkFailedSendBuy(Map js) {
    final cons = Conditions();
    cons.add(Condition()..key = Keys.userId..value = js[Keys.userId]);
    cons.add(Condition()..key = 'plan_id'..value = js['plan_id']);
    cons.add(Condition()..key = 'purchase_token'..value = js['purchase_token']);

    return AppDB.db.insertOrIgnore(AppDB.cafeBazarBuy, js, cons);
  }

  Future<void> reSendFailed() async {
    final cons = Conditions();
    cons.add(Condition(ConditionType.DefinedNotNull)..key = 'purchase_token');

    final res = AppDB.db.query(AppDB.cafeBazarBuy, cons);

    for(final k in res){
      sendDataToServer(k, isFirst: false);
    }
  }

  Future<int> deleteFailedBuy(Map js) {
    final cons = Conditions();
    cons.add(Condition()..key = Keys.userId..value = js[Keys.userId]);
    cons.add(Condition()..key = 'plan_id'..value = js['plan_id']);
    cons.add(Condition()..key = 'purchase_token'..value = js['purchase_token']);

    return AppDB.db.delete(AppDB.cafeBazarBuy,  cons);
  }

  Future<bool> sendDataToServer(Map<String, dynamic> js, {bool isFirst = true}) {
    final requester = Requester();
    final ret = Completer<bool>();

    requester.httpRequestEvents.manageResponse = (req, r) async {
      if(req.isOk){
        await AppTools.requestProfileDataForVip();

        if(!isFirst) {
          deleteFailedBuy(js);
        }

        requester.dispose();
        return ret.complete(true);
      }
      else {
        if(isFirst) {
          await sinkFailedSendBuy(js);
        }

        requester.dispose();
        return ret.complete(false);
      }
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request();

    return ret.future;
  }
}
