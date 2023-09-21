import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/managers/orientationManager.dart';
import 'package:iris_tools/modules/irisLocalizations.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/tools/app/app_loading.dart';
import 'package:app/tools/app/app_locale.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/route_tools.dart';
import '/managers/settings_manager.dart';

/// with SingleTickerProviderStateMixin
/// with TickerProviderStateMixin

abstract class StateSuper<W extends StatefulWidget> extends State<W> {
	final AssistController assistCtr = AssistController();
	late double ws;
	late double hs;
	late double hr;

	@override
  void didUpdateWidget(W oldWidget) {
		super.didUpdateWidget(oldWidget);
  }

  @override
	void initState() {
		super.initState();

		RouteTools.addWidgetState(this);

		if(kIsWeb){
			AppSizes.instance.addMetricListener(onResize);
		}

		ws = AppSizes.instance.appWidth;
		hs = AppSizes.instance.appHeight;
		hr = AppSizes.instance.heightRatio;
	}

	@override
	Widget build(BuildContext context) {
		return const Center(child: Text('State-Base'),);
	}

	@override
	void dispose() {
		RouteTools.removeWidgetState();

		if(kIsWeb){
			AppSizes.instance.removeMetricListener(onResize);
		}

		super.dispose();
	}

	void callState() {
		if(mounted) {
		  setState(() {});
		}
	}

	void rotateToDefaultOrientation() {
		OrientationManager.setAppRotation(SettingsManager.localSettings.appRotationState);
	}

	void rotateToPortrait() {
		if(!OrientationManager.isPortrait(context)) {
		  OrientationManager.fixPortraitModeOnly();
		}
	}

	void rotateToLandscape() {
		if(!OrientationManager.isLandscape(context)) {
		  OrientationManager.fixLandscapeModeOnly();
		}
	}

	String? t(String key, {String? key2, String? key3}) {
		var res1 = AppLocale.appLocalize.translate(key);

		if(res1 == null) {
		  return null;
		}

		if(key2 != null) {
		  res1 += ' ${AppLocale.appLocalize.translate(key2)?? ''}';
		}

		if(key3 != null) {
		  res1 += ' ${AppLocale.appLocalize.translate(key3)?? ''}';
		}

		return res1;
	}
	//------------------------------------------------------
	Map<String, dynamic>? tAsMap(String key) {
		return AppLocale.appLocalize.translateAsMap(key);
	}

	String? tInMap(String key, String subKey) {
		return tAsMap(key)?[subKey];
	}

	IrisLocalizations localization() {
		return AppLocale.appLocalize;
	}
	///-------------------------------------------------------
	void addPostOrCall({required Function() fn, BuildContext? subContext}) async {
		if(!mounted){
			return;
		}

		await Future.delayed(const Duration(milliseconds: 10), (){});

		final status = ((subContext?? context) as Element).dirty;

		if(status) {
			WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
				fn.call();
			});
		}
		else {
			fn.call();
		}
	}

	/// note: can not show a dialog in initState(), use addPostFrameCallback() if it is force
	void showLoading({bool canBack = false, Duration? startDelay}){
		AppLoading.instance.showLoading(context, dismiss: canBack);
	}

	Future hideLoading(){
		return AppLoading.instance.hideLoading(context);
	}

	// Btn back
	void onBackButton<s extends StateSuper>(s state, {dynamic result}) {
		// when call [maybePop()] , onWillBack will call
		// when call [Pop()] , onWillBack not call
		Navigator.of(state.context).maybePop(result);
	}

	// before close (mayPop), keyboard backKey, onBackButton
	Future<bool> onWillBack<s extends StateSuper>(s state) {
		/*if (false) {
			Navigator.of(state.context).pop();
			return Future<bool>.value(false);
		}*/

		// if true: popPage,  false: not close page
		return Future<bool>.value(true);
	}

	void onResize(oldW, oldH, newW, newH){
		// must override if need
	}
}

/*
	## override onWillBack in children (Screen|Page):

	@override
  Future<bool> onWillBack<s extends StateBase>(s state) {
    if (weSlideController.isOpened) {
      weSlideController.hide();
      return Future<bool>.value(false);
    }

		return Future<bool>.value(true);
    // do not use this, not work: return super.onWillBack(state);
  }

	.............
	WillPopScope(
			onWillPop: () => state.onWillBack(state),
			onWillPop: () => onWillBack(this),
			child: ...
	)
 --------------------------------------------------------------------------------------

 --------------------------------------------------------------------------------------

*/
