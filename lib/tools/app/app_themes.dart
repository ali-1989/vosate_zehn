import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/system.dart';

import 'package:app/structures/models/color_theme.dart';
import 'package:app/tools/app/app_decoration.dart';
import '/managers/font_manager.dart';

/// hlp:
/// https://htmlcolorcodes.com/
/// https://colorhunt.co/

/// notes:
/// material library's theme is only supported by the material library widgets and not by RichText. use Text.rich.

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
	/// sets minimum vertical layout metrics
	StrutStyle strutStyle = const StrutStyle(forceStrutHeight: true, height: 1.08, leading: 0.36);

	static AppThemes get instance {
		init();

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

	static void init() {
		if(!_isInit) {
			_isInit = true;

			_instance = AppThemes._();

			_instance.baseFont = Font();
			_instance.boldFont = Font();
			_instance.subFont = Font();

			prepareThemes();
			applyDefaultTheme();
		}
	}

	static void prepareFonts(String language) {
		if(_isInit) {
			_instance.baseFont = FontManager.instance.defaultFontFor(language, FontUsage.normal);
			_instance.boldFont = FontManager.instance.defaultFontFor(language, FontUsage.bold);
			_instance.subFont = FontManager.instance.defaultFontFor(language, FontUsage.sub);
		}
	}

	static void prepareThemes() {
		_instance.themeList.clear();

		{
			final mainTheme = ColorTheme(
					AppDecoration.mainColor, AppDecoration.secondColor,
					AppDecoration.differentColor, Colors.black);

			mainTheme.themeName = 'Main';
			mainTheme.appBarItemColor = Colors.black.withAlpha(180);

			AppThemes._instance.themeList[mainTheme.themeName] = mainTheme;

			/// set default
			AppThemes._instance.defaultTheme = mainTheme;
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
			//primaryColorDark: ColorHelper.darkIfIsLight(th.primaryColor),
			// buttons are use this color for btnText (accentColor)
			accentColor: th.buttonTextColor,
			backgroundColor: th.buttonBackColor,
			errorColor: th.errorColor,
			cardColor: th.cardColor,
			brightness: _instance.currentBrightness,
		);

		final raw = FontManager.instance.rawTextTheme;

		th.baseTextStyle = raw.bodyMedium!.copyWith(
			fontSize: _instance.baseFont.size,
			fontFamily: _instance.baseFont.family,
			height: _instance.baseFont.height,
			color: th.textColor,
		);

		th.subTextStyle = raw.titleMedium!.copyWith(
			fontSize: _instance.subFont.size,
			fontFamily: _instance.subFont.family,
			height: _instance.subFont.height,
			color: th.textColor,
		);

		th.boldTextStyle = raw.displayLarge!.copyWith(
			fontSize: _instance.boldFont.size,
			fontFamily: _instance.boldFont.family,
			height: _instance.boldFont.height,
			color: th.textColor,
		);

		th.textUnderlineStyle = th.textUnderlineStyle.copyWith(
			fontSize: _instance.baseFont.size,
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
		final height = th.baseTextStyle.height?? 1.0;
		final raw = FontManager.instance.rawThemeData;
		TextTheme primaryTextTheme;

		if(FontManager.useFlutterFontSize){
			primaryTextTheme = TextTheme(
				bodyLarge: raw.textTheme.bodyLarge!.copyWith(
					fontFamily: baseFamily, color: th.textColor, height: height,
				),
				bodyMedium: raw.textTheme.bodyMedium!.copyWith(
					fontFamily: baseFamily, color: th.textColor, height: height,
				),
				bodySmall: raw.textTheme.bodySmall!.copyWith(
					fontFamily: subFamily, color: th.textColor, height: height,
				),
				titleLarge: raw.textTheme.titleLarge!.copyWith(
					fontFamily: baseFamily, color: th.appBarItemColor, fontWeight: FontWeight.bold, height: height,
				),
				titleMedium: raw.textTheme.titleMedium!.copyWith(
					fontFamily: baseFamily, color: th.textColor, height: height,
				),
				titleSmall: raw.textTheme.titleSmall!.copyWith(
					fontFamily: subFamily, color: th.textColor, height: height,
				),
				displayLarge: raw.textTheme.displayLarge!.copyWith(
					fontFamily: boldFamily, color: th.textColor, height: height,
				),
				displayMedium: raw.textTheme.displayMedium!.copyWith(
					fontFamily: boldFamily, color: th.textColor, height: height,
				),
				displaySmall: raw.textTheme.displaySmall!.copyWith(
					fontFamily: boldFamily, color: th.textColor, height: height,
				),
				headlineMedium: raw.textTheme.headlineMedium!.copyWith(
					fontFamily: baseFamily, color: th.textColor, height: height,
				),
				headlineSmall: raw.textTheme.headlineSmall!.copyWith(
					fontFamily: baseFamily, color: th.textColor, height: height,
				),
				labelLarge: raw.textTheme.labelLarge!.copyWith(
					fontFamily: boldFamily, color: th.buttonTextColor, height: height,
				),
				labelSmall: raw.textTheme.labelSmall!.copyWith(
					fontFamily: subFamily, color: th.textColor, height: height,
				),
			);
		}
		else {
			final fontSize = _instance.baseFont.size ?? FontManager.instance.getPlatformFont().size?? FontManager.defaultFontSize;

			primaryTextTheme = TextTheme(
				bodyLarge: raw.textTheme.bodyLarge!.copyWith(
					fontFamily: baseFamily, color: th.textColor, fontSize: fontSize +1, height: height,
				),
				bodyMedium: raw.textTheme.bodyMedium!.copyWith(
					fontFamily: baseFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				bodySmall: raw.textTheme.bodySmall!.copyWith(
					fontFamily: subFamily, color: th.textColor, fontSize: fontSize-1, height: height,
				),
				titleLarge: raw.textTheme.titleLarge!.copyWith(
					fontFamily: baseFamily, color: th.appBarItemColor, fontSize: fontSize +3, height: height,
					fontWeight: FontWeight.bold,
				),
				titleMedium: raw.textTheme.titleMedium!.copyWith(
					fontFamily: baseFamily, color: th.textColor, fontSize: fontSize +2, height: height,
				),
				titleSmall: raw.textTheme.titleSmall!.copyWith(
					fontFamily: subFamily, color: th.textColor, fontSize: fontSize +1, height: height,
				),
				displayLarge: raw.textTheme.displayLarge!.copyWith(
					fontFamily: boldFamily, color: th.textColor, fontSize: fontSize +2, height: height,
				),
				displayMedium: raw.textTheme.displayMedium!.copyWith(
					fontFamily: boldFamily, color: th.textColor, fontSize: fontSize +1, height: height,
				),
				displaySmall: raw.textTheme.displaySmall!.copyWith(
					fontFamily: boldFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				headlineMedium: raw.textTheme.headlineMedium!.copyWith(
					fontFamily: baseFamily, color: th.textColor, fontSize: fontSize +1, height: height,
				),
				headlineSmall: raw.textTheme.headlineSmall!.copyWith(
					fontFamily: baseFamily, color: th.textColor, fontSize: fontSize, height: height,
				),
				labelLarge: raw.textTheme.labelLarge!.copyWith(
					fontFamily: boldFamily, color: th.buttonTextColor, fontSize: fontSize -1, height: height,
				),
				labelSmall: raw.textTheme.labelSmall!.copyWith(
					fontFamily: subFamily, color: th.textColor, fontSize: fontSize -2, height: height,
				),
			);
		}


		final chipTextColor = AppDecoration.chipTextColor();

		final chipThemeData = raw.chipTheme.copyWith(//ThemeData();
			brightness: AppThemes._instance.currentBrightness,
			backgroundColor: AppDecoration.chipColor(),
			checkmarkColor: chipTextColor,
			deleteIconColor: chipTextColor,
			selectedColor: th.differentColor,
			disabledColor: th.inactiveTextColor,
			shadowColor: th.shadowColor,
			labelStyle: th.subTextStyle.copyWith(color: chipTextColor),
			elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 0.0: 1.0,
			padding: const EdgeInsets.all(0.0),
		);

		final scrollbarTheme = const ScrollbarThemeData().copyWith(
			thumbColor: MaterialStateProperty.all(
					AppDecoration.checkPrimaryByWB(th.primaryColor.withAlpha(80), th.differentColor.withAlpha(80))
			),
		);

		final iconTheme = raw.iconTheme.copyWith(
				color: th.textColor,
		);

		final appAppBarTheme = AppBarTheme(
			toolbarTextStyle: primaryTextTheme.titleLarge,
			iconTheme: iconTheme.copyWith(color: th.appBarItemColor),
			foregroundColor: th.appBarItemColor,
			actionsIconTheme: iconTheme.copyWith(color: th.appBarItemColor),
			systemOverlayStyle: AppThemes._instance.currentBrightness == Brightness.light? SystemUiOverlayStyle.light: SystemUiOverlayStyle.dark,
			centerTitle: true,
			elevation: 1.0,
			color: th.appBarBackColor,
			shadowColor: th.shadowColor,
		);

		final bottomAppAppBarTheme = BottomAppBarTheme(
			elevation: 1.0,
			color: th.appBarBackColor,
			surfaceTintColor: th.appBarBackColor.withAlpha(40),
		);

		final dialogTheme = DialogTheme(
				elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 1.0: 5.0,
				titleTextStyle: th.baseTextStyle.copyWith(color: th.dialogTextColor, fontWeight: FontWeight.w700),
				contentTextStyle: th.baseTextStyle.copyWith(color: th.dialogTextColor),
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
			overlayColor: kIsWeb? Colors.transparent : th.errorColor,
			valueIndicatorColor: th.infoColor,
		);

		final popupMenu = PopupMenuThemeData(
			elevation: ColorHelper.isNearLightness(th.primaryColor, Colors.black)? 0.0: 4.0,
			color: th.drawerBackColor,
			textStyle: th.baseTextStyle.copyWith(height: 1.1),
		);

		final colorScheme = ColorScheme.fromSwatch(
		primarySwatch: th.primarySwatch,
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

		const buttonTheme = ButtonThemeData(
		);

		const iconButtonTheme = IconButtonThemeData(
			style: ButtonStyle(
				//minimumSize: kIsWeb? MaterialStateProperty.all(Size(20, 45)): null,
			),
		);

		final buttonBorder = MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))));

		final elevatedButtonTheme = ElevatedButtonThemeData(
			style: ButtonStyle(
				shape: buttonBorder,
				//padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 8)),
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
						AppDecoration.checkPrimaryByWB(th.primaryColor, th.differentColor).withAlpha(100)
				),
			),
		);

		final outlinedButtonTheme = OutlinedButtonThemeData(
			style: ButtonStyle(
				tapTargetSize: MaterialTapTargetSize.shrinkWrap,
				//backgroundColor: MaterialStateProperty.all(th.buttonBackColor),
				foregroundColor: MaterialStateProperty.all(th.textColor),
				shape: buttonBorder,
			),
		);

		final tableThemeData = DataTableThemeData(
			dataRowColor: MaterialStateProperty.all(th.primaryColor),
			headingRowColor: MaterialStateProperty.all(th.differentColor),
			dataTextStyle: primaryTextTheme.bodySmall,
		);

		final radioThemeData = RadioThemeData(
			fillColor: MaterialStateProperty.all(AppDecoration.checkPrimaryByWB(th.primaryColor, th.differentColor)),
			overlayColor: MaterialStateProperty.all(th.differentColor),
			materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
			visualDensity: VisualDensity.comfortable,
		);

		final checkboxThemeData = CheckboxThemeData(
			fillColor: MaterialStateProperty.all(AppDecoration.checkPrimaryByWB(th.primaryColor, th.differentColor)),
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
			errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.errorColor)),
			focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: th.errorColor)),
		); ///OutlineInputBorder, UnderlineInputBorder

		final textSelectionTheme = TextSelectionThemeData(
			cursorColor: th.textColor,
			selectionColor: th.differentColor.withAlpha(180),
			selectionHandleColor: th.textColor,
		);
		
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
			iconButtonTheme: iconButtonTheme,
			buttonTheme: buttonTheme,
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
			scaffoldBackgroundColor: th.backgroundColor,
			dividerColor: th.dividerColor,
			cardColor: th.cardColor,
			hintColor: th.hintColor,
			dialogBackgroundColor: th.dialogBackColor,
			//deprecate> buttonColor: th.buttonsColorScheme.background,
			disabledColor: th.inactiveTextColor,
			splashColor: th.accentColor,
			indicatorColor: th.differentColor,
			secondaryHeaderColor: th.differentColor,
			highlightColor: ColorHelper.changeLight(th.primaryColor),
			bottomAppBarTheme: bottomAppAppBarTheme,
			colorScheme: colorScheme,
			chipTheme: chipThemeData,
			scrollbarTheme: scrollbarTheme,
			unselectedWidgetColor: th.hintColor, // color: radioButton
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

	static TextStyle baseTextStyle() {
		return AppThemes._instance.currentTheme.baseTextStyle;
	}

	static TextStyle boldTextStyle() {
		return AppThemes._instance.currentTheme.boldTextStyle;
	}

	static TextStyle subTextStyle() {
		return AppThemes._instance.currentTheme.subTextStyle;
	}

	static Color buttonBackgroundColor() {
		return AppThemes.instance.themeData.elevatedButtonTheme.style!.backgroundColor!.resolve({MaterialState.focused})!;
	}

	static TextDirection getOppositeDirection() {
		if (AppThemes._instance.textDirection == TextDirection.rtl) {
		  return TextDirection.ltr;
		}

		return TextDirection.rtl;
	}

	static TextAlign getTextAlign() {
		if (AppThemes._instance.textDirection == TextDirection.rtl) {
		  return TextAlign.left;
		}

		return TextAlign.right;
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
