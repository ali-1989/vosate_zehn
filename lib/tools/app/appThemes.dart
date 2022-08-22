import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/models/colorTheme.dart';
import '/managers/fontManager.dart';

/// hlp:
/// https://htmlcolorcodes.com/
/// https://colorhunt.co/

class AppThemes {
	AppThemes._();

	static late final AppThemes _instance;
	static bool _isInit = false;
	static final List<Function(ColorTheme)> _onThemeChangeListeners = [];

	Map<String, ColorTheme> themeList = {};
	late ColorTheme currentTheme;
	late ColorTheme defaultTheme;
	late Font baseFont;
	late Font subFont;
	late Font boldFont;
	late ThemeData themeData;
	ThemeMode currentThemeMode = ThemeMode.light;
	Brightness currentBrightness = Brightness.light;
	TextDirection textDirection = TextDirection.rtl;
	StrutStyle strutStyle = const StrutStyle(forceStrutHeight: true, height: 1.08, leading: 0.36);

	static AppThemes get instance {
		initial();

		return _instance;
	}

	static void addThemeChangeListener(Function(ColorTheme) lis) {
		if (!_onThemeChangeListeners.contains(lis)) {
		  _onThemeChangeListeners.add(lis);
		}
	}

	static void removeThemeChangeListener(Function(ColorTheme) lis) {
		_onThemeChangeListeners.remove(lis);
	}

	static ThemeData accessThemeData(BuildContext context) {
		return Theme.of(context);
	}

	static void initial() {
		if(!_isInit) {
			_instance = AppThemes._();

			_instance.baseFont = Font();
			_instance.subFont = Font();
			_instance.boldFont = Font();
		}

		_instance.themeList.clear();
		prepareThemes();

		if(!_isInit) {
			_instance.currentTheme = _instance.defaultTheme;
		}

		_instance.themeData = createThemeData(_instance.currentTheme);
		_isInit = true;
	}

	static void prepareThemes() {
		{
			final blueTheme = ColorTheme(Colors.amber, Colors.orange, const Color(0xFFFF006E), Colors.black);
			//primary: ^1976D2, 1060A0 | dif: (FF006E|d81b60), ^F77F00

			blueTheme.themeName = 'Amber';
			blueTheme.appBarItemColor = Colors.black.withAlpha(180);

			AppThemes._instance.themeList[blueTheme.themeName] = blueTheme;
			AppThemes._instance.defaultTheme = blueTheme;
		}
	}

	static void applyDefaultTheme() {
		applyTheme(AppThemes._instance.defaultTheme);
	}

	static void applyTheme(ColorTheme theme) {
		AppThemes._instance.currentTheme = theme;
		AppThemes._instance.themeData = createThemeData(theme);

		_onThemeChange();
	}

	static void prepareDefaultFontFor(String lang){
		AppThemes._instance.baseFont = FontManager.instance.defaultFontFor(lang, FontUsage.normal);
		AppThemes._instance.subFont = FontManager.instance.defaultFontFor(lang, FontUsage.sub);
		AppThemes._instance.boldFont = FontManager.instance.defaultFontFor(lang, FontUsage.bold);
	}

	static void _onThemeChange() {
		for (final f in _onThemeChangeListeners) {
			try {
				f.call(_instance.currentTheme);
			}
			catch (e) {/**/}
		}
	}
	///--------------------------------------------------------------------------------------------------
	static void _checkTheme(ColorTheme th) {
		th.buttonsColorScheme = ColorScheme.fromSwatch(
			primarySwatch: th.primarySwatch,
			primaryColorDark: ColorHelper.darkIfIsLight(th.primaryColor),
			// buttons are use this color for btnText (accentColor)
			accentColor: th.buttonTextColor,
			backgroundColor: th.buttonBackColor,
			errorColor: th.errorColor,
			cardColor: th.cardColor,
			brightness: _instance.currentBrightness,
		);

		th.fontSize = _instance.baseFont.size ??  FontManager.instance.getPlatformFont().size!;

		final raw = FontManager.instance.rawTextTheme;

		th.baseTextStyle = raw.bodyText2!.copyWith(
			fontSize: _instance.baseFont.size,
			fontFamily: _instance.baseFont.family,
			height: _instance.baseFont.height,
			color: th.textColor,
		);
		th.subTextStyle = raw.subtitle1!.copyWith(
			fontSize: _instance.subFont.size,
			fontFamily: _instance.subFont.family,
			height: _instance.subFont.height,
			color: th.textColor,
		);
		th.boldTextStyle = raw.headline1!.copyWith(
			fontSize: _instance.boldFont.size,
			fontFamily: _instance.boldFont.family,
			height: _instance.boldFont.height,
			color: th.textColor,
		);

		th.textUnderlineStyle = th.textUnderlineStyle.copyWith(
			fontSize: th.fontSize,
			height: _instance.baseFont.height,
			color: th.underLineDecorationColor,
			decorationColor: th.underLineDecorationColor,
		);
	}

	static ThemeData createThemeData(ColorTheme th) {
		if (th.executeOnStart != null) {
		  th.executeOnStart?.call(th);
		}

		_checkTheme(th);

		final baseFamily = th.baseTextStyle.fontFamily;
		final subFamily = th.subTextStyle.fontFamily;
		final boldFamily = th.boldTextStyle.fontFamily;
		final fontSize = th.fontSize;
		final height = th.baseTextStyle.height?? 1.0;
		final raw = FontManager.instance.rawThemeData;

		final primaryTextTheme = TextTheme(
				//fontSize: raw.textTheme.bodyText1.fontSize + fontSize
				bodyText1: raw.textTheme.bodyText1!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				bodyText2: raw.textTheme.bodyText2!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				subtitle1: raw.textTheme.subtitle1!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				subtitle2: raw.textTheme.subtitle2!.copyWith(
						fontFamily: subFamily, color: th.textColor, fontSize: fontSize-1, height: height,
				),
				overline: raw.textTheme.overline!.copyWith(
						fontFamily: subFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				headline1: raw.textTheme.headline1!.copyWith(
						fontFamily: boldFamily, color: th.textColor, fontSize: fontSize + 6, height: height,
				),
				headline2: raw.textTheme.headline2!.copyWith(
						fontFamily: boldFamily, color: th.textColor, fontSize: fontSize + 5, height: height,
				),
				headline3: raw.textTheme.headline3!.copyWith(
						fontFamily: boldFamily, color: th.textColor, fontSize: fontSize + 4, height: height,
				),
				headline4: raw.textTheme.headline4!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize + 3, height: height,
				),
				headline5: raw.textTheme.headline5!.copyWith(
						fontFamily: baseFamily, color: th.textColor, fontSize: fontSize + 2, height: height,
				),
				headline6: raw.textTheme.headline6!.copyWith(
						fontFamily: baseFamily, color: th.appBarItemColor, fontSize: fontSize + 1,
					fontWeight: FontWeight.bold, height: height,
				),
				button: raw.textTheme.button!.copyWith(
						fontFamily: boldFamily, color: th.buttonTextColor, fontSize: fontSize, height: height,
				),
				caption: raw.textTheme.caption!.copyWith(
						fontFamily: subFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
		);

		final chipBack = checkPrimaryByWB(th.primaryColor, th.buttonBackColor);
		final chipTextColor = ColorHelper.getUnNearColor(Colors.white, chipBack, Colors.black);

		final chipThemeData = raw.chipTheme.copyWith(//ThemeData();
			brightness: AppThemes._instance.currentBrightness,
			backgroundColor: chipBack,
			checkmarkColor: chipTextColor,
			deleteIconColor: chipTextColor,
			selectedColor: th.differentColor,
			disabledColor: th.inactiveTextColor,//changeLight(th.accentColor),
			shadowColor: th.shadowColor,
			labelStyle: th.subTextStyle.copyWith(color: chipTextColor),
			elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 0.0: 1.0,
			padding: const EdgeInsets.all(0.0),
		);

		final scrollbarTheme = const ScrollbarThemeData().copyWith(
			thumbColor: MaterialStateProperty.all(
					AppThemes.checkPrimaryByWB(th.primaryColor.withAlpha(80), th.differentColor.withAlpha(80))
			),
		);

		final iconTheme = raw.iconTheme.copyWith(
			color: th.textColor,
		);

		final appAppBarTheme = AppBarTheme(
			toolbarTextStyle: primaryTextTheme.headline6,
			iconTheme: iconTheme.copyWith(color: th.appBarItemColor),
			foregroundColor: th.appBarItemColor,
			actionsIconTheme: iconTheme.copyWith(color: th.appBarItemColor),
			systemOverlayStyle: AppThemes._instance.currentBrightness == Brightness.light? SystemUiOverlayStyle.light: SystemUiOverlayStyle.dark,
			centerTitle: true,
			elevation: 1.0,
			color: th.appBarBackColor,
			shadowColor: th.shadowColor,
		);

		final dialogTheme = DialogTheme(
				elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 1.0: 5.0,
				titleTextStyle: th.baseTextStyle.copyWith(fontSize: fontSize + 5, color: th.dialogTextColor, fontWeight: FontWeight.w700),
				contentTextStyle: th.baseTextStyle.copyWith(fontSize: fontSize + 2, color: th.dialogTextColor),
				backgroundColor: th.dialogBackColor,
				shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
		);

		const pageTransition = PageTransitionsTheme(builders: {
			TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
			TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
		});

		final sliderTheme = SliderThemeData(
			trackHeight: 4.0,
			trackShape: const RoundedRectSliderTrackShape(),
			thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
			overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
			tickMarkShape: const RoundSliderTickMarkShape(),
			valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
			thumbColor: th.buttonBackColor, //circle
			activeTrackColor: th.buttonBackColor,// selectedBar
			inactiveTrackColor: th.inactiveBackColor, // selectedBar before seek
			activeTickMarkColor: th.buttonBackColor,// selectedBar dot,
			disabledActiveTickMarkColor: th.buttonBackColor,// unSelectedBar dot,
			overlayColor: th.errorColor,
			valueIndicatorColor: th.infoColor,
		);

		final popupMenu = PopupMenuThemeData(
			elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 0.0: 4.0,
			color: th.drawerBackColor,
			textStyle: th.baseTextStyle.copyWith(height: 1.1),
		);

		final colorScheme = ColorScheme.fromSwatch(
		primarySwatch: th.primarySwatch,
		primaryColorDark: ColorHelper.darkIfIsLight(th.primaryColor),
		accentColor: th.accentColor, // => is secondary
		backgroundColor: th.backgroundColor,
		errorColor: th.errorColor,
		cardColor: th.cardColor,
		brightness: AppThemes._instance.currentBrightness,
		);

		final cardTheme = CardTheme(
			color: th.cardColor,
			elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 3.0: 4.0,
			shadowColor: th.shadowColor,
			clipBehavior: Clip.antiAlias,
			margin: const EdgeInsets.all(4.0), // def: 4.0
		);

		/// https://flutter.dev/docs/release/breaking-changes/buttons

		final elevatedButtonTheme = ElevatedButtonThemeData(
			style: ButtonStyle(
					tapTargetSize: MaterialTapTargetSize.padded,
				//backgroundColor: MaterialStateProperty.all(th.buttonBackColor),
				foregroundColor: MaterialStateProperty.all(th.buttonTextColor),
				backgroundColor: MaterialStateProperty.resolveWith<Color>(
							(Set<MaterialState> states) {
						if (states.contains(MaterialState.disabled)) {
						  return th.inactiveBackColor;
						}
						if (states.contains(MaterialState.hovered)) {
							return th.buttonBackColor.withAlpha(200);
						}
						if (states.contains(MaterialState.focused) ||
								states.contains(MaterialState.pressed)) {
						  return th.buttonBackColor;
						}

						return th.buttonBackColor;
					},
				),
			),
		);

		final textButtonTheme = TextButtonThemeData(
			style: ButtonStyle(
				//foregroundColor: MaterialStateProperty.all(AppThemes.checkPrimaryByWB(th.primaryColor, th.differentColor)),
				//foregroundColor: MaterialStateProperty.all(Colors.lightBlue),
				visualDensity: VisualDensity.comfortable,
				tapTargetSize: MaterialTapTargetSize.padded,
				foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
							if (states.contains(MaterialState.disabled)) {
								return th.inactiveBackColor;
							}
							if (states.contains(MaterialState.hovered)) {
								return Colors.lightBlue.withAlpha(200);
							}
							if (states.contains(MaterialState.focused) ||
									states.contains(MaterialState.pressed)) {
								return Colors.lightBlue;
							}

							return Colors.lightBlue;
						},
				),
				overlayColor: MaterialStateProperty.all(
						AppThemes.checkPrimaryByWB(th.primaryColor, th.differentColor).withAlpha(100)
				),
			),
		);

		final outlinedButtonTheme = OutlinedButtonThemeData(
			style: ButtonStyle(
				tapTargetSize: MaterialTapTargetSize.shrinkWrap,
				//backgroundColor: MaterialStateProperty.all(th.buttonBackColor),
				foregroundColor: MaterialStateProperty.all(th.textColor),
			),
		);

		final tableThemeData = DataTableThemeData(
			dataRowColor: MaterialStateProperty.all(th.primaryColor),
			headingRowColor: MaterialStateProperty.all(th.differentColor),
			dataTextStyle: primaryTextTheme.caption,
		);

		final radioThemeData = RadioThemeData(
			fillColor: MaterialStateProperty.all(AppThemes.checkPrimaryByWB(th.primaryColor, th.differentColor)),
			overlayColor: MaterialStateProperty.all(th.differentColor),
			materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
			visualDensity: VisualDensity.comfortable,
		);

		final checkboxThemeData = CheckboxThemeData(
			fillColor: MaterialStateProperty.all(AppThemes.checkPrimaryByWB(th.primaryColor, th.differentColor)),
			overlayColor: MaterialStateProperty.all(th.differentColor),
			materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
			visualDensity: VisualDensity.comfortable,
		);

		final dividerTheme = DividerThemeData(
			color: th.dividerColor,
			endIndent: 0,
			indent: 0,
			space: 1.0,
			thickness: 1.0
		);

		final inputDecoration = InputDecorationTheme(
			hintStyle: th.baseTextStyle.copyWith(color: th.hintColor),
			labelStyle: th.subTextStyle.copyWith(color: th.hintColor),
			focusColor: th.hintColor,
			hoverColor: th.infoTextColor,//webHoverColor
			floatingLabelBehavior: FloatingLabelBehavior.auto,
			border: UnderlineInputBorder(borderSide: BorderSide(color: th.hintColor)),
			focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.hintColor)),
			enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.hintColor)),
			disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.inactiveTextColor)),
			//errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.inactiveTextColor)),
			//focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.inactiveTextColor)),
		); ///OutlineInputBorder, UnderlineInputBorder

		final textSelectionTheme = TextSelectionThemeData(
			cursorColor: th.textColor,
			selectionColor: th.differentColor.withAlpha(180),
			selectionHandleColor: th.textColor,
		);

		//Switch & toggle color
		final sw = ColorHelper.isNearColors(th.primaryColor, [Colors.white, Colors.grey[600]!, Colors.grey[900]!])? th.differentColor: th.primaryColor;
		///-------------- themeData ----------------------------------
		final myThemeData = ThemeData(
			visualDensity: VisualDensity.adaptivePlatformDensity,
			applyElevationOverlayColor: true,
			platform: System.getTargetPlatform(),
			pageTransitionsTheme: pageTransition,
			brightness: AppThemes._instance.currentBrightness,
			appBarTheme: appAppBarTheme,
			primaryTextTheme: primaryTextTheme,
			textTheme: primaryTextTheme,
			dialogTheme: dialogTheme,
			buttonBarTheme: const ButtonBarThemeData(buttonTextTheme: ButtonTextTheme.accent),
			iconTheme: iconTheme,
			primaryIconTheme: iconTheme,
			sliderTheme: sliderTheme,
			popupMenuTheme: popupMenu,
			inputDecorationTheme: inputDecoration,
			textSelectionTheme: textSelectionTheme,
			cardTheme: cardTheme,
			textButtonTheme: textButtonTheme,
			elevatedButtonTheme: elevatedButtonTheme,
			outlinedButtonTheme: outlinedButtonTheme,
			//deprecate> buttonTheme: appButtonTheme,
			dataTableTheme: tableThemeData,
			radioTheme: radioThemeData,
			checkboxTheme: checkboxThemeData,
			dividerTheme: dividerTheme,
			primaryColorDark: ColorHelper.darkIfIsLight(th.primaryColor),
			primaryColorLight: ColorHelper.lightPlus(th.primaryColor),
			// canvasColor: drawer & dropDown backColor
			canvasColor: th.drawerBackColor,
			primarySwatch: th.primarySwatch,
			primaryColor: th.primaryColor,
			//accentColor: th.accentColor, use: colorScheme.secondary [this is used for btn if 'primaryColorScheme' not set]
			backgroundColor: th.backgroundColor,
			scaffoldBackgroundColor: th.backgroundColor,
			selectedRowColor: th.accentColor,
			dividerColor: th.dividerColor,
			cardColor: th.cardColor,
			errorColor: th.errorColor,
			hintColor: th.hintColor,
			dialogBackgroundColor: th.dialogBackColor,
			//deprecate> buttonColor: th.buttonsColorScheme.background,
			disabledColor: th.inactiveTextColor,
			toggleableActiveColor: sw,
			splashColor: th.accentColor,
			indicatorColor: th.differentColor,
			secondaryHeaderColor: th.differentColor,
			highlightColor: ColorHelper.changeLight(th.primaryColor),
			bottomAppBarColor: th.appBarBackColor,
			colorScheme: colorScheme,
			chipTheme: chipThemeData,
			scrollbarTheme: scrollbarTheme,
			unselectedWidgetColor: th.hintColor, // color: radio btn
			shadowColor: th.shadowColor,
			hoverColor: th.webHoverColor,
		);

		if (th.executeOnEnd != null) {
		  th.executeOnEnd?.call(myThemeData, th);
		}

		return myThemeData;
	}
	///================================================================================================
	static TextTheme textTheme() {
		return AppThemes._instance.themeData.textTheme;
	}

	static TextStyle appBarTextStyle() {
		final app = AppThemes._instance.themeData.appBarTheme.toolbarTextStyle!;
		return app;//.copyWith(fontSize: app.fontSize! - 3);
	}

	static TextStyle baseTextStyle() {
		return AppThemes._instance.currentTheme.baseTextStyle;
	}

	static TextStyle boldTextStyle() {
		return AppThemes._instance.currentTheme.boldTextStyle;
	}

	static TextStyle subTextStyle() {
		return AppThemes._instance.currentTheme.subTextStyle;
	}

	static TextStyle? body2TextStyle() {
		return AppThemes._instance.themeData.textTheme.bodyText2;
	}

	static TextStyle infoHeadLineTextStyle() {
		return AppThemes._instance.themeData.textTheme.headline5!.copyWith(
			color: AppThemes._instance.themeData.textTheme.headline5!.color!.withAlpha(150),
		);
	}

	static TextStyle infoTextStyle() {
		return AppThemes._instance.themeData.textTheme.headline5!.copyWith(
			color: AppThemes._instance.themeData.textTheme.headline5!.color!.withAlpha(150),
			fontSize: AppThemes._instance.themeData.textTheme.headline5!.fontSize! -2,
			height: 1.5,
		);
		//return currentTheme.baseTextStyle.copyWith(color: currentTheme.infoTextColor);
	}

	static ButtonThemeData buttonTheme() {
		return AppThemes._instance.themeData.buttonTheme;
	}

	static TextStyle? buttonTextStyle() {
		return AppThemes._instance.themeData.textTheme.button;
		//return themeData.elevatedButtonTheme.style!.textStyle!.resolve({MaterialState.focused});
	}

	static Color? buttonTextColor() {
		return buttonTextStyle()?.color;
	}

	static Color? textButtonColor() {
		return AppThemes._instance.themeData.textButtonTheme.style!.foregroundColor!.resolve({MaterialState.selected});
	}

	static Color buttonBackgroundColor() {
		return AppThemes._instance.themeData.elevatedButtonTheme.style!.backgroundColor!.resolve({MaterialState.focused})!;
	}

	static ThemeData dropdownTheme(BuildContext context, {Color? color}) {
		return AppThemes._instance.themeData.copyWith(
			canvasColor: color?? ColorHelper.changeHue(AppThemes._instance.currentTheme.accentColor),
		);
	}

	static BoxDecoration dropdownDecoration({Color? color, double radius = 5}) {
		return BoxDecoration(
				color: color?? ColorHelper.changeHue(AppThemes._instance.currentTheme.accentColor),
				borderRadius: BorderRadius.circular(radius),
		);
	}

	static Color cardColorOnCard() {
		return ColorHelper.changeHSLByRelativeDarkLight(AppThemes._instance.currentTheme.cardColor, 2, 0.0, 0.04);
	}
	///--- Relative ---------------------------------------------------------------------------------------------------
	static bool isDarkPrimary(){
		return ColorHelper.isNearColor(AppThemes._instance.currentTheme.primaryColor, Colors.grey[900]!);
	}

	static bool isLightPrimary(){
		return ColorHelper.isNearColor(AppThemes._instance.currentTheme.primaryColor, Colors.grey[200]!);
	}

	static Color checkPrimaryByWB(Color ifNotNear, Color ifNear){
		return ColorHelper.ifNearColors(AppThemes._instance.currentTheme.primaryColor, [Colors.grey[900]!, Colors.grey[600]!, Colors.white],
				()=> ifNear, ()=> ifNotNear);
	}

	static Color checkColorByWB(Color base, Color ifNotNear, Color ifNear){
		return ColorHelper.ifNearColors(base, [Colors.grey[900]!, Colors.grey[600]!, Colors.white],
				()=> ifNear, ()=> ifNotNear);
	}

	static TextStyle relativeSheetTextStyle() {
		final app = AppThemes._instance.themeData.appBarTheme.toolbarTextStyle!;
		final color = ColorHelper.getUnNearColor(app.color!, AppThemes._instance.currentTheme.primaryColor, Colors.black);

		return app.copyWith(color: color, fontSize: 14);//currentTheme.appBarItemColor
	}

	static Text sheetText(String text) {
		return Text(
			text,
			style: relativeSheetTextStyle(),
		);
	}

	static TextStyle relativeFabTextStyle() {
		final app = AppThemes._instance.themeData.appBarTheme.toolbarTextStyle!;

		return app.copyWith(fontSize: app.fontSize! - 3, color: AppThemes._instance.currentTheme.fabItemColor);
	}

	static Color relativeBorderColor$outButton({bool onColored = false}) {
		if(ColorHelper.isNearColors(AppThemes._instance.currentTheme.primaryColor, [Colors.grey[900]!, Colors.grey[300]!])) {
		  return AppThemes._instance.currentTheme.appBarItemColor;
		} else {
		  return onColored? Colors.white : AppThemes._instance.currentTheme.primaryColor;
		}
	}

	static BorderSide relativeBorderSide$outButton({bool onColored = false}) {
		return BorderSide(width: 1.0, color: relativeBorderColor$outButton(onColored: onColored).withAlpha(140));
	}

	static InputDecoration textFieldInputDecoration({int alpha = 255}) {
		final border = OutlineInputBorder(
				borderSide: BorderSide(color: AppThemes._instance.currentTheme.textColor.withAlpha(alpha))
		);

		return InputDecoration(
			border: border,
			disabledBorder: border,
			enabledBorder: border,
			focusedBorder: border,
			errorBorder: border,
		);
	}
	///------------------------------------------------------------------------------------------------------
	static TextDirection getOppositeDirection() {
		if (AppThemes._instance.textDirection == TextDirection.rtl) {
		  return TextDirection.ltr;
		}

		return TextDirection.rtl;
	}

	static bool isLtrDirection() {
		if (AppThemes._instance.textDirection == TextDirection.ltr) {
		  return true;
		}

		return false;
	}

	static bool isRtlDirection() {
		if (AppThemes._instance.textDirection == TextDirection.rtl) {
		  return true;
		}

		return false;
	}
}
