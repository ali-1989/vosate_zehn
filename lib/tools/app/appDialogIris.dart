import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/irisDialog/irisDialog.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';

class AppDialogIris {
	static final _instance = AppDialogIris._();
	static bool _isInit = false;
	static late IrisDialogDecoration _dialogDecoration;

	static AppDialogIris get instance {
		_init();
		
		return _instance;
	}

	IrisDialogDecoration get dialogDecoration => _dialogDecoration;

	static void _init(){
		if(!_isInit){
			prepareDialogDecoration();
			_isInit = true;
		}
	}

	AppDialogIris._(){
		_init();
	}

	factory AppDialogIris(){
		return _instance;
	}

	static void prepareDialogDecoration(){
		_dialogDecoration = IrisDialogDecoration();

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

		if(AppSizes.isBigWidth()) {
			double factor = 0.8;
			double wid = AppSizes.instance.appWidth * factor;

			while(wid > (AppSizes.webMaxDialogSize - 50)){
				factor -= 0.05;
				wid = AppSizes.instance.appWidth * factor;
			}

			_dialogDecoration.widthFactor = factor;
		}
	}
	///============================================================================================================
	Future showIrisDialog(
			BuildContext context, {
				String? title,
				String? desc,
				String? yesText,
				Widget? descView,
				Widget? icon,
				Function? yesFn,
				bool dismissOnButtons = true,
				IrisDialogDecoration?	decoration,
			}) {
		return IrisDialog.show(
			context,
			descriptionText: desc,
			descriptionWidget: descView,
      positiveButtonText: yesText,
			title: title,
			icon: icon,
			positivePress: (ctx)=> yesFn?.call(),
			dismissOnButtons: dismissOnButtons,
			decoration: decoration ?? AppDialogIris.instance.dialogDecoration,
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
				IrisDialogDecoration?	decoration,
		}){

		return IrisDialog.show(
			context,
			descriptionText: desc,
			descriptionWidget: descView,
			positiveButtonText: yesText?? AppMessages.yes,
			negativeButtonText: noText?? AppMessages.no,
			title: title,
			decoration: decoration?? AppDialogIris.instance.dialogDecoration,
			icon: icon,
			dismissOnButtons: dismissOnButtons,
			positivePress: (ctx)=> yesFn?.call(),
			negativePress: (ctx)=> noFn?.call(),
		);
	}

	Future showTextInputDialog(
			BuildContext context, {
				required Widget descView,
				String? yesText,
				required Function(String txt) yesFn,
				Function(String txt)? onChange,
				String? noText,
				String? initValue,
				Function? noFn,
				String? title,
				Widget? icon,
				bool canDismiss = true,
				TextInputType textInputType = TextInputType.text,
				IrisDialogDecoration?	decoration,
		}){

		final ctr = TextEditingController();

		if(initValue != null){
			ctr.text = initValue;
		}

		onPosClick(){
			final txt = ctr.text;
			yesFn.call(txt);
		}

		final rejectView = Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				descView,
				const SizedBox(height: 15,),
				AutoDirection(
						builder: (context, dCtr){
							return TextField(
								controller: ctr,
								textDirection: dCtr.getTextDirection(ctr.text),
								textInputAction: TextInputAction.done,
								keyboardType: textInputType,
								maxLines: 1,
								expands: false,
								onChanged: (t){
									dCtr.onChangeText(t);
									onChange?.call(t);
								},
							);
						}
				),
			],
		);

		final dec = AppDialogIris.instance.dialogDecoration.copy();
		dec.negativeButtonBackColor = Colors.transparent;
		dec.negativeButtonTextColor = Colors.black;

		return IrisDialog.show(
			context,
			descriptionWidget: rejectView,
			positiveButtonText: yesText?? AppMessages.yes,
			negativeButtonText: noText,
			title: title,
			decoration: decoration?? AppDialogIris.instance.dialogDecoration,
			icon: icon,
			canDismissible: canDismiss,
			dismissOnButtons: false,
			positivePress: (ctx)=> onPosClick.call(),
			negativePress: noFn != null? (ctx)=> noFn.call() : null,
		);
	}

	void showSuccessDialog(BuildContext context, String? title, String desc) {//shield-check, sticker-check, thump-up
		showIrisDialog(context, title: title, desc: desc,
				icon: const Icon(AppIcons.eye, size: 48, color: Colors.green,)
		);
	}

	void showWarningDialog(BuildContext context, String? title, String desc) {
		showIrisDialog(context, title: title, desc: desc, icon:
		const Icon(AppIcons.eye, size: 48, color: Colors.orange,)
		);
	}

	void showInfoDialog(BuildContext context, String? title, String desc) { //library
		showIrisDialog(context, title: title, desc: desc,
				icon: const Icon(AppIcons.eye, size: 48, color: Colors.blue,)
		);
	}

	Future showErrorDialog(BuildContext context, String? title, String desc) { //alert, minus-circle
		return showIrisDialog(context, title: title, desc: desc,
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
		final x = IrisDialog.show<bool>(
			context,
			descriptionWidget: view?? Text(
				AppMessages.wantToLeave,
          style: AppThemes.baseTextStyle().copyWith(
            fontSize: 16,
          ),
        ),
      positiveButtonText: AppMessages.yes,
      negativeButtonText: AppMessages.no,
			decoration: AppDialogIris.instance.dialogDecoration,
			positivePress: (ctx){
				return true;
				//Navigator.of(context).pop<bool>(true);
			},
			negativePress: (ctx)=> false,
		);

		return Future<bool>((){
			return x.then((value) {
				if(value != null) {
				  return value;
				}

				return false;
			});
		});
	}
}
