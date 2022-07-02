import 'dart:typed_data';

import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iris_tools/notifications/localNotification/notification.dart' as notify_pkg;

import '/constants.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appThemes.dart';


// https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/lib/main.dart
//https://pub.dev/packages/awesome_notifications

class AppNotification {
	static final String _androidChannelId$Default = '123003211';
	static final String _androidChannelName$Default = '${Constants.appName} Channel 1';
	static FlutterLocalNotificationsPlugin? _handler;
	static late IOSNotificationDetails _iosNotificationDetails;
	static late AndroidNotificationDetails _androidNotificationDetails;

	AppNotification._();

	/// insert: android\app\src\main\res\drawable\app_icon.png   or   ic_launcher.png
	static Future<bool> initial() async {
		final settingsAndroid = AndroidInitializationSettings('launcher_icon'); // ic_launcher  OR   app_icon
		final settingsIOS = IOSInitializationSettings(
				requestAlertPermission: true,
				requestBadgePermission: true,
				requestSoundPermission: true,
				onDidReceiveLocalNotification: onDidReceiveNotification$iOS
		);

		final initializationSettings = InitializationSettings(android: settingsAndroid, iOS: settingsIOS);
		_handler = notify_pkg.Notification.notificationPlugin;
		await _handler!.initialize(initializationSettings, onSelectNotification: onSelectNotification);

		_prepare();

		return true;
	}

	static void _prepare() {
		final vibrationPattern = Int64List(4);
		vibrationPattern[0] = 0;
		vibrationPattern[1] = 100;
		vibrationPattern[2] = 0;
		vibrationPattern[3] = 0;

		_iosNotificationDetails = IOSNotificationDetails(
				presentAlert: true,
				presentSound: true,
				sound: 'plucky',
		);

		_androidNotificationDetails = AndroidNotificationDetails(
			_androidChannelId$Default,
			_androidChannelName$Default,
			importance: Importance.defaultImportance,
			priority: Priority.high,
			visibility: NotificationVisibility.public,
			ticker: '',
			ledColor: AppThemes.instance.currentTheme.primaryColor,
			ledOnMs: 1000,
			ledOffMs: 1000,
			vibrationPattern: vibrationPattern,
			enableVibration: true,
			enableLights: true,
			autoCancel: true,
			onlyAlertOnce: false,
			ongoing: false, // if true: fix until click on notification, can not dismiss.
			//sound: RawResourceAndroidNotificationSound('plucky'),
			//color: const Color.fromARGB(255, 255, 150, 0),
			//icon:
		);
	}

	static AndroidNotificationDetails genAndroidDetail(
		{
			AndroidNotificationDetails? base,
			String? chanelId,
			String? channelName,
			Importance? importance,
			Priority? priority,
			NotificationVisibility? visibility,
			AndroidNotificationChannelAction? channelAction,
			Int64List? vibrationPattern,
			bool? enableVibration,
			bool? enableLights,
			bool? playSound,
			bool? showProgress,
			bool? autoCancel,
			bool? onlyAlertOnce,
			bool? ongoing,
			bool? showWhen,
			bool? channelShowBadge,
			Color? ledColor,
			int? ledOnMs,
			int? ledOffMs,
			int? progress,
			int? maxProgress,
			int? when,
			int? timeoutAfter,
			String? icon,
			String? tag,
			String? ticker,
			String? category,
			AndroidBitmap<Object>? largeIcon,
			AndroidNotificationSound? sound,
			StyleInformation? styleInformation,
		}
			) {
		final AndroidNotificationDetails defaultSet = base?? _androidNotificationDetails;

		final res = AndroidNotificationDetails(
			chanelId?? defaultSet.channelId,
			channelName?? defaultSet.channelName,
			importance: importance?? defaultSet.importance,
			priority: priority?? defaultSet.priority,
			visibility: visibility?? defaultSet.visibility,
			channelAction: channelAction?? defaultSet.channelAction,
			vibrationPattern: vibrationPattern?? defaultSet.vibrationPattern,
			enableVibration: enableVibration?? defaultSet.enableVibration,
			enableLights: enableLights?? defaultSet.enableLights,
			playSound: playSound?? defaultSet.playSound,
			ledColor: ledColor?? defaultSet.ledColor,
			ledOnMs: ledOnMs?? defaultSet.ledOnMs,
			ledOffMs: ledOffMs?? defaultSet.ledOffMs,
			icon: icon?? defaultSet.icon,
			largeIcon: largeIcon?? defaultSet.largeIcon,
			showProgress: showProgress?? defaultSet.showProgress,
			progress: progress?? defaultSet.progress,
			maxProgress: maxProgress?? defaultSet.maxProgress,
			when: when?? defaultSet.when,
			showWhen: showWhen?? defaultSet.showWhen,
			timeoutAfter: timeoutAfter?? defaultSet.timeoutAfter,
			tag: tag?? defaultSet.tag,
			ticker: ticker?? defaultSet.ticker,
			sound: sound?? defaultSet.sound,
			autoCancel: autoCancel?? defaultSet.autoCancel,
			onlyAlertOnce: onlyAlertOnce?? defaultSet.onlyAlertOnce,
			ongoing: ongoing?? defaultSet.ongoing,
			category: category?? defaultSet.category,
			channelShowBadge: channelShowBadge?? defaultSet.channelShowBadge,
			styleInformation: styleInformation?? defaultSet.styleInformation,
		);

		return res;
	}

	static IOSNotificationDetails genIosDetail(
			{
				List<IOSNotificationAttachment>? attachments,
				int? badgeNumber,
				bool? presentAlert,
				bool? presentBadge,
				bool? presentSound,
				String? sound,
				String? subtitle,
				String? threadIdentifier,
			}) {
		final res = IOSNotificationDetails(
				attachments: attachments?? _iosNotificationDetails.attachments,
				badgeNumber: badgeNumber?? _iosNotificationDetails.badgeNumber,
				presentAlert: presentAlert?? _iosNotificationDetails.presentAlert,
				presentBadge: presentBadge?? _iosNotificationDetails.presentBadge,
				presentSound: presentSound?? _iosNotificationDetails.presentSound,
				sound: sound?? _iosNotificationDetails.sound,
				subtitle: subtitle?? _iosNotificationDetails.subtitle,
				threadIdentifier: threadIdentifier?? _iosNotificationDetails.threadIdentifier,
		);

		return res;
	}

	static Future<NotificationAppLaunchDetails?> checkAppLunchedByNotification() async {
		return notify_pkg.Notification.checkAppLunchedByNotification();
	}

	static Future<void> createNotificationChannel(String id, String name, String description) async {
		return notify_pkg.Notification.createNotificationChannel(id, name, description);
	}

	static Future<void> deleteNotificationChannel(String id) async {
		return notify_pkg.Notification.deleteNotificationChannel(id);
	}

	static Future<bool?>? requestIOSPermissions() {
		return notify_pkg.Notification.requestIOSPermissions();
	}

	static void changeNotificationSound(String name) {
		_androidNotificationDetails = genAndroidDetail(
				sound: RawResourceAndroidNotificationSound(name),
				channelAction: AndroidNotificationChannelAction.update
		);

		_iosNotificationDetails = genIosDetail(
				sound: name,
		);
	}

	static Future<void> showNotification(int id, String title, String message, String payload,
		{
			AndroidNotificationDetails? androidDetails,
			IOSNotificationDetails? iosDetails,
		}) async {

		final notificationDetails = NotificationDetails(
				android: androidDetails?? _androidNotificationDetails,
				iOS: iosDetails?? _iosNotificationDetails,
		);

		await _handler?.show(id, title, message, notificationDetails, payload: payload);
	}

	static Future<void> showProgressNotification(
			int id,
			int maxProgress,
			int progress,
			String title,
			String message,
			String payload,
			{
				AndroidNotificationDetails? androidDetails,
				IOSNotificationDetails? iosDetails,
			}
			) async {

		final myAndroidDetails = genAndroidDetail(
			base: androidDetails,
			channelShowBadge: false,
			playSound: false,
			onlyAlertOnce: true,
			showProgress: true,
			maxProgress: maxProgress,
			progress: progress,
		);

		final notificationDetails = NotificationDetails(
			android: myAndroidDetails,
			iOS: iosDetails?? _iosNotificationDetails,
		);

		await _handler?.show(id, title, message, notificationDetails, payload: payload);
	}

	static Future<void> showMultiMessageNotification(
			int id,
			String category,
			List<Message> messages,
			String payload,
			{
				String? title,
				AndroidNotificationDetails? androidDetails,
				IOSNotificationDetails? iosDetails,
			}
			) async {

		final messagingStyle = MessagingStyleInformation(
				messages.first.person!,
				groupConversation: true,
				htmlFormatContent: true,
				htmlFormatTitle: true,
				conversationTitle: title,
				messages: messages,
		);

		final myAndroidDetails = genAndroidDetail(
			base: androidDetails,
			category: category,
			styleInformation: messagingStyle,
		);

		final notificationDetails = NotificationDetails(
			android: myAndroidDetails,
			iOS: iosDetails?? _iosNotificationDetails,
		);

		await _handler?.show(id, null, null, notificationDetails, payload: payload);
	}

	static Future<void> showInboxNotification(
			int id,
			String summary,
			List<String> lines,
			String payload,
			{
				String? title,
				AndroidNotificationDetails? androidDetails,
				IOSNotificationDetails? iosDetails,
			}
	) async {

		final inboxStyleInformation = InboxStyleInformation(
			lines,
			htmlFormatLines: true,
			htmlFormatContent: true,
			htmlFormatContentTitle: true,
			htmlFormatSummaryText: true,
			htmlFormatTitle: true,
			contentTitle: title,
			summaryText: summary,
		);

		final myAndroidDetails = genAndroidDetail(
			base: androidDetails,
			styleInformation: inboxStyleInformation,
		);

		final notificationDetails = NotificationDetails(
			android: myAndroidDetails,
			iOS: iosDetails?? _iosNotificationDetails,
		);

		await _handler?.show(id, null, null, notificationDetails, payload: payload);
	}

	static Future<void> cancelById(int id) async {
		await _handler?.cancel(id);
	}

	static Future<void> cancelAll() async {
		await _handler?.cancelAll();
	}
	/// ---- invoke when user click on notification -----------------------------------------------
	static Future<dynamic> onSelectNotification(String? payload){
		if(payload != null) {
		  AppManager.logger.logToScreen('payload: ' + payload);
		}//todo del
		return Future<dynamic>.value('');
	}
	//---------------------------------------------------------------------------------------
	/// iOS not show notifications when app is run, use this hack
	static Future onDidReceiveNotification$iOS(int id, String? title, String? body, String? payload) async {
		// display a dialog with the notification details, tap ok to go to another page
		// ignore: unawaited_futures
		showDialog(
			context: AppRoute.materialContext,
			builder: (BuildContext context) => CupertinoAlertDialog(
				title: Text(title?? ''),
				content: Text(body?? ''),
				actions: [
					CupertinoDialogAction(
						isDefaultAction: true,
						child: Text('Ok'),
						onPressed: () async {
							Navigator.of(context, rootNavigator: true).pop();
							await Navigator.push(
								context,
								MaterialPageRoute(
									//builder: (context) => show(payload),
									builder: (context) => Center(),
								),
							);
						},
					)
				],
			),
		);
	}
}
