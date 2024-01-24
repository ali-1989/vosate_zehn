import 'dart:io';
import 'dart:math';

import 'package:app/tools/app/app_http_dio.dart';

class FindCountryIp {
  FindCountryIp._();

  static Future<String> findCountryWithIP() async {
    var res = await findCountryWithIP2();
    res ??= await findCountryWithIP3();
    res ??= await findCountryWithIP4();

    return res?? 'US';
  }

  static Future<String?> findCountryWithIP2() async {
    const url = 'https://api.country.is';

    HttpItem http = HttpItem(fullUrl: url);
    http.method = 'GET';

    final res = AppHttpDio.send(http);

    return res.response.then((value) async {
      if(res.isOk){
        return res.getBodyAsJson()!['country'] as String;
      }

      return null;
    })
        .onError((error, stackTrace) => null);
  }

  static Future<String?> findCountryWithIP3() async {
    const url = 'https://api.db-ip.com/v2/free/self';

    HttpItem http = HttpItem(fullUrl: url);
    http.method = 'GET';

    final res = AppHttpDio.send(http);

    return res.response.then((value) {
      if(res.isOk){
        return res.getBodyAsJson()!['countryCode'] as String;
      }

      return null;
    })
        .onError((error, stackTrace) => null);
  }

  static Future<String?> findCountryWithIP4() async {
    const url = 'https://hutils.loxal.net/whois';

    HttpItem http = HttpItem(fullUrl: url);
    http.method = 'GET';

    final res = AppHttpDio.send(http);

    return res.response.then((value) {
      if(res.isOk){
        return res.getBodyAsJson()!['countryIso'] as String;
      }

      return null;
    })
        .onError((error, stackTrace) => null);
  }

  static Future<InternetAddress> retrieveIPAddress() async {
    int code = Random().nextInt(255);
    final dgSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    dgSocket.readEventsEnabled = true;
    dgSocket.broadcastEnabled = true;

    Future<InternetAddress> ret = dgSocket.timeout(const Duration(milliseconds: 100), onTimeout: (sink) {
      sink.close();
    }).expand<InternetAddress>((event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = dgSocket.receive();

        if (dg != null && dg.data.length == 1 && dg.data[0] == code) {
          dgSocket.close();
          return [dg.address];
        }
      }
      return [];
    }).firstWhere((InternetAddress? a) => a != null);

    dgSocket.send([code], InternetAddress('255.255.255.255'), dgSocket.port);
    return ret;
  }
}