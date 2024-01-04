import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/managers/orientationManager.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/tools/app/app_loading.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/route_tools.dart';
import '/managers/settings_manager.dart';

/// with SingleTickerProviderStateMixin
/// with TickerProviderStateMixin

abstract class StateSuper<W extends StatefulWidget> extends State<W> {
	final AssistController assistCtr = AssistController();
	late double ws;
	late double hs;
	late double wRel;
	late double hRel;
	late double iconR;
	late double fontR;

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
		wRel = AppSizes.instance.widthRelative;
		hRel = AppSizes.instance.heightRelative;
		iconR = AppSizes.instance.iconRatio;
		fontR = AppSizes.instance.fontRatio;
	}

	@override
	Widget build(BuildContext context) {
		return const Center(child: Text('State-super'));
	}

	@override
	void dispose() {
		RouteTools.removeWidgetState(this);

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

		// true: pop,  false: not close page
		return Future<bool>.value(true);
	}

	void onResize(oldW, oldH, newW, newH){
		// must override if need
	}
}

/*
	## override onWillBack in children (Screen|Page):

	@override
  Future<bool> onWillBack<s extends StateSuper>(s state) {
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
 -------------------------------------------------------------------------------

*/
