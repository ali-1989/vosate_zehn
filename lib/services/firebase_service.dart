import 'package:app/system/initialize.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/tools/app/appNotification.dart';

Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  //_sendNotification(message);
}

Future<void> _sendNotification(RemoteMessage message) async {
  await InitialApplication.importantInit();
  //await PublicAccess.logger.logToAll('---> Notification  --- ${message.notification?.body}');//todo
  await InitialApplication.launchUpInit();

  int? id;

  try{
    id = message.data['id'];
  }
  catch (e){}

  final ids = AppDB.fetchAsList(Keys.setting$dailyTextIds);

  if(!ids.contains(id)) {
    if(SettingsManager.settingsModel.notificationDailyText) {
      AppNotification.sendNotification(message.notification!.title, message.notification!.body!);
    }

    AppDB.addToList(Keys.setting$dailyTextIds, id?? 0);
  }
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

    await Firebase.initializeApp();//options: firebaseOptions

    setListening();

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
    catch (e){/**/}

    ///When there is a notification in the statusbar and the app is opened by the user's click, not by the notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      //print('=================== ${initialMessage.notification?.body} ');//todo
    }
  }

  static void setListening(){
    /// it's fire when app is open and in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     _sendNotification(message);
    });

    /// it's fire when be click on Fcm notification. (no notification that app sent)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

    /// it's fire when app is be in background or is was terminated
    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);
    //FirebaseMessaging.instance.setAutoInitEnabled(false);
  }

  static Future<String?> getTokenForce() async {
    token = await FirebaseMessaging.instance.getToken();
    //PublicAccess.logger.logToAll(' token ==> $token'); //todo
    final gd = GregorianDate();
    gd.moveLocalToUTC();

    lastUpdateToken = gd.convertToSystemDate();

    return token;
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

  static Future<void> sendPushMessage() async {
    try {
      //body: constructFCMPayload(_token);
    }
    catch (e) {/**/}
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
}
