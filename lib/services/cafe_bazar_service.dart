
import 'dart:async';

import 'package:flutter_poolakey/flutter_poolakey.dart';

class CafeBazarService {
  static const rsa = 'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwChOAjldybANd57CEWIGCUPxqFoMoPYIxnLrxpuA8p0zvI9cuITW7fG4QgvCxRHf76K/0FvEnQgHrplisOxufqhQaDJVcBWYp6Lf44gI3u5hdK5i+6O4/MVcJrtVOwmmL5uMf9/vOjm1pHFFM8PWjIazlfpTsB9YJL7UWojHgv9O18dtww9sKuqmpRA23Ni6AMinahMm7DtQHYeCBYtBSX54+X/gUnzvGW93UaN4M8CAwEAAQ==';
  static CafeBazarService? _instance;
  bool _isConnected = false;

  CafeBazarService._init();

  factory CafeBazarService(){
    _instance ??= CafeBazarService._init();

    return _instance!;
  }

  FutureOr<bool> connect(){
    if(_isConnected){
      return _isConnected;
    }

    return FlutterPoolakey.connect(rsa, onDisconnected: () {
      _isConnected = false;
      print('************ bazar disconnected ***********');
    });
  }

  /// for InApp buy (coin,...)
  Future<PurchaseInfo> purchase(String productId, {String payload = ''}) async {
     return FlutterPoolakey.purchase(productId, payload: payload);
  }

  /// for subscription (30 days, 1 year,...)
  Future<PurchaseInfo> subscribe(String productId, {String payload = ''}) async {
    return FlutterPoolakey.subscribe(productId, payload: payload);
  }

  /// must user be login in bazar app.
  Future<List<PurchaseInfo>> getAllSubscribedProducts() async {
    return FlutterPoolakey.getAllSubscribedProducts();
  }

  Future<List<SkuDetails>> getSubscriptionSkuDetails(List<String> products) async {
    return FlutterPoolakey.getSubscriptionSkuDetails(products);
  }
}