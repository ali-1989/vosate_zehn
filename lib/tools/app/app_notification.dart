import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/structures/models/notification_settings_model.dart';
import 'package:app/system/constants.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_decoration.dart';

// icon generator:
// https://romannurik.github.io/AndroidAssetStudio/icons-notification.html#source.type=image&source.space.trim=1&source.space.pad=0&name=notif

///---------------------------------------------------------------------
/*@pragma('vm:entry-point')
Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
}

/// Use this method to detect every time that a new notification is displayed
@pragma('vm:entry-point')
Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
}

/// Use this method to detect if the user dismissed a notification
@pragma('vm:entry-point')
Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
}

/// Use this method to detect when the user taps on a notification or action button
@pragma('vm:entry-point')
Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {

}*/

@pragma('vm:entry-point')
Future<void> awesomeTapListener(ReceivedAction action){
	if(action.payload is Map){
		final key = action.payload!['key'];

		if(key == 'message'){ // send from firebase-service
			//AppBroadcast.layoutPageKey.currentState?.gotoPage(3);
			//RouteTools.backToRoot(RouteTools.getBaseContext()!);
		}
	}

	return Future.value();
}

///=============================================================================
class AppNotification {
	AppNotification._();

	static NotificationSettingsModel fetchNotificationSettingModel(){
		return NotificationSettingsModel.fromMap(AppDB.fetchKv(Keys.setting$notificationModel));
	}

	static Future saveNotificationModel(NotificationSettingsModel model){
		return AppDB.setReplaceKv(Keys.setting$notificationModel, model.toMap());
	}

	static Future<bool> initial() async {
		await AppDB.init();
		final defaultNotifySetting = fetchNotificationSettingModel();
		saveNotificationModel(defaultNotifySetting);

		await requestPermission();

		if(System.isAndroid()){
			final nc1 = NotificationChannel(
				channelKey: defaultNotifySetting.channelId,
				channelGroupKey: defaultNotifySetting.groupId,
				channelName: defaultNotifySetting.channelId,
				channelDescription: Constants.appName,
				defaultColor: defaultNotifySetting.defaultColor,
				ledColor: defaultNotifySetting.ledColor,
				defaultPrivacy: defaultNotifySetting.isPublic? NotificationPrivacy.Public : NotificationPrivacy.Private,
				importance: defaultNotifySetting.importance.getImportance(),
				enableLights: defaultNotifySetting.enableLights,
				enableVibration: defaultNotifySetting.enableVibration,
				playSound: defaultNotifySetting.playSound,
				//soundSource: ,
				vibrationPattern: getVibration(),
				ledOnMs: 500,
				ledOffMs: 500,
			);

			///* resource://drawable/firebase_icon
			AwesomeNotifications().initialize(
				'resource://drawable/firebase_icon',
				[nc1],
				debug: false,
			);
		}
		else {
			AwesomeNotifications().initialize(
				null, [],
				debug: false,
			);
		}

		return true;
	}

	static Future<void> requestPermission() async {
		try {
			final isAllowed = await AwesomeNotifications().isNotificationAllowed();

			if (!isAllowed) {
				final defaultNotifySetting = fetchNotificationSettingModel();

				AwesomeNotifications().requestPermissionToSendNotifications(
						channelKey: defaultNotifySetting.channelId,
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
		}
		catch (e){/**/}
	}

	static Int64List getVibration() {
		final vibrationPattern = Int64List(4);
		vibrationPattern[0] = 0;
		vibrationPattern[1] = 100;
		vibrationPattern[2] = 0;
		vibrationPattern[3] = 0;

		return vibrationPattern;
	}

	static void startListenTap() {
		//AwesomeNotifications().actionStream.listen(awesomeTapListener);

		AwesomeNotifications().setListeners(
				onActionReceivedMethod: awesomeTapListener,
				//onNotificationCreatedMethod: ,
				//onNotificationDisplayedMethod: ,
				//onDismissActionReceivedMethod:
		);
	}

	static void removeChannel(String channelKey) {
		AwesomeNotifications().removeChannel(channelKey);
	}

	static void updateChannel(NotificationChannel channel) {
		AwesomeNotifications().setChannel(channel, forceUpdate: true);
	}

	static void dismissAllNotifications() {
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

	static void sendNotification(String? title, String text, {int? id, Map<String, String>? payload}) {
		final defaultNotifySetting = fetchNotificationSettingModel();

		final n = NotificationContent(
			id: id ?? Generator.generateIntId(5),
			channelKey: defaultNotifySetting.channelId,
			title: title,
			body: text,
			autoDismissible: true,
			color: AppDecoration.orange,
			category: NotificationCategory.Message,
			notificationLayout: NotificationLayout.Default,
			payload: payload,
		);

		AwesomeNotifications().createNotification(
				content: n,
		);
	}

	static void sendMessagesNotification(String? title, String user, String message, {int? id}) {
		final defaultNotifySetting = fetchNotificationSettingModel();

		AwesomeNotifications().createNotification(
			content: NotificationContent(
				id: id ?? Generator.generateIntId(5),
				channelKey: defaultNotifySetting.channelId,
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
