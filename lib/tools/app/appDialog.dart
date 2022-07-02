import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';

class AppDialog {
	static final _instance = AppDialog._();
	static bool _isInit = false;
	static late DialogDecoration _dialogDecoration;

	static AppDialog get instance {
		_init();
		
		return _instance;
	}


	DialogDecoration get dialogDecoration => _dialogDecoration;

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
		_dialogDecoration = DialogDecoration();

		Color textColor(){
			if(ColorHelper.isNearColor(AppThemes.instance.currentTheme.dialogBackColor, Colors.white)) {
				return Colors.black;
			}

			return Colors.white;
		}

		_dialogDecoration.descriptionColor = textColor();
		//_dialogDecoration.titleColor = textColor();
		_dialogDecoration.titleColor = Colors.white;
		_dialogDecoration.titleBackgroundColor = AppThemes.instance.currentTheme.accentColor;
		_dialogDecoration.iconBackgroundColor = Colors.black;
		_dialogDecoration.positiveButtonTextColor = AppThemes.instance.currentTheme.buttonTextColor;
		_dialogDecoration.negativeButtonTextColor = AppThemes.instance.currentTheme.buttonTextColor;
		_dialogDecoration.positiveButtonBackColor = AppThemes.buttonBackgroundColor();
		_dialogDecoration.negativeButtonBackColor = AppThemes.buttonBackgroundColor();
	}
	///============================================================================================================
	Future showDialog(
			BuildContext context, {
				String? title,
				String? desc,
				String? yesText,
				Widget? descView,
				Widget? icon,
				Function? yesFn,
				bool dismissOnButtons = true,
				DialogDecoration? decoration,
			}) {
		decoration ??= AppDialog.instance.dialogDecoration;
		return Dialogs.materialDialog(
				color: Colors.white,
				msg: desc,
				title: title,
				context: context,
				actions: [
					IconsButton(
						onPressed: () {},
						text: 'Claim',
						iconData: Icons.done,
						color: Colors.blue,
						textStyle: const TextStyle(color: Colors.white),
						iconColor: Colors.white,
					),
				]
		);
	}

  Future showYesNoDialog(
			BuildContext context, {
				String? desc,
				Widget? descView,
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

				OutlinedButton(
						onPressed: (){
							yesFn?.call();
						},
						child: Text(noText?? AppMessages.no)
				)
			]
		);
	}

	void showSuccessDialog(BuildContext context, String? title, String desc) {//shield-check, sticker-check, thump-up
		showDialog(context, title: title, desc: desc,
				icon: const Icon(AppIcons.eye, size: 48, color: Colors.green,)
		);
	}

	void showWarningDialog(BuildContext context, String? title, String desc) {
		showDialog(context, title: title, desc: desc, icon:
		const Icon(AppIcons.eye, size: 48, color: Colors.orange,)
		);
	}

	void showInfoDialog(BuildContext context, String? title, String desc) { //library
		showDialog(context, title: title, desc: desc,
				icon: const Icon(AppIcons.eye, size: 48, color: Colors.blue,)
		);
	}

	Future showErrorDialog(BuildContext context, String? title, String desc) { //alert, minus-circle
		return showDialog(context, title: title, desc: desc,
				icon: const Icon(AppIcons.eye, size: 48, color: Colors.redAccent,)
		);
	}
	///============================================================================================================
	Future showDialog$NetDisconnected(BuildContext context) {
		return showErrorDialog(
			context,
			null,
			AppMessages.netConnectionIsDisconnect,
		);
	}

	Future<bool> showDialog$wantClose(BuildContext context, {Widget? view}) {
		Dialogs.materialDialog(
			context: context,
		);

		return Future.value(false);
	}
}
///========================================================================================
class DialogDecoration {
	ThemeData? themeData;
	Color? dimColor;
	Color? backgroundColor;
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

