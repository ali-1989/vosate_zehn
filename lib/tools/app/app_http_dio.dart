import 'dart:convert' as system_convert;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/listHelper.dart';

import 'package:app/tools/log_tools.dart';

class AppHttpDio {
	AppHttpDio._();

	static BaseOptions _genOptions(){
		return BaseOptions(
			connectTimeout: const Duration(seconds: 15),
		);
	}

	static HttpRequester send(HttpItem httpItem, {BaseOptions? options}){
		httpItem.prepareMultiParts();

		if(httpItem.debugMode) {
			var txt = '\n-------------------------http debug\n';
			txt += 'url: ${httpItem.fullUrl}\n';
			txt += 'Method: ${httpItem.method}\n';
			txt += 'Headers: ${httpItem.headers}\n';

			if(httpItem.body is String) {
				txt += 'Body: ${httpItem.body} \n------------------------- End';
			}
			else if(httpItem.body is MultipartFile) {
				txt += 'MultipartFile: Len> ${(httpItem.body as MultipartFile).length} \n';
				txt += 'MultipartFile: Mime> ${(httpItem.body as MultipartFile).contentType?.mimeType} \n------------------------- End';
			}
			else if(httpItem.body is FormData) {
				txt += 'FormData: Len> ${(httpItem.body as FormData).length} \n';
				txt += 'FormData: boundary> ${(httpItem.body as FormData).boundary} \n';
				txt += 'FormData: files len> ${(httpItem.body as FormData).files.length} \n';
				txt += 'FormData: fields len> ${(httpItem.body as FormData).fields.length} \n------------------------- End';
			}

			LogTools.logger.logToAll(txt);
		}

		final itemRes = HttpRequester();

		try {
			Dio dio = Dio(options ?? _genOptions());

			final uri = correctUri(httpItem.fullUrl)!;

			///  add proxy
			if(httpItem.useProxy && httpItem.proxyAddress != null) {
				(dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
					final client = HttpClient();

					client.findProxy = (uri) {
						return 'PROXY ${httpItem.proxyAddress}';
					};

					client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

					return client;
				};
			}

			final inter = InterceptorsWrapper(
					onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
						itemRes.requestOptions = options;

						if(!kIsWeb) {
							options.headers['Connection'] = 'close';
						}

						if(httpItem.headers.isNotEmpty){
							options.headers.addAll(httpItem.headers);
						}

						return handler.next(options);
						//return handler.resolve(response);
						//return handler.reject(dioError);
					},
					onResponse: (Response<dynamic> res, ResponseInterceptorHandler handler) {
						if(httpItem.debugMode) {
							var txt = '\n----------------- http Debug [onResponse]\n';
							txt += 'statusCode:  ${res.statusCode}\n';
							txt += 'response.data: ${res.data}\n----------------------- End Debug';

							LogTools.logger.logToAll(txt);
						}

						itemRes._response = res;
						itemRes.isOk = !(res is Error
								|| res is Exception
								|| res.statusCode != 200
								|| res.data == null);

						if(httpItem.onResponseCall?.call(res)?? true) {
							handler.next(res);
						}
					},
					onError: (DioException err, ErrorInterceptorHandler handler) async {
						if(httpItem.debugMode) {
							var txt = '\n----------------- http Debug [onError]\n';
							txt += 'statusCode: ${err.response?.statusCode}\n';
							txt += 'response.data: ${err.response?.data}\n';
							txt += 'error: ${err.error} \n--------------------------- End Debug';

							LogTools.logger.logToAll(txt);
						}

						final ro = RequestOptions(path: uri);
						itemRes.requestOptions = ro;

						final res = Response<dynamic>(
								requestOptions: ro,
								statusCode: err.response?.statusCode,
								data: err.response ?? DioException(requestOptions: ro, error: err.error, type: DioExceptionType.unknown)
						);

						itemRes._response = err.response?? res;

						handler.resolve(itemRes._response!);
					}
			);

			dio.interceptors.add(inter);

			final cancelToken = CancelToken();
			itemRes.dio = dio;
			itemRes.canceller = cancelToken;

			itemRes._responseAsync = dio.request<dynamic>(
				uri,
				cancelToken: cancelToken,
				options: httpItem.options,
				queryParameters: httpItem.queries,
				data: httpItem.body,
				onReceiveProgress: httpItem.onReceiveProgress,
				onSendProgress: httpItem.onSendProgress,
			);
		}
		catch (e) {
			itemRes._responseAsync = Future.error(e);
		}

		return itemRes;
	}

	static HttpRequester download(HttpItem item, String savePath, {BaseOptions? options}){
		if(item.debugMode && !kIsWeb) {
			LogTools.logger.logToAll('==== Stack Trace : ${StackTrace.current.toString()}');
		}

		final itemRes = HttpRequester();
		Dio dio;

		try {
			dio = Dio(options ?? _genOptions());

			final uri = correctUri(item.fullUrl)!;

			if(item.useProxy && item.proxyAddress != null) {
				(dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
					final client = HttpClient();
					client.findProxy = (uri) {
						return 'PROXY ${item.proxyAddress}';
					};

					client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

					return client;
				};
			}

			final downloadInter = InterceptorsWrapper(
					onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
						if(!kIsWeb) {
							options.headers['Connection'] = 'close';
						}

						itemRes.requestOptions = options;

						handler.next(options);
					},

					onResponse: (Response<dynamic> res, ResponseInterceptorHandler handler) {
						itemRes._response = res;

						itemRes.isOk = !(res is Error
								|| res is Exception
								|| (res.statusCode != 200 && res.statusCode != 206)
								|| res.data == null);

						handler.next(res);
					},

					onError: (DioException err, ErrorInterceptorHandler handler) {
						final ro = RequestOptions(path: uri);
						final Response res = Response<ResponseBody>(requestOptions: ro, data: ResponseBody.fromBytes([], 404));
						//Response res = Response<ResponseBody>(requestOptions: ro, data: ResponseBody.fromString('$err', 404));
						//Response res = Response<DioError>(requestOptions: ro, data: DioError(requestOptions: ro));
						itemRes._response = res;
						itemRes.isOk = false;

						//handler.next(err);   < this take log error
						//handler.reject(err); < this take log error
						handler.resolve(res);
					});
			dio.interceptors.add(downloadInter);

			final cancelToken = CancelToken();
			itemRes.dio = dio;
			itemRes.canceller = cancelToken;

			itemRes._responseAsync = dio.download(
					uri,
					savePath,
				cancelToken: cancelToken,
				options: item.options,
				queryParameters: item.queries,
				data: item.body,
				onReceiveProgress: item.onReceiveProgress,
			);
		}
		catch (e) {
			itemRes._responseAsync = Future.error(e);
		}

		return itemRes;
	}

	// https://stackoverflow.com/questions/56638826/downloading-progress-in-darthttp
	static HttpRequester getHeaders(HttpItem item ,{Duration? timeout}){
		final itemRes = HttpRequester();

		try {
			//HttpClient g = HttpClient();  this is used in dio

			final client = http.Client();
			//final HttpClient client = HttpClient(); client.openUrl(request.method, Uri.parse(uri))

			final uri = correctUri(item.fullUrl)!;
			final http.BaseRequest request = http.Request(item.method?? 'GET', Uri.parse(uri));
			request.persistentConnection = false;
			request.headers['Range'] = 'bytes=0-'; // > Content-Range: bytes 0-1023/146515

			Future<http.StreamedResponse?> send = client.send(request);

			send = send
					.timeout(timeout?? const Duration(seconds: 26),)
					.catchError((e){ // TimeoutException
						return null;
						//client.close();
					});

			itemRes._responseAsync = send.then((http.StreamedResponse? response) {
				if(response == null || response is Error) {
					return null;//Response<http.StreamedResponse>(data: null, requestOptions: RequestOptions(path: uri));
				}

				//Map headers = response.headers;
				itemRes.isOk = true;

				client.close();
				return Response<http.StreamedResponse>(data: response, requestOptions: RequestOptions(path: uri));
				/*
				int received = 0;
				int length = response.contentLength;

				StreamSubscription listen;
				listen = response.stream.listen((List<int> bytes) {
					received += bytes.length;

					if(received > 200) {
						client.close();
						listen.cancel();
					}
				},
				onDone: (){
					client.close();
					listen.cancel();
				},
				onError: (e){
					client.close();
					listen.cancel();
				},
				cancelOnError: true
				);*/
			});
		}
		catch (e) {
			itemRes._responseAsync = Future.error(e);
		}

		return itemRes;
	}

	static void cancelAndClose(HttpRequester? request, {String passTag = 'my'}) {
		if(request != null){
			if(!(request.canceller?.isCancelled?? true)) {
			  request.canceller?.cancel(passTag);
			}

			request.dio?.close(force: true);
		}
	}

	static String? correctUri(String? uri) {
		if(uri == null) {
		  return null;
		}

		return uri.replaceAll(RegExp('/{2,}'), '/').replaceFirst(':/', '://');
		//return uri.replaceAll(RegExp('(?<!:)(/{2,})'), '/');
	}
}
///========================================================================================================
class HttpRequester {
	late Future<Response?> _responseAsync;
	Response? _response;
	RequestOptions? requestOptions;
	CancelToken? canceller;
	Dio? dio;
	bool isOk = false;
	Map<String, dynamic>? parts;

	HttpRequester(){
		_responseAsync = Future((){return null;});
	}

	// maybe: Future<dynamic> vs Future<Response?>
	Future<Response?> get response => _responseAsync;

	Response? get responseData => _response;

	dynamic getBody(){
		if(_response == null) {
		  return null;
		}

		return _response?.data;
	}

	Map<String, dynamic>? getBodyAsJson(){
		if(_response == null) {
		  return null;
		}

		final receive = _response?.data.toString();

		try {
			return JsonHelper.jsonToMap<String, dynamic>(receive);
		}
		catch (e){
			return {};
		}
	}

	Map<String, dynamic>? getPartByJsonName(){
		final parts = getParts();

		if(parts == null) {
		  return getBodyAsJson();
		}

		final List<int>? receive = parts['Json'];

		if(receive == null) {
		  return null;
		}

		return JsonHelper.jsonToMap(Converter.bytesToStringUtf8(receive));
	}

	dynamic getPart(String name){
		final parts = getParts();

		if(parts == null) {
		  return null;
		}

		return parts[name];
	}

	Map<String, dynamic>? getParts(){
		if(parts != null) {
		  return parts;
		}

		final List<int> bytes = _response?.data;

		if(bytes[0] == 13 && bytes[1] == 10 && bytes[2] == 10 && bytes[3] == 10){
			parts = _reFactorBytes(bytes);
			_response?.data = null;
			return parts;
		}

		return null;
	}

	Map<String, dynamic> _reFactorBytes(List<int> bytes){
		final res = <String, dynamic>{};
		late List<int> partSplitter;
		late List<int> nameSplitter;
		var idx = 0;

		for(var i = 5; i < bytes.length; i++){
			if(bytes[i] == 13 && bytes[i+1] == 10 && bytes[i+2] == 10 && bytes[i+3] == 10) {
				partSplitter = ListHelper.slice(bytes, 4, i - 4);
				idx = i+4;
				break;
			}
		}

		for(var i = idx+1; i < bytes.length; i++){
			if(bytes[i] == 13 && bytes[i+1] == 10 && bytes[i+2] == 10 && bytes[i+3] == 10) {
				nameSplitter = ListHelper.slice(bytes, idx, i - idx);
				idx = i+4;
				break;
			}
		}

		var p = idx;
		var n = idx;

		while(true){
			p = ListHelper.indexOf(bytes, partSplitter, start: p);

			if(p > -1) {
				p += partSplitter.length;

				n = ListHelper.indexOf(bytes, nameSplitter, start: p);

				if(n > -1) {
					final nameBytes = ListHelper.slice(bytes, p, n-p);
					final name = String.fromCharCodes(nameBytes);
					final lenIndex = n + nameSplitter.length;
					final lenBytes = ListHelper.slice(bytes, lenIndex, 4);
					final len = Int8List.fromList(lenBytes).buffer.asByteData().getInt32(0, Endian.big);
					res[name] = ListHelper.slice(bytes, lenIndex+4, len);
					p += len;
				}
			}
			else {
			  break;
			}
		}

		return res;
	}

	bool isError(){
		return _response is Error || _response is Exception;
	}

	bool get isDioCancelError {
		return _response is DioException && (_response as DioException).message == 'my';
	}

	bool isCancelError(dynamic e) {
		return e is DioException && e.message == 'my';
	}

	Response emptyResponse = Response<ResponseBody>(
			requestOptions: RequestOptions(path: '-empty-'),
			data: null,
	);//ResponseBody.fromString('non', 404)
}
///========================================================================================================
class HttpItem {
	String fullUrl = '';
	String? proxyAddress;
	bool useProxy = false;
	bool debugMode = false;
	dynamic body;
	bool Function(Response response)? onResponseCall;
	Map<String, dynamic> queries = {};
	Map<String, String> headers = {};
	ProgressCallback? onSendProgress;
	ProgressCallback? onReceiveProgress;
	List<FormDataItem> formDataItems = [];
	Options options = Options(
		method: 'GET',
		receiveDataWhenStatusError: true,// if true: error section in interceptors has body
		responseType: ResponseType.plain,
		//sendTimeout: ,
		//receiveTimeout: ,
	);

	HttpItem({this.fullUrl = ''});

	String? get method => options.method;

	set method (String? m) {options.method = m;}

	/*set pathSection (String? p) {
		if(p.toString().startsWith(RegExp('^/?http.*', caseSensitive: false))) {
		  fullUrl = UrlHelper.resolveUri(p);
		}
		else {
		  _pathSection = p;
		}
	}*/

	void addPathQuery(String key, dynamic value){
		queries[key] = value;
	}

	void addPathQueryAsMap(Map<String, dynamic> map){
		for(var kv in map.entries) {
		  queries[kv.key] = kv.value;
		}
	}

	/// response receive chunk chunk,  Response<ResponseBody> Stream<Uint8List>
	void setResponseIsStream(){
		options.responseType = ResponseType.stream;
	}

	/// response not convert to string, is List<int>
	void setResponseIsBytes(){
		options.responseType = ResponseType.bytes;
	}

	void setResponseIsPlain(){
		options.responseType = ResponseType.plain;
	}

	void setBody(String value){
		body = value;
	}

	void setBodyJson(Map js){
		body = system_convert.json.encode(js);
	}

	List? _getFormField(){
		if(body is! FormData) {
			return null;
		}

		return (body as FormData).fields;
	}

	void clearFormField(){
		formDataItems.clear();
		_getFormField()?.clear();
	}

	void addFormField(String key, String value){
		if(body is! FormData) {
			body = FormData();
		}

		_getFormField()!.add(MapEntry(key, value));
	}

	void addFormFile(String partName, String fileName, File file){
		if(body is! FormData) {
			body = FormData();
		}

		final itm = FormDataItem();
		itm.partName = partName;
		itm.fileName = fileName;
		itm.filePath = file.path;

		formDataItems.add(itm);
	}

	void addFormBytes(String partName, String dataName, List<int> bytes){
		if(body is! FormData) {
			body = FormData();
		}

		final itm = FormDataItem();
		itm.partName = partName;
		itm.fileName = dataName;
		itm.bytes = bytes;

		formDataItems.add(itm);
	}

	void addFormStream(String partName, String dataName, Stream<List<int>> stream, int size){
		if(body is! FormData) {
			body = FormData();
		}

		final itm = FormDataItem();
		itm.partName = partName;
		itm.fileName = dataName;
		itm.stream = stream;
		itm.streamSize = size;

		formDataItems.add(itm);
	}

	void prepareMultiParts(){
		if(body is! FormData) {
			return;
		}

		final newBody = FormData();
		final oldBody = body as FormData;

		/// copy Fields
		for(final f in oldBody.fields){
			newBody.fields.add(f);
		}

		/// add Files
		for(final fd in formDataItems){
			if(fd.filePath != null){
				final m = MultipartFile.fromFileSync(fd.filePath!, filename: fd.fileName, contentType: fd.contentType);
				newBody.files.add(MapEntry(fd.partName, m));
			}
			else if(fd.bytes != null){
				final m = MultipartFile.fromBytes(fd.bytes!, filename: fd.fileName, contentType: fd.contentType);
				newBody.files.add(MapEntry(fd.partName, m));
			}
			else {
				final m = MultipartFile.fromStream(() => fd.stream!, fd.streamSize!, filename: fd.fileName, contentType: fd.contentType);
				newBody.files.add(MapEntry(fd.partName, m));
			}
		}

		body = newBody;
	}
}
///========================================================================================================
class FormDataItem {
	late String partName;
	late String fileName;
	String? filePath;
	int? streamSize;
	List<int>? bytes;
	Stream<List<int>>? stream;
	MediaType contentType = MediaType.parse('application/octet-stream');

	FormDataItem();
}
