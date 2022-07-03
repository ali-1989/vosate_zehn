import 'dart:typed_data';

import 'package:iris_tools/api/generator.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/tools/app/appDb.dart';

import '/constants.dart';
import '/models/notificationModel.dart' as nm;
import 'package:awesome_notifications/awesome_notifications.dart';

// https://github.com/rafaelsetragni/awesome_notifications/blob/master/example/lib/utils/notification_util.dart

class AppNotification {
	AppNotification._();

	static String getChannelKey(){
		return AppDB.fetchKv(Keys.setting$notificationChanelKey);
	}

	static nm.NotificationModel getNotificationModel(){
		return nm.NotificationModel.fromMap(AppDB.fetchKv(Keys.setting$notificationModel));
	}

	static Future saveNotificationModel(nm.NotificationModel model){
		return AppDB.setReplaceKv(Keys.setting$notificationModel, model.toMap());
	}

	static Future<bool> initial() async {
		AwesomeNotifications().removeChannel(getChannelKey());
		final highModel = getNotificationModel();

		AwesomeNotifications().initialize(
			/// android\app\src\main\res\drawable\app_icon.png   or   ic_launcher.png
				null,// 'resource://drawable/res_app_icon',
				[
					NotificationChannel(
          channelGroupKey: AppDB.fetchKv(Keys.setting$notificationChanelGroup),
          channelKey: getChannelKey(),
          channelName: highModel.name,
          channelDescription: Constants.appName,
          defaultColor: highModel.defaultColor,
          ledColor: highModel.ledColor,
          defaultPrivacy: highModel.isPublic? NotificationPrivacy.Public : NotificationPrivacy.Private,
          importance: highModel.importanceIsHigh? NotificationImportance.High : NotificationImportance.Default,
          enableLights: highModel.enableLights,
          enableVibration: highModel.enableVibration,
          playSound: highModel.playSound,
					//soundSource: ,
          vibrationPattern: getVibration(),
          ledOnMs: 500,
          ledOffMs: 500,
        )
      ],
				/*channelGroups: [
					NotificationChannelGroup(
							channelGroupkey: 'basic_channel_group',
							channelGroupName: 'Basic group')
				],*/
				debug: true,
		);

		requestPermission();
		return true;
	}

	static Int64List getVibration() {
		final vibrationPattern = Int64List(4);
		vibrationPattern[0] = 0;
		vibrationPattern[1] = 100;
		vibrationPattern[2] = 0;
		vibrationPattern[3] = 0;

		return vibrationPattern;
	}

	static void requestPermission() {
		AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
			if (!isAllowed) {
				AwesomeNotifications().requestPermissionToSendNotifications(
					channelKey: getChannelKey(),
					permissions: [
						NotificationPermission.Alert,
						NotificationPermission.Sound,
						NotificationPermission.Badge,
						NotificationPermission.Vibration,
						NotificationPermission.Light,
						NotificationPermission.PreciseAlarms, // allows the scheduled notifications to be displayed at the expected time
						NotificationPermission.FullScreenIntent, // pop up even if the user is using another app
					]
				);
			}
		});
	}

	static void startListenTap() {
		AwesomeNotifications().actionStream.listen((ReceivedNotification receivedNotification){
			//receivedNotification.id , payload
				}
		);
	}

	static void dismissAll() {
		AwesomeNotifications().dismissAllNotifications();
	}

	static void dismissById(int nId) {
		AwesomeNotifications().dismiss(nId);
	}

	static void dismissByChannel(String channel) {
		AwesomeNotifications().dismissNotificationsByChannelKey(channel);
	}

	static void showNotificationSettingPage() {
		AwesomeNotifications().showNotificationConfigPage();
	}

	static void sendNotification(String? title, String text, {int? id}) {
		AwesomeNotifications().createNotification(
				content: NotificationContent(
						id: id ?? Generator.generateIntId(5),
						channelKey: getChannelKey(),
						title: title,
						body: text,
					autoDismissible: true,
					category: NotificationCategory.Message,
					notificationLayout: NotificationLayout.Default,
				),
		);
	}

	static void sendMessagesNotification(String? title, String user, String message, {int? id}) {
		AwesomeNotifications().createNotification(
			content: NotificationContent(
				id: id ?? Generator.generateIntId(5),
				channelKey: getChannelKey(),
				title: title,
				summary: user,
				autoDismissible: true,
				category: NotificationCategory.Email,
				notificationLayout: NotificationLayout.Inbox,
				body: '<b> 10.000 visitor! Congratz!</b> You just won our prize'
						'\n'
						'<b>Want to loose weight?</b> Are you tired from false advertisements? '
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'<b>READ MY MESSAGE</b> Stop to ignore me!',
				//largeIcon: largeIcon,
				//customSound: 'resource://raw/res_morph_power_rangers'
			),
		);
	}
}
