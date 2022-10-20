import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/tools/app/appNotification.dart';

Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  _sendNotification(message);
}

Future<void> _sendNotification(RemoteMessage message) async {
  final id = message.data['id'];

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

    await Firebase.initializeApp(options: firebaseOptions);

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

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _sendNotification(initialMessage);
    }
  }

  static void setListening(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     _sendNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _sendNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);
  }

  static Future<String?> getTokenForce() async {
    token = await FirebaseMessaging.instance.getToken();
    //PublicAccess.logger.logToAll('fcm token ============> $token');
    final gd = GregorianDate();
    gd.moveLocalToUTC();

    lastUpdateToken = gd.convertToSystemDate();

    return token;
  }

  static Future<String?> getToken() async {
    if(token == null || lastUpdateToken == null){
      return getTokenForce();
    }

    if(DateHelper.isPastOf(lastUpdateToken, Duration(minutes: 30))){
      return getTokenForce();
    }

    return token;
  }

  static Future<void> subscribeToTopic(String name) async {
    return FirebaseMessaging.instance.subscribeToTopic(name);
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
