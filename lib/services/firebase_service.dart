import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iris_tools/api/logger/reporter.dart';

Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  PublicAccess.logger.logToFile('_fbMessagingBackgroundHandler: ${message.notification!.body}');
  //showFlutterNotification(message);
}
///================================================================================================
class FireBaseService {
  FireBaseService._();

  static Future init() async {
    await Firebase.initializeApp();

    FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);
    setListening();
  }

  static void setListening(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppNotification.sendNotification(message.notification!.title, message.notification!.body!);

      PublicAccess.logger.logToFile('onMessage [sendNotification]: ${message.notification!.title}');
      PublicAccess.reporter.addReport(Report()..description = '${message.notification!.body}'..type = ReportType.appInfo);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PublicAccess.logger.logToFile('onMessageOpenedApp: ${message.notification!.body}');
      PublicAccess.reporter.addReport(Report()..description = 'onMessageOpenedApp'..type = ReportType.appInfo);
    });
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
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