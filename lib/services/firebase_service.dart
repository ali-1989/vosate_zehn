import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _fbMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //showFlutterNotification(message);
}

class FireBaseService {
  FireBaseService._();

  static Future init() async {
    await Firebase.initializeApp();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_fbMessagingBackgroundHandler);
    setListening();
  }

  static void setListening(){
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print(event.notification!.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
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
    'via': 'FlutterFire Cloud Messaging!!!',
    'count': messageCount.toString(),
    };

    js['notification'] = {
    'title': 'Hello FlutterFire!',
    'body': 'This notification (#$messageCount) was created via FCM!',
    };

    return js;
  }
}