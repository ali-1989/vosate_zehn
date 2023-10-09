import 'dart:async';

import 'package:app/tools/app/app_decoration.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/irisDialog/irisDialog.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sizes.dart';
import '/tools/app/app_themes.dart';

typedef OnButtonCallback = FutureOr Function(BuildContext context);

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
		_dialogDecoration.positiveButtonBackColor = AppDecoration.buttonBackgroundColor();
		_dialogDecoration.negativeButtonBackColor = AppDecoration.buttonBackgroundColor();

		if(AppSizes.isBigWidth()) {
			double factor = 0.8;
			double wid = AppSizes.instance.appWidth * factor;

			while(wid > (AppSizes.webMaxWidthSize - 50)){
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
				OnButtonCallback? yesFn,
				bool dismissOnButtons = true,
				bool canDismissible = false,
				IrisDialogDecoration?	decoration,
			}) {
		return IrisDialog.show(
			context,
			descriptionText: desc,
			descriptionWidget: descView,
      positiveButtonText: yesText,
			title: title,
			icon: icon,
			canDismissible: canDismissible,
			positivePress: (ctx) => yesFn?.call(ctx),
			dismissOnButtons: dismissOnButtons,
			decoration: decoration ?? AppDialogIris.instance.dialogDecoration,
		);
	}

  Future showYesNoDialog(
			BuildContext context, {
				String? desc,
				Widget? descView,
				String? yesText,
				String? noText,
				OnButtonCallback? yesFn,
				OnButtonCallback? noFn,
				String? title,
				Widget? icon,
				bool dismissOnButtons = true,
				bool canDismissible = false,
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
			canDismissible: canDismissible,
			positivePress: (ctx) => yesFn?.call(ctx),
			negativePress: (ctx) => noFn?.call(ctx),
		);
	}

	Future showTextInputDialog(
			BuildContext context, {
				required Widget descView,
				String? mainButtonText,
				required dynamic Function(BuildContext context, String txt) mainButton,
				Function(String txt)? onChange,
				String? noText,
				String? initValue,
				OnButtonCallback? noFn,
				String? title,
				Widget? icon,
				bool canDismiss = true,
				Widget? textField,
				TextInputType? textInputType,
				InputDecoration? inputDecoration,
				TextEditingController? textEditingController,
				IrisDialogDecoration?	decoration,
		}){

		var txt = '';

		dynamic onPosClick(BuildContext ctx){
			return mainButton.call(ctx, txt);
		}

		void myOnChange(String input){
			txt = input;
			onChange?.call(input);
		}

		final dec = AppDialogIris.instance.dialogDecoration.copy();
		dec.negativeButtonBackColor = Colors.transparent;
		dec.negativeButtonTextColor = Colors.black;

		return IrisDialog.show(
			context,
			descriptionWidget: _TextInputView(
				topView: descView,
				inputDecoration: inputDecoration,
				textInputType: textInputType,
				controller: textEditingController,
				onChange: myOnChange,
				initValue: initValue,
				textField: textField,
			),
			positiveButtonText: mainButtonText?? AppMessages.yes,
			negativeButtonText: noText,
			title: title,
			decoration: decoration?? AppDialogIris.instance.dialogDecoration,
			icon: icon,
			canDismissible: canDismiss,
			dismissOnButtons: false,
			positivePress: (ctx) => onPosClick.call(ctx),
			negativePress: noFn != null? (ctx) => noFn.call(ctx) : null,
		);
	}

	void showSuccessDialog(BuildContext context, String? title, String desc) {//shield-check, sticker-check, thump-up
		showIrisDialog(context, title: title, desc: desc,
				icon: const Icon(AppIcons.eye, size: 48, color: Colors.green)
		);
	}

	void showWarningDialog(BuildContext context, String? title, String desc) {
		showIrisDialog(context, title: title, desc: desc, icon:
		const Icon(AppIcons.eye, size: 48, color: Colors.orange)
		);
	}

	void showInfoDialog(BuildContext context, String? title, String desc) { //library
		showIrisDialog(context, title: title, desc: desc,
				icon: const Icon(AppIcons.eye, size: 48, color: Colors.blue)
		);
	}

	Future showErrorDialog(BuildContext context, String? title, String desc) { //alert, minus-circle
		return showIrisDialog(context, title: title, desc: desc,
				icon: const Icon(AppIcons.eye, size: 48, color: Colors.redAccent)
		);
	}
	///===========================================================================================================
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
///=============================================================================
class _TextInputView extends StatefulWidget {
	final Widget topView;
	final Widget? textField;
	final TextEditingController? controller;
	final String? initValue;
	final TextInputType? textInputType;
	final	InputDecoration? inputDecoration;
	final Function(String txt)? onChange;

	const _TextInputView({
		required this.topView,
		this.onChange,
		this.textField,
		this.controller,
		this.initValue,
		this.textInputType,
		this.inputDecoration,
		super.key,
	});

  @override
  State<_TextInputView> createState() => _TextInputViewState();
}
///-------------------------------
class _TextInputViewState extends State<_TextInputView> {
  late TextEditingController controller;


	@override
	void initState() {
		super.initState();

		controller = widget.controller?? TextEditingController();

		if(widget.initValue != null){
			controller.text = widget.initValue!;
		}
	}

	@override
  void dispose() {
		controller.dispose();
		super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				widget.topView,
				const SizedBox(height: 10),

				Builder(
				  builder: (context) {
						if(widget.textField != null){
							return widget.textField!;
						}

				    return AutoDirection(
				    		builder: (context, dCtr){
				    			return TextField(
				    				controller: controller,
				    				textDirection: dCtr.getTextDirection(controller.text),
				    				textInputAction: TextInputAction.done,
				    				keyboardType: widget.textInputType,
				    				maxLines: 1,
				    				expands: false,
				    				decoration: widget.inputDecoration,
				    				onChanged: (t){
				    					dCtr.onChangeText(t);
				    					widget.onChange?.call(t);
				    				},
				    			);
				    		}
				    );
				  }
				),
			],
		);
  }
}
