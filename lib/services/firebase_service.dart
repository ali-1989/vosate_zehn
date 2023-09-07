import 'dart:isolate';

import 'package:app/tools/log_tools.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appNotification.dart';

// https://firebase.google.com/docs/cloud-messaging/flutter/receive
// https://firebase.google.com/docs/cloud-messaging/flutter/client

@pragma('vm:entry-point')
Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  /// firebase it self sending a notification

  // this is runs in its own isolate outside your applications context,
  // and can, perform logic such as HTTP requests,
  // perform IO operations (e.g. updating local storage),
  // communicate with other plugins


  //await Firebase.initializeApp();
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
///================================================================================================
class FireBaseService {
  static String? token;
  static DateTime? lastUpdateToken;

  FireBaseService._();

  static Future<void> initializeApp() async {
    try {
      if(kIsWeb){
        final firebaseOptions = const FirebaseOptions(
          appId: '1:731359726004:web:7b371dd04042f69cb20ae1',
          apiKey: 'AIzaSyC2gsyD1HYpP6LwXws6hZc_PTFoK68rl8c',
          projectId: 'vosate-zehn-7d8fe',
          messagingSenderId: '731359726004',
          measurementId: 'G-8ZKZGGLXRW',
        );

        await Firebase.initializeApp(options: firebaseOptions);
        return;
      }

      final firebaseOptions = const FirebaseOptions(
        appId: '1:731359726004:android:fbbd8cd236c4fc31b20ae1',
        apiKey: 'AIzaSyBVuGcqQFjUl1t5mIUJ04rfr9EKkDRqYxM',
        projectId: 'vosate-zehn-7d8fe',
        messagingSenderId: '731359726004',
        measurementId: 'G-8ZKZGGLXRW',
      );
      LogTools.logger.logToAll('@@@@@@@@@: A- start initialize fire ${Isolate.current.hashCode}'); //todo.
      try {
        await Firebase.initializeApp(options: firebaseOptions).catchError((e){
          LogTools.logger.logToAll('@@@@@@@@@: e1e -$e  ${Isolate.current.hashCode}'); //todo.
          return null;
        });
      }
      catch (e){
        LogTools.logger.logToAll('@@@@@@@@@: e2e -$e  ${Isolate.current.hashCode}'); //todo.
      }
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
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      /// https://firebase.google.com/docs/cloud-messaging/flutter/client#prevent-auto-init
      //FirebaseMessaging.instance.setAutoInitEnabled(false);

      setListening();
      LogTools.logger.logToAll('@@@@@@@@@: set listener ${Isolate.current.hashCode}'); //todo.

      Future.delayed(const Duration(seconds: 3), (){
        getToken();
      });
    }
    catch (e){/**/}
  }

  static void setListening() async {
    /// it's fire when app is open and is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     _onNewNotification(message);
    });

    /// it's fire when app is be in background or is was terminated
    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      token = fcmToken;
      EventNotifierService.notify(AppEvents.firebaseTokenReceived);
      subscribeToTopic(ApiManager.fcmTopic);
    });

    /// it's fire when be click on Fcm notification. (no notification by app)
    FirebaseMessaging.onMessageOpenedApp.listen(_handler);

    ///When app is opened by the user touch (not by the notification), and there is a Fcm notification in the statusbar
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handler(initialMessage);
    }
  }

  static void _handler(RemoteMessage message) {
    //if (message.data['type'] == 'chat') {}
  }

  static Future<String?> getTokenForce() async {
    LogTools.logger.logToAll('@@@@@@@@@: start get token ${Isolate.current.hashCode}'); //todo.

    token = await FirebaseMessaging.instance.getToken(vapidKey: 'BLkHyiaxrQJA7eSDwjrCos0BcsGVPjxM8JGXJ1CFBAeFa2wNGoJDGkOJu6CqsPhjwhf2_EII8SoJmos0TqMOitE');
    LogTools.logger.logToAll('@@@@@@@@@: token: $token'); //todo.
    if(token != null) {
      lastUpdateToken = DateHelper.getNow();
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
    final messageCount = 0;

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
}
