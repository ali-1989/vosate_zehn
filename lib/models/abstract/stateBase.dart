import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/managers/orientationManager.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/system/localizations.dart';
import 'package:app/tools/app/appLoading.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appSizes.dart';
import '/managers/settingsManager.dart';

/// with SingleTickerProviderStateMixin
/// with TickerProviderStateMixin

abstract class StateBase<W extends StatefulWidget> extends State<W> {
	final AssistController assistCtr = AssistController();
	late double sw;
	late double sh;

	@override
  void didUpdateWidget(W oldWidget) {
		super.didUpdateWidget(oldWidget);
  }

  @override
	void initState() {
		super.initState();

		if(kIsWeb){
			AppSizes.instance.addMetricListener(onResize);
		}

		sw = AppSizes.instance.appWidth;
		sh = AppSizes.instance.appHeight;
	}

	@override
	Widget build(BuildContext context) {
		return const Center(child: Text('State-Base'),);
	}

	@override
	void dispose() {
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
		OrientationManager.setAppRotation(SettingsManager.settingsModel.appRotationState);
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
		return AppLocale.appLocalize.translateMap(key);
	}

	String? tInMap(String key, String subKey) {
		return tAsMap(key)?[subKey];
	}

	IrisLocalizations localization() {
		return AppLocale.appLocalize;
	}

	void addPostOrCall(Function() fn){
		if(!mounted){
			return;
		}

		var status = (context as Element).dirty;

		if(status) {
			WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
				fn.call();
			});
		}
		else {
			fn.call();
		}
	}

	void showLoading({bool canBack = false, Duration? startDelay}){
		AppLoading.instance.showLoading(context, dismiss: canBack);
	}

	Future hideLoading(){
		return AppLoading.instance.hideLoading(context);
	}

	// Btn back
	void onBackButton<s extends StateBase>(s state, {dynamic result}) {
		// when call [maybePop()] , onWillBack will call
		// when call [Pop()] , onWillBack not call
		Navigator.of(state.context).maybePop(result);
	}

	// before close (mayPop), keyboard backKey, onBackButton
	Future<bool> onWillBack<s extends StateBase>(s state) {
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
			child: ...)
 --------------------------------------------------------------------------------------
 sample of build():

 state.mediaQuery ??= MediaQuery.of(state.context).size;

  return WillPopScope(
    onWillPop: () => state.onWillBack(state),
    child: Material( //or Scaffold
        child: SizedBox(
          width: state.mediaQuery.width,
          height: state.mediaQuery.height,
          child: SafeArea(
            child:
 --------------------------------------------------------------------------------------






 dynamic tDynamicOrFirst(String key, String subKey) {
		final list = tAsMap(key);

		if(list == null) {
		  return null;
		}

		final Iterable<MapEntry> tra = list.entries;
		MapEntry? find;

		try {
			find = tra.firstWhere((element) {
				return element.key == subKey;
			});
		}
		catch (e){}

		if(find != null) {
		  return find.value;
		}

		return tra.first.value;
	}

	String? tJoin(String key, {String join = ''}) {
		final list = tAsMap(key);

		if(list == null) {
		  return null;
		}

		var res = '';

		for(final s in list.entries){
			res += s.value.toString() + join;
		}

		if(res.length > join.length) {
			res = res.substring(0, res.length - join.length);
		}

		return res;
	}


 	String? tC(String key, {String? key2, String? key3}) {
		var res1 = AppLocale.appLocalize.translateCapitalize(key);

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


 */
