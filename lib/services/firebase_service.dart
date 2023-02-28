import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/services/event_dispatcher_service.dart';
import 'package:app/system/applicationInitialize.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appNotification.dart';

Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  // firebase it self sending a notification
}

Future<void> _onNewNotification(RemoteMessage message) async {
  await ApplicationInitial.prepareDirectoriesAndLogger();
  await ApplicationInitial.inSplashInit();

  int? id;

  try{
    id = message.data['id'];

    final ids = AppDB.fetchAsList(Keys.setting$dailyTextIds);

    if(!ids.contains(id)) {
      if (SettingsManager.settingsModel.notificationDailyText) {
        AppNotification.sendNotification(message.notification!.title, message.notification!.body!);
      }

      AppDB.addToList(Keys.setting$dailyTextIds, id ?? 0);
    }
  }
  catch (e){}
}
///================================================================================================
class FireBaseService {
  static String? token;
  static DateTime? lastUpdateToken;

  FireBaseService._();

  static Future init() async {
    const firebaseOptions = FirebaseOptions(
      appId: '1:731359726004:android:fbbd8cd236c4fc31b20ae1',
      apiKey: 'AIzaSyBVuGcqQFjUl1t5mIUJ04rfr9EKkDRqYxM',
      projectId: 'vosate-zehn-7d8fe',
      messagingSenderId: '731359726004',
    );

    await Firebase.initializeApp(options: firebaseOptions);
    //FirebaseMessaging.instance.setAutoInitEnabled(false);

    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      /// ios
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    catch (e){}

    setListening();

    ///When there is a notification in the statusbar and the app is opened by the user, not by the notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
    }
  }

  static void setListening(){
    /// it's fire when app is open and in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     _onNewNotification(message);
    });

    /// it's fire when be click on Fcm notification. (no notification that app sent)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

    /// it's fire when app is be in background or is was terminated
    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);
  }

  static Future<String?> getTokenForce() async {
    token = await FirebaseMessaging.instance.getToken();

    if(token != null) {
      lastUpdateToken = DateHelper.getNow();
      EventDispatcherService.notify(EventDispatcher.firebaseTokenReceived);

      return token;
    }
    else {
      EventDispatcherService.attachFunction(EventDispatcher.networkConnected, _onNetConnected);
      return null;
    }
  }

  static Future<String?> getToken() async {
    if(token == null || lastUpdateToken == null){
      return getTokenForce();
    }

    if(DateHelper.isPastOf(lastUpdateToken, Duration(hours: 2))){
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
    EventDispatcherService.deAttachFunction(EventDispatcher.networkConnected, _onNetConnected);
    getTokenForce();
  }
}
