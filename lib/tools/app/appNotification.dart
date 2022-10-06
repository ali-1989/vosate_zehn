import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:iris_tools/api/generator.dart';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';
import '/constants.dart';
import '/models/notificationModel.dart' as nm;

// https://github.com/rafaelsetragni/awesome_notifications/blob/master/example/lib/utils/notification_util.dart

class AppNotification {
	AppNotification._();

	static Future<void> sinkNotificationIds() async {
		await AppDB.setReplaceKv(Keys.setting$notificationChanelKey, 'C_${Generator.generateName(8)}');
		await AppDB.setReplaceKv(Keys.setting$notificationChanelGroup, 'CG_${Generator.generateName(8)}');

		return;
	}

	static String? fetchChannelKey(){
		return AppDB.fetchKv(Keys.setting$notificationChanelKey);
	}

	static nm.NotificationModel fetchNotificationModel(){
		return nm.NotificationModel.fromMap(AppDB.fetchKv(Keys.setting$notificationModel));
	}

	static Future saveNotificationModel(nm.NotificationModel model){
		return AppDB.setReplaceKv(Keys.setting$notificationModel, model.toMap());
	}

	static Future<bool> initial() async {
		var ch = fetchChannelKey();

		if(ch == null){
			await AppNotification.sinkNotificationIds();
			ch = fetchChannelKey();
		}
		else {
			AwesomeNotifications().removeChannel(ch);
		}

		final lastNotifyModel = fetchNotificationModel();

		AwesomeNotifications().initialize(
			/// drawable/app_icon.png   or   mipmap-hdpi/ic_launcher.png       resource://drawable/app_icon
			null, //'resource://drawable/app_icon.png'
			[
					NotificationChannel(
          channelGroupKey: AppDB.fetchKv(Keys.setting$notificationChanelGroup),
          channelKey: ch?? '',
          channelName: lastNotifyModel.name,
          channelDescription: Constants.appName,
          defaultColor: lastNotifyModel.defaultColor,
          ledColor: lastNotifyModel.ledColor,
          defaultPrivacy: lastNotifyModel.isPublic? NotificationPrivacy.Public : NotificationPrivacy.Private,
          importance: lastNotifyModel.importanceIsHigh? NotificationImportance.High : NotificationImportance.Default,
          enableLights: lastNotifyModel.enableLights,
          enableVibration: lastNotifyModel.enableVibration,
          playSound: lastNotifyModel.playSound,
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
				debug: false,
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
					channelKey: fetchChannelKey(),
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
			//PublicAccess.logger.logToFile('tap notification  id: ${receivedNotification.id} ');
		});
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
						channelKey: fetchChannelKey()?? '',
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
				channelKey: fetchChannelKey()?? '',
				title: title,
				summary: user,
				autoDismissible: true,
				category: NotificationCategory.Email,
				notificationLayout: NotificationLayout.Inbox,
				body: message,
				//largeIcon: largeIcon,
				//customSound: 'resource://raw/res_morph_power_rangers'
			),
		);

		/*
		'<b> 10.000 visitor! Congratz!</b> You just won our prize'
						'\n'
						'<b>Want to loose weight?</b> Are you tired from false advertisements? '
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'\n'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
						'<b>READ MY MESSAGE</b> Stop to ignore me!'
		 */
	}
}
