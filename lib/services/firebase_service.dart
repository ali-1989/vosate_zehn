import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/services/firebase_options.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_notification.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/sentences_page.dart';

// https://firebase.google.com/docs/cloud-messaging/flutter/receive
// https://firebase.google.com/docs/cloud-messaging/flutter/client

@pragma('vm:entry-point')
Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  /// firebase it self sending this notification. no need me.

  // this is runs in its own isolate outside your applications context,
  // and can, perform logic such as HTTP requests,
  // perform IO operations (e.g. updating local storage),
  // communicate with other plugins


  //await ApplicationInitial.prepareDirectoriesAndLogger();
  //await ApplicationInitial.inSplashInit();
}

Future<void> _onNewNotification(RemoteMessage message) async {
  int? id;

  try{
    id = message.data['id'];

    final ids = AppDB.fetchAsList(Keys.setting$dailyTextIds);

    if(!ids.contains(id)) {
      if (SettingsManager.localSettings.notificationDailyText) {
        AppNotification.sendNotification(message.notification!.title, message.notification!.body!);
      }

      AppDB.addToList(Keys.setting$dailyTextIds, id ?? 0);
    }
  }
  catch (e){/**/}
}
///=============================================================================
class FireBaseService {
  static String? token;
  static DateTime? lastUpdateToken;

  FireBaseService._();

  static Future<void> initializeApp() async {
    try {
      FirebaseOptions options;

      if(kIsWeb){
        options = DefaultFirebaseOptions.web;
      }
      else if(System.isAndroid()){
        options = DefaultFirebaseOptions.android;
      }
      else {
        options = DefaultFirebaseOptions.currentPlatform;
      }

      await Firebase.initializeApp(options: options)
          .then<FirebaseApp?>((v) => v).catchError((e){
        LogTools.logger.logToAll('@@@@@@@@@: e1e -$e  ${Isolate.current.hashCode}'); //todo.
        return null;
      });

      LogTools.logger.logToAll('@@@@@@@@@: B - Ok ${Isolate.current.hashCode}'); //todo.
    }
    catch (e){/**/}
  }

  static Future start() async {
    //FirebaseMessaging.instance.isSupported()
    LogTools.logger.logToAll('@@@@@@@@@: start fire ${Isolate.current.hashCode}'); //todo.

    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      ///----- ios
      /*NotificationSettings*/
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      /// https://firebase.google.com/docs/cloud-messaging/flutter/client#prevent-auto-init
      //FirebaseMessaging.instance.setAutoInitEnabled(false);

      setListening();

      Future.delayed(const Duration(seconds: 3), (){
        getToken();
      });
    }
    catch (e){/**/}
  }

  static void setListening() async {
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenListen);

    /// it's fire when app is open and is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     _onNewNotification(message);
    });

    /// it's fire when app is be in background or is was terminated
    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);

    /// it's fire when be click on Fcm notification. (no notification by app)
    FirebaseMessaging.onMessageOpenedApp.listen(_handlerTouchFcmNotification);

    ///When app is opened by the user touch (not by the notification), and there is a Fcm notification in the statusbar
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handlerOpenAppWhenExistNotification(initialMessage);
    }
  }

  static void _onTokenListen(fcmToken) {
    token = fcmToken;
    subscribeToTopic(ApiManager.fcmTopic);
    EventNotifierService.notify(AppEvents.firebaseTokenReceived);
  }

  static void _handlerTouchFcmNotification(RemoteMessage message) {
    Future.delayed(const Duration(seconds: 1), (){
      RouteTools.pushPage(RouteTools.materialContext!, const SentencesPage());
    });

    _addMessageId(message);
  }

  static void _handlerOpenAppWhenExistNotification(RemoteMessage message) {
    Future.delayed(const Duration(seconds: 1), (){
      RouteTools.pushPage(RouteTools.materialContext!, const SentencesPage());
    });

    _addMessageId(message);
    //if (message.data['type'] == 'chat') {}
  }

  static Future<String?> getTokenForce() async {
    LogTools.logger.logToAll('@@@@@@@@@: start get token ${Isolate.current.hashCode}'); //todo.

    token = await FirebaseMessaging.instance.getToken(vapidKey: DefaultFirebaseOptions.fcmKey);
    LogTools.logger.logToAll('@@@@@@@@@: token: $token'); //todo.
    if(token != null) {
      lastUpdateToken = DateHelper.now();
      EventNotifierService.notify(AppEvents.firebaseTokenReceived);

      return token;
    }
    else {
      EventNotifierService.addListener(AppEvents.networkConnected, _onNetConnected);
      return null;
    }
  }

  static Future<String?> getToken() async {
    if(token == null || lastUpdateToken == null){
      return getTokenForce();
    }

    if(DateHelper.isPastOf(lastUpdateToken, const Duration(hours: 2))){
      return getTokenForce();
    }

    return token;
  }

  static Future<void> subscribeToTopic(String name) async {
    return FirebaseMessaging.instance.subscribeToTopic(name);
  }

  static Future<void> unsubscribeFromTopic(String name) async {
    return FirebaseMessaging.instance.unsubscribeFromTopic(name);
  }

  static Map generateMessage(String? token) {
    const messageCount = 0;

    final js = {};
    js['token'] = token;

    js['data'] = {
    'from': 'FlutterFire Cloud Messaging!!!',
    'count': messageCount.toString(),
    };

    js['notification'] = {
    'title': 'Hello FlutterFire!',
    'body': 'This notification (#$messageCount) was created via FCM!',
    };

    return js;
  }

  static void _onNetConnected({data}) {
    EventNotifierService.removeListener(AppEvents.networkConnected, _onNetConnected);
    getTokenForce();
  }

  static void _addMessageId(RemoteMessage message){
    try{
      int? id = message.data['id'];

      final ids = AppDB.fetchAsList(Keys.setting$dailyTextIds);

      if(!ids.contains(id)) {
        AppDB.addToList(Keys.setting$dailyTextIds, id ?? 0);
      }
    }
    catch (e){/**/}
  }
}
