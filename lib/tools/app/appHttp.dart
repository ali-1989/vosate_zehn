import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/listHelper.dart';
import 'package:path/path.dart';

class AppHttp {
  AppHttp._();

  static int connectTimeout = 15000;

  static HttpRequester get(HttpItem item) {
    final itemRes = HttpRequester();

    try {
      final uri = correctUri(item.fullUri)!;
      itemRes.client = Client();
      //final BaseRequest request = Request(item.method?? 'GET', Uri.parse(uri), );

      itemRes._responseFuture = itemRes.client.get(
        Uri.parse(uri),
        headers: item.headers,
      )
          .timeout(Duration(milliseconds: connectTimeout + 2000), onTimeout: () async {
        return Response('timeout', 408);
      });
    }
		catch (e) {
      itemRes._responseFuture = Future.error(e);
    }

    return itemRes;
  }

  static HttpRequester post(HttpItem item) {
    final itemRes = HttpRequester();

    try {
      final uri = correctUri(item.fullUri)!;
      itemRes.client = Client();

      itemRes._responseFuture = itemRes.client.post(
        Uri.parse(uri),
        headers: item.headers,
        encoding: Encoding.getByName('utf-8'),
        body: item.body,
      )
          .timeout(Duration(milliseconds: connectTimeout + 2000), onTimeout: () async {
        return Response('timeout', 408);
      });
    }
		catch (e) {
      itemRes._responseFuture = Future.error(e);
    }

    return itemRes;
  }

	// .bytesToString()
  static Future<StreamedResponse?> uploadFile(HttpItem http, File? file) async {
    if (file == null) {
      return null;
    }

		try {
			ByteStream stream = ByteStream(file.openRead())..cast();
			final length = await file.length();
			final uri = Uri.parse(http.fullUri!);
			final request = MultipartRequest('POST', uri);
			final multiPartFile = MultipartFile('file', stream, length, filename: basename(file.path));
			request.files.add(multiPartFile);

      return await request.send();

    }
		catch (e) {
      return null;
    }
  }

  static void cancelAndClose(HttpRequester? request) {
    try {
      if (request != null) {
        request.client.close();
      }
    } catch (e) {
      /**/
    }
  }

  static String? correctUri(String? uri) {
    if (uri == null) {
      return null;
    }

    //return uri.replaceAll(RegExp('/{2,}'), "/").replaceFirst(':\/', ':\/\/');
    return uri.replaceAll(RegExp('(?<!:)(/{2,})'), '/');
  }
}
///========================================================================================================
class HttpRequester {
  late Future<Response?> _responseFuture;
  Response? _responseObj;
  late Client client;
  bool isOk = false;
  Map<String, dynamic>? parts;

  HttpRequester() {
    _responseFuture = Future(() {return null;});
  }

  Future<Response?> get response => _responseFuture;

  Response? get responseData => _responseObj;

  dynamic getBody() {
    if (_responseObj == null) {
      return null;
    }

    return _responseObj?.body;
  }

  Map<String, dynamic>? getBodyAsJson() {
    if (_responseObj == null) {
      return null;
    }

    final receive = _responseObj?.body;
    return JsonHelper.jsonToMap<String, dynamic>(receive);
  }

  Map<String, dynamic>? getPartByJsonName() {
    final parts = getParts();

    if (parts == null) {
      return getBodyAsJson();
    }

    final List<int>? receive = parts['Json'];

    if (receive == null) {
      return null;
    }

    return JsonHelper.jsonToMap(Converter.bytesToStringUtf8(receive));
  }

  dynamic getPart(String name) {
    final parts = getParts();

    if (parts == null) {
      return null;
    }

    return parts[name];
  }

  Map<String, dynamic>? getParts() {
    if (parts != null) {
      return parts;
    }

    final Uint8List bytes = _responseObj!.bodyBytes;

    if (bytes[0] == 13 && bytes[1] == 10 && bytes[2] == 10 && bytes[3] == 10) {
      parts = _reFactorBytes(bytes);
      return parts;
    }

    return null;
  }

  Map<String, dynamic> _reFactorBytes(List<int> bytes) {
    final res = <String, dynamic>{};
    late List<int> partSplitter;
    late List<int> nameSplitter;
    var idx = 0;

    for (var i = 5; i < bytes.length; i++) {
      if (bytes[i] == 13 && bytes[i + 1] == 10 && bytes[i + 2] == 10 && bytes[i + 3] == 10) {
        partSplitter = ListHelper.slice(bytes, 4, i - 4);
        idx = i + 4;
        break;
      }
    }

    for (var i = idx + 1; i < bytes.length; i++) {
      if (bytes[i] == 13 && bytes[i + 1] == 10 && bytes[i + 2] == 10 && bytes[i + 3] == 10) {
        nameSplitter = ListHelper.slice(bytes, idx, i - idx);
        idx = i + 4;
        break;
      }
    }

    var p = idx;
    var n = idx;

    while (true) {
      p = ListHelper.indexOf(bytes, partSplitter, start: p);

      if (p > -1) {
        p += partSplitter.length;

        n = ListHelper.indexOf(bytes, nameSplitter, start: p);

        if (n > -1) {
          final nameBytes = ListHelper.slice(bytes, p, n - p);
          final name = String.fromCharCodes(nameBytes);
          final lenIndex = n + nameSplitter.length;
          final lenBytes = ListHelper.slice(bytes, lenIndex, 4);
          final len = Int8List.fromList(lenBytes).buffer.asByteData().getInt32(0, Endian.big);
          res[name] = ListHelper.slice(bytes, lenIndex + 4, len);
          p += len;
        }
      } else {
        break;
      }
    }

    return res;
  }

  bool isError() {
    return _responseObj is Error || _responseObj is Exception;
  }

  Response emptyResponse = Response('-', 0);
}

///===================================================================================================
class HttpItem {
  HttpItem();

  String? fullUri;
  Map<String, dynamic> queries = {};
  Map<String, String> headers = {};
  dynamic body;
  String method = 'GET';

  void addPathQuery(String key, dynamic value) {
    queries[key] = value;
  }

  void addPathQueryAsMap(Map<String, dynamic> map) {
    for (var kv in map.entries) {
      queries[kv.key] = kv.value;
    }
  }

  void setBody(String value) {
    body = value;
  }

  void setBodyJson(Map js) {
    body = json.encode(js);
  }
}
