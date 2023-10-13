import 'package:app/tools/app/app_decoration.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:material_dialogs/material_dialogs.dart';

import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';

class AppDialog {
	static final _instance = AppDialog._();
	static bool _isInit = false;
	static late DialogDecoration _dialogTheme;

	static AppDialog get instance {
		_init();
		
		return _instance;
	}

	DialogDecoration get dialogDecoration => _dialogTheme;

	static void _init(){
		if(!_isInit){
			_prepareDialogDecoration();
			_isInit = true;
		}
	}

	AppDialog._(){
		_init();
	}

	factory AppDialog(){
		return _instance;
	}

	static void _prepareDialogDecoration(){
		_dialogTheme = DialogDecoration();

		Color textColor(){
			if(ColorHelper.isNearColor(AppThemes.instance.currentTheme.dialogBackColor, Colors.white)) {
				return Colors.black;
			}

			return Colors.white;
		}

		_dialogTheme.dimColor = ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.black,])
				? Colors.white.withAlpha(80)
				: Colors.black.withAlpha(150);
		_dialogTheme.descriptionColor = textColor();
		//_dialogDecoration.titleColor = textColor();
		_dialogTheme.titleColor = Colors.white;
		_dialogTheme.titleBackgroundColor = AppThemes.instance.currentTheme.accentColor;
		_dialogTheme.iconBackgroundColor = Colors.black;
		_dialogTheme.positiveButtonTextColor = AppThemes.instance.currentTheme.buttonTextColor;
		_dialogTheme.negativeButtonTextColor = AppThemes.instance.currentTheme.buttonTextColor;
		_dialogTheme.positiveButtonBackColor = AppDecoration.buttonBackgroundColor();
		_dialogTheme.negativeButtonBackColor = AppDecoration.buttonBackgroundColor();
	}
	///============================================================================================================
	Future showDialog(
			BuildContext context, {
				String? title,
				String? desc,
				String? yesText,
				Widget? icon,
				Function? yesFn,
				bool barrierDismissible = true,
				DialogDecoration? decoration,
				List<Widget>? actions,
			}) {

		decoration ??= AppDialog.instance.dialogDecoration;
		var topView = Dialogs.holder;

		if(icon != null){
			topView = ClipRRect(
				borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
			  child: ColoredBox(
			  		color: Colors.black87,
			  		child: SizedBox(
			  				width: double.maxFinite,
			  				child: icon
			  		),
			  ),
			);
		}

		if(yesText != null){
			actions ??= [];

			actions.add(ElevatedButton(
					onPressed: (){
						if(yesFn != null) {
							yesFn.call();
						}
						else {
							RouteTools.popTopView(context: context);
						}
					},
					child: Text(yesText)
			));
		}

		return Dialogs.materialDialog(
				color: decoration.backgroundColor,
				barrierColor: decoration.dimColor,
				msg: desc,
				title: title,
				context: context,
				barrierDismissible: barrierDismissible,
				customView: topView,
				actions: [
					...?actions
				]
		);
	}

  Future showYesNoDialog(
			BuildContext context, {
				String? desc,
				String? yesText,
				Function? yesFn,
				String? noText,
				Function? noFn,
				String? title,
				Widget? icon,
				bool dismissOnButtons = true,
				DialogDecoration?	decoration,
		}){

		return Dialogs.materialDialog(
			context: context,
			msg: desc,
			title: title,
			actions: [
				ElevatedButton(
						onPressed: (){
							yesFn?.call();
						},
						child: Text(yesText?? AppMessages.yes)
				),

				/*IconsOutlineButton(
					onPressed: () {},
					text: 'Cancel',
					iconData: Icons.cancel_outlined,
					textStyle: TextStyle(color: Colors.grey),
					iconColor: Colors.grey,
				),*/

				OutlinedButton(
						onPressed: (){
							yesFn?.call();
						},
						child: Text(noText?? AppMessages.no)
				)
			]
		);
	}

	Future showCustomDialog(
			BuildContext context,
			Widget view, {
				String? yesText,
				Function? yesFn,
				bool barrierDismissible = true,
				DialogDecoration? decoration,
				List<Widget>? actions,
			}) {

		decoration ??= AppDialog.instance.dialogDecoration;

		if(yesText != null){
			actions ??= [];

			actions.add(ElevatedButton(
					onPressed: (){
						if(yesFn != null) {
							yesFn.call();
						}
						else {
							RouteTools.popTopView(context: context);
						}
					},
					child: Text(yesText)
			));
		}

		return Dialogs.materialDialog(
				color: decoration.backgroundColor,
				barrierColor: decoration.dimColor,
				context: context,
				barrierDismissible: barrierDismissible,
				customView: view,
				actions: [
					...?actions
				]
		);
	}

	void showSuccessDialog(BuildContext context, String? title, String desc) {//shield-check, sticker-check, thump-up
		showDialog(context, title: title, desc: desc, yesText: AppMessages.ok,
				icon: Icon(AppIcons.downloadDone, size: 48, color: AppThemes.instance.currentTheme.successColor,)
		);
	}

	void showWarningDialog(BuildContext context, String? title, String desc) {
		showDialog(context, title: title, desc: desc, yesText: AppMessages.ok,
				icon: Icon(AppIcons.light, size: 48, color: AppThemes.instance.currentTheme.warningColor)
		);
	}

	void showInfoDialog(BuildContext context, String? title, String desc) { //library
		showDialog(context, title: title, desc: desc, yesText: AppMessages.ok,
				icon: Icon(AppIcons.lightBulb, size: 48, color: AppThemes.instance.currentTheme.infoColor)
		);
	}

	Future showErrorDialog(BuildContext context, String? title, String desc) { //alert, minus-circle
		return showDialog(context, title: title, desc: desc, yesText: AppMessages.ok,
				icon: Icon(AppIcons.close, size: 48, color: AppThemes.instance.currentTheme.errorColor)
		);
	}
	///============================================================================================================
	Future showDialog$NetDisconnected(BuildContext context) {
		return showErrorDialog(
			context,
			AppMessages.netConnectionIsDisconnect,
			'',
		);
	}
}
///========================================================================================
class DialogDecoration {
	ThemeData? themeData;
	Color? dimColor;
	Color backgroundColor = Colors.white;
	Color? titleColor;
	Color? descriptionColor;
	Color? positiveButtonTextColor;
	Color? positiveButtonBackColor;
	Color? negativeButtonTextColor;
	Color? negativeButtonBackColor;
	Color? iconBackgroundColor;
	Color? titleBackgroundColor;
	Color? shadowColor;
	TextStyle? titleStyle;
	TextStyle? descriptionStyle;
	TextStyle? positiveStyle;
	TextStyle? negativeStyle;
	ShapeBorder? shape;
	EdgeInsets? padding;
	EdgeInsets titlePadding = const EdgeInsets.all(10.0);
	double widthFactor = 0.8;
	double elevation = 4.0;
	double messageToButtonsSpace = 20;
	RouteTransitionsBuilder? transitionsBuilder;
	Duration animationDuration = const Duration(milliseconds: 300);

	DialogDecoration copy(){
		final res = DialogDecoration();
		res.themeData = themeData;
		res.dimColor = dimColor;
		res.backgroundColor = backgroundColor;
		res.titleColor = titleColor;
		res.descriptionColor = descriptionColor;
		res.positiveButtonTextColor = positiveButtonTextColor;
		res.positiveButtonBackColor = positiveButtonBackColor;
		res.negativeButtonBackColor = negativeButtonBackColor;
		res.negativeButtonTextColor = negativeButtonTextColor;
		res.iconBackgroundColor = iconBackgroundColor;
		res.titleBackgroundColor = titleBackgroundColor;
		res.shadowColor = shadowColor;
		res.titleStyle = titleStyle;
		res.descriptionStyle = descriptionStyle;
		res.positiveStyle = positiveStyle;
		res.negativeStyle = negativeStyle;
		res.shape = shape;
		res.padding = padding;
		res.titlePadding = titlePadding;
		res.widthFactor = widthFactor;
		res.elevation = elevation;
		res.messageToButtonsSpace = messageToButtonsSpace;
		res.transitionsBuilder = transitionsBuilder;
		res.animationDuration = animationDuration;

		return res;
	}
}

