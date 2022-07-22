import 'dart:async';
import 'dart:math';

import 'package:getsocket/getsocket.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:vosate_zehn/models/settingsModel.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/publicAccess.dart';

import '/system/httpCodes.dart';
import '/system/keys.dart';
import '/system/session.dart';

import '/tools/deviceInfoTools.dart';
import '/tools/netListenerTools.dart';

import '/tools/userLoginTools.dart';

class AppWebsocket {
	AppWebsocket._();

	static GetSocket? _ws;
	static String? _uri;
	static bool _isConnected = false;
	static bool canReconnectState = true;
	static Duration reconnectInterval = const Duration(seconds: 6);
	static Timer? periodicHeartTimer;
	static Timer? reconnectTimer;
	static final List<void Function(dynamic data)> _receiverListeners = [];
	//static StreamController _streamCtr = StreamController.broadcast();

	static String? get address => _uri;
	//static Stream get stream => _streamCtr.stream;
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

		try {
				_isConnected = false;
				_ws?.close(1000); //status.normalClosure
		}
		catch(e){/**/}

		connect();
	}

	static void connect() async {
		if(isConnected || System.isWeb()) {
			return;
		}

		try {
			_ws = GetSocket(_uri!);

			_ws!.onOpen(() {
				_onConnected();
			});

			_ws!.onClose((c) {
				_onDisConnected();
			});

			_ws!.onError((e) {
				_onDisConnected();
			});

			/// onData
			_ws!.onMessage((data) {
				_handlerNewMessage(data);
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

		if(_ws != null) {
			_ws!.close();
		}

		periodicHeartTimer?.cancel();
	}

	static void sendData(dynamic data){
		_ws!.send(data);
	}
	///-------------- on dis Connect -----------------------------------------------------------
	static void _onDisConnected() async{
		_isConnected = false;
		periodicHeartTimer?.cancel();

		NetListenerTools.onWsDisConnectedListener();

		_reconnect();
	}
	///-------------- on new Connect -----------------------------------------------------------
	static void _onConnected() async {
		_isConnected = true;
		reconnectInterval = const Duration(seconds: 6);
		sendData(JsonHelper.mapToJson(PublicAccess.getHowIsMap()));

		NetListenerTools.onWsConnectedListener();

		periodicHeartTimer?.cancel();
		periodicHeartTimer = Timer.periodic(Duration(minutes: SettingsModel.webSocketPeriodicHeart), (timer) {
			sendHeartAndUsers();
		});
	}
	///------------ heart every 4 min ---------------------------------------------------
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
			/// UserData , ChatData, TicketData, Command, none
			final String section = js[Keys.section]?? 'none';
			final String command = js[Keys.command]?? '';
			final userId = js[Keys.userId]?? 0;
			final data = js[Keys.data];
			//--------------------------------------------------
			if(section == HttpCodes.sec_command || section == 'none') {
				switch (command) {
					case HttpCodes.com_serverMessage: // from WsServerNs
						break;
					case HttpCodes.com_forceLogOff:
						// ignore: unawaited_futures
						UserLoginTools.forceLogoff(userId);
						break;
					case HttpCodes.com_forceLogOffAll:
						// ignore: unawaited_futures
						UserLoginTools.forceLogoffAll();
						break;
					case HttpCodes.com_talkMeWho:
						sendData(JsonHelper.mapToJson(PublicAccess.getHowIsMap()));
						break;
					case HttpCodes.com_sendDeviceInfo:
						sendData(JsonHelper.mapToJson(DeviceInfoTools.getDeviceInfo()));
						break;
				}
			}
			//--------------------------------------------------
			if(section == HttpCodes.sec_ticketData){
				ticketDataSec(command, data, userId, js);
			}

			if(section == HttpCodes.sec_userData){
				userDataSec(command, data, userId, js);
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

	static void ticketDataSec(String command, Map<String, dynamic> data, int userId, Map js) async {

		/// new Message =======================
		if(command == HttpCodes.com_newMessage) {
			final ticketData = js['ticket_data'];
			final mediaData = js['media_data'];
			final userData = js['user_data'];
		}
	}

	static void chatDataSec(String command, Map<String, dynamic> data, int userId, Map js) async {
		/// user Seen =======================
		if(command == HttpCodes.com_userSeen) {
			/*final senderId = data[Keys.userId];
			final conversationId = data['conversation_id'];
			final seenTs = data['seen_ts'];*/
		}

		/// new Message =======================
		else if(command == HttpCodes.com_newMessage) {
			final chatData = js['chat_data'];
			final mediaData = js['media_data'];
			final userData = js['user_data'];
		}
	}

	static void userDataSec(String command, Map<String, dynamic> data, int userId, Map js) async {
		/// new profile =======================
		if(command == HttpCodes.com_updateProfileSettings) {
			await Session.newProfileData(data);
		}
	}

	static void courseDataSec(String command, Map<String, dynamic> data, int userId, Map js) async {

	}
}
