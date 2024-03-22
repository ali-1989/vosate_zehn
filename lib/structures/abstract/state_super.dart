import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/managers/orientationManager.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/tools/app/app_loading.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/route_tools.dart';
import '/managers/settings_manager.dart';

/// with SingleTickerProviderStateMixin
/// with TickerProviderStateMixin

abstract class StateSuper<W extends StatefulWidget> extends State<W> {
	final AssistController assistCtr = AssistController();
	double get ws => AppSizes.instance.appWidth;
	double get hs => AppSizes.instance.appHeight;
	double get wRel => AppSizes.instance.widthRelative;
	double get hRel => AppSizes.instance.heightRelative;
	double get iconR => AppSizes.instance.iconRatio;
	double get fontR => AppSizes.instance.fontRatio;

	@override
  void didUpdateWidget(W oldWidget) {
		super.didUpdateWidget(oldWidget);
  }

  @override
	void initState() {
		super.initState();

		RouteTools.addWidgetState(this);

		if(!System.isMobile()){
			AppSizes.instance.addMetricListener(onResize);
		}
	}

	@override
	Widget build(BuildContext context) {
		return const Center(child: Text('State-super'));
	}

	@override
	void dispose() {
		RouteTools.removeWidgetState(this);
		AppSizes.instance.removeMetricListener(onResize);

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

	void onResize(oldW, oldH, newW, newH){
		if(kIsWeb && mounted){
			setState(() {});
		}
		// must override if need.
		// any page that is pushed by Navigator.push() not listen Resize by default.
		// must override this to listen. but widget tree before first Push receive changes.
	}
}


/**
 onPop:
		bool onPop<s extends StateSuper>(s state, bool? last) {
			if(last != null){
				MoveToBackground.moveTaskToBack();
			}

			return false;
		}

		PopScope(
		canPop: onPop(this, null),
		onPopInvoked: (s)=> onPop(this, s),
		child:
 */
