import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_websocket/iris_websocket.dart';

import 'package:app/services/login_service.dart';
import 'package:app/structures/models/settingsModel.dart';
import 'package:app/system/httpCodes.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/netListenerTools.dart';
import 'package:app/tools/routeTools.dart';

class WebsocketService {
	WebsocketService._();

	static GetSocket? _ws;
	static String? _uri;
	static bool _isConnected = false;
	static bool canReconnectState = true;
	static Duration reconnectInterval = const Duration(seconds: 6);
	static Timer? periodicHeartTimer;
	static Timer? reconnectTimer;
	static final List<void Function(dynamic data)> _receiverListeners = [];
	//static StreamController _streamCtr = StreamController.broadcast();
	//static Stream get stream => _streamCtr.stream;

	static String? get address => _uri;
	static bool get isConnected => _isConnected;

	static void addMessageListener(void Function(dynamic data) fun){
		//return stream.listen(fun);
		if(!_receiverListeners.contains(fun)) {
		  _receiverListeners.add(fun);
		}
	}

	static void removeMessageListener(void Function(dynamic data) fun){
		//return stream.listen(fun);
		_receiverListeners.remove(fun);
	}

	static Future<void> prepareWebSocket(String uri) async{
		_uri = uri;
		_isConnected = false;
		//await PublicAccess.logger.logToAll('@@@@@@@@@ ws: isConnected:$isConnected');//todo

		try {
				_ws?.close(1000); //status.normalClosure
		}
		catch(e){/**/}

		connect();
	}

	static void connect() async {
		if(isConnected) {
			return;
		}

		try {
			_ws = GetSocket(_uri!);

			_ws!.onOpen(_onConnected);
			/// onData
			_ws!.onMessage(_handlerNewMessage);

			_ws!.onClose((c) {
				_onDisConnected();
			});

			_ws!.onError((e) {
				_onDisConnected();
			});

			_ws!.connect();
		}
		catch(e){
			_onDisConnected();
		}
	}

	static void _reconnect([Duration? delay]){
		if(canReconnectState) {
			reconnectTimer?.cancel();

			reconnectTimer = Timer(delay?? reconnectInterval, () {
				if(AppBroadcast.isNetConnected) {
					connect();
				}
			});

			var temp = reconnectInterval.inSeconds;
			temp = min<int>((temp * 1.3).floor(), 600);
			reconnectInterval = Duration(seconds: temp);
		}
	}

	static void shutdown(){
		_isConnected = false;
		_ws?.close();
		periodicHeartTimer?.cancel();
	}

	static void sendData(dynamic data){
		_ws!.send(data);
	}
	///-------------- on disConnect -----------------------------------------------------------
	static void _onDisConnected() async{
		_isConnected = false;
		//await PublicAccess.logger.logToAll('@@@@@@@@@ ws: is ok:$isConnected');//todo
		periodicHeartTimer?.cancel();

		NetListenerTools.onWsDisConnectedListener();

		_reconnect();
	}
	///-------------- on new Connect -----------------------------------------------------------
	static void _onConnected() async {
		_isConnected = true;
		//await PublicAccess.logger.logToAll('@@@@@@@@@ ws: is ok:$isConnected');//todo
		reconnectInterval = const Duration(seconds: 6);

		sendData(JsonHelper.mapToJson(PublicAccess.getHeartMap()));
		NetListenerTools.onWsConnectedListener();

		periodicHeartTimer?.cancel();
		periodicHeartTimer = Timer.periodic(Duration(minutes: SettingsModel.webSocketPeriodicHeartMinutes), (timer) {
			sendHeartAndUsers();
		});
	}
	///------------ heart every 3 min ---------------------------------------------------
	static void sendHeartAndUsers() {
		final heart = PublicAccess.getHeartMap();

		try {
			sendData(JsonHelper.mapToJson(heart));
		}
		catch(e){
			_isConnected = false;
			periodicHeartTimer?.cancel();
			_reconnect(const Duration(seconds: 3));
		}
	}




	///-------------- onNew Ws Message -----------------------------------------------------------
	static void _handlerNewMessage(dynamic dataAsJs) async{
		try {
			final receiveData = dataAsJs.toString();

			if(!Checker.isJson(receiveData)) {
				return;
			}

			final js = JsonHelper.jsonToMap<String, dynamic>(receiveData)!;
			/// section: UserData, Command, none
			final String section = js[Keys.section]?? 'none';
			final String command = js[Keys.command]?? '';
			final userId = js[Keys.userId]?? 0;
			final data = js[Keys.data];
			//--------------------------------------------------
			if(section == HttpCodes.sec_command || section == 'none') {
				switch (command) {
					case HttpCodes.com_messageForUser:
						messageForUser(js);
						break;
					case HttpCodes.com_dailyText:
						dailyText(js);
						break;
					case HttpCodes.com_forceLogOff:
						// ignore: unawaited_futures
						LoginService.forceLogoff(userId);
						break;
					case HttpCodes.com_forceLogOffAll:
						// ignore: unawaited_futures
						LoginService.forceLogoffAll();
						break;
					case HttpCodes.com_talkMeWho:
						sendData(JsonHelper.mapToJson(PublicAccess.getHeartMap()));
						break;
					case HttpCodes.com_sendDeviceInfo:
						sendData(JsonHelper.mapToJson(DeviceInfoTools.getDeviceInfo()));
						break;
				}
			}
			//--------------------------------------------------
			if(section == HttpCodes.sec_userData){
				userDataSection(command, data, userId, js);
			}

			// ignore: unawaited_futures
			Future((){
				for(var f in _receiverListeners){
					f.call(js);
				}
			});
		}
		catch(e){}
	}

	static void userDataSection(String command, Map<String, dynamic> data, int userId, Map js) async {
		/// new profile =======================
		if(command == HttpCodes.com_updateProfileSettings) {
			await SessionService.newProfileData(data);
		}
	}

	static void messageForUser(Map js) async {
		final userId = js[Keys.userId];
		final data = js[Keys.data];
		final message = data['message'];
		final messageId = data['message_id'];

		if(userId != null && userId != SessionService.getLastLoginUser()?.userId){
			return;
		}

		final ids = AppDB.fetchAsList(Keys.setting$userMessageIds);

		if(!ids.contains(messageId)) {
			if(RouteTools.materialContext != null) {
				_promptDialog(RouteTools.getTopContext()!, message);
				AppDB.addToList(Keys.setting$userMessageIds, messageId);
			}
		}
	}

	static void dailyText(Map js) async {
		final data = js[Keys.data];
		final message = data['message'];
		final title = data['title'];
		final messageId = data['id'];

		final ids = AppDB.fetchAsList(Keys.setting$dailyTextIds);

		if(!ids.contains(messageId)) {
			_promptNotification(title, message);
			AppDB.addToList(Keys.setting$dailyTextIds, messageId);
		}
	}

	static _promptDialog(BuildContext context, String msg){
		AppDialogIris.instance.showIrisDialog(
				context,
				yesText: AppMessages.yes,
				desc: msg,
		);
	}

	static _promptNotification(String? title, String msg){
		AppNotification.sendNotification(title, msg);
	}
}
