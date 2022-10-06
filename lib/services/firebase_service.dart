import 'package:app/managers/settingsManager.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  PublicAccess.logger.logToFile('fb MessagingBackgroundHandler: ${message.notification!.body}');
  _sendNotification(message);
}

Future<void> _sendNotification(RemoteMessage message) async {
  if(SettingsManager.settingsModel.notificationDailyText) {
    AppNotification.sendNotification(message.notification!.title, message.notification!.body!);
  }
}
///================================================================================================
class FireBaseService {
  static String? token;
  static DateTime? lastUpdateToken;

  FireBaseService._();

  static Future init() async {
    await Firebase.initializeApp();

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PublicAccess.logger.logToFile('on Fcm [initialMessage]: ${initialMessage.notification!.title}');
      _sendNotification(initialMessage);
    }

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    setListening();
  }

  static void setListening(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      PublicAccess.logger.logToFile('on Fcm [sendNotification]: ${message.notification!.title}');
      _sendNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PublicAccess.logger.logToFile('onMessageOpenedApp: ${message.notification!.body}');
    });

    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);
  }

  static Future<String?> getTokenForce() async {
    token = await FirebaseMessaging.instance.getToken();
    PublicAccess.logger.logToAll('fcm token: $token');//todo
    final gd = GregorianDate();
    gd.moveLocalToUTC();

    lastUpdateToken = gd.convertToSystemDate();

    return token;
  }

  static Future<String?> getToken() async {
    if(token == null || lastUpdateToken == null){
      return getTokenForce();
    }

    if(DateHelper.isPastOf(lastUpdateToken, Duration(hours: 1))){
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

  static Map constructFCMPayload(String? token) {
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