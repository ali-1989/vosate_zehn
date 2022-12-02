import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/calendarTools.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:app/managers/settingsManager.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/dateTools.dart';

typedef OnSelect = void Function(DateTime dateTime);
typedef OnChange = Widget? Function(DateTime dateTime);
///================================================================================================
class SelectDateCalendarView extends StatefulWidget {
  final String? title;
  final String? buttonText;
  final Color? iconColor;
  final TextStyle? textStyle;
  final DateTime? currentDate;
  final int? maxYearAsGregorian;
  final int? minYearAsGregorian;
  final bool showButton;
  final bool showCalendar;
  final bool lockYear;
  final bool lockMonth;
  final bool lockDay;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final OnSelect? onSelect;
  final OnChange? onChange;

  SelectDateCalendarView({
    this.title,
    this.buttonText,
    this.currentDate,
    this.maxYearAsGregorian,
    this.minYearAsGregorian,
    this.onSelect,
    this.showButton = true,
    this.showCalendar = true,
    this.lockYear = false,
    this.lockMonth = false,
    this.lockDay = false,
    this.iconColor,
    this.borderRadius,
    this.border,
    this.textStyle,
    this.onChange,
    Key? key,
    }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectDateCalendarViewState();
  }
}
///==============================================================================================
class SelectDateCalendarViewState extends State<SelectDateCalendarView> {
  late DateTime curDate;
  late ADateStructure curDateRelative;
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;
  late int maxDayOfMonth;
  late int maxOfYear;
  late int minOfYear;
  Widget? messageView;
  late TextStyle titleStyle;
  ScrollController scrollCtr = ScrollController();


  @override
  void initState() {
    super.initState();

    titleStyle = widget.textStyle?? TextStyle(color: AppThemes.instance.currentTheme.textColor);
    curDate = widget.currentDate?? DateTime.now();

    curDateRelative = DateTools.convertToADateByCalendar(curDate)!;
    final toDay = DateTools.convertToADateByCalendar(DateTime.now())!;

    if(widget.maxYearAsGregorian != null){
      final d = DateTime(widget.maxYearAsGregorian!, 12, 1);
      maxOfYear = DateTools.convertToADateByCalendar(d)!.getYear();
    }
    else {
      maxOfYear = toDay.getYear() +1;
    }

    if(widget.minYearAsGregorian != null){
      final d = DateTime(widget.minYearAsGregorian!, 1, 1);
      minOfYear = DateTools.convertToADateByCalendar(d)!.getYear();
    }
    else {
      final cDate = DateTools.convertToADateByCalendar(curDate)!;
      minOfYear = MathHelper.minInt(toDay.getYear(), cDate.getYear());
    }

    selectedYear = curDateRelative.getYear();
    selectedMonth = curDateRelative.getMonth();
    selectedDay = curDateRelative.getDay();
    maxDayOfMonth = curDateRelative.getLastDayOfMonthFor(selectedYear, selectedMonth);

    messageView = widget.onChange?.call(curDate);

    if(selectedYear > maxOfYear){
      selectedYear = maxOfYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    //Color itemColor = iconColor?? AppThemes.currentTheme.textColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppThemes.instance.currentTheme.backgroundColor,
        borderRadius: widget.borderRadius,
        border: widget.border,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: widget.showButton || widget.showCalendar,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: widget.showButton,
                    child: TextButton(
                      child: Text('${widget.buttonText?? context.t('select')}'),
                      onPressed: (){
                        onButtonClick();
                      },
                    ),
                  ),

                  Visibility(
                    visible: widget.showCalendar,
                    child: SizedBox(
                      height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              //borderRadius: BorderRadius.circular(10),
                              dropdownColor: Colors.grey[400],
                              value: SettingsManager.settingsModel.calendarType,
                              onChanged: (newValue) {
                                changeCalendar(newValue as CalendarType);

                                setState(() {});
                              },
                              items: DateTools.calendarList.map((cal) => DropdownMenuItem(
                                value: cal,
                                child: Text('${context.tInMap('calendarOptions', cal.name)}'),
                              ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 5),
          Row(
            children: [
              Visibility(
                visible: messageView != null,
                child: Column(
                  children: [
                    messageView?? SizedBox(),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),

          Scrollbar(
            thumbVisibility: true,
            controller: scrollCtr,
            child: ListView(
              shrinkWrap: true,
              controller: scrollCtr,
              children: [
                Visibility(
                  visible: widget.title != null,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Text('${widget.title}', style: titleStyle),
                  ),
                ),

                const SizedBox(height: 20,),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: SizedBox(
                    height: AppSizes.instance.fwSize(120),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IgnorePointer(
                          ignoring: widget.lockYear,
                          child: NumberPicker(
                            minValue: minOfYear,
                            maxValue: maxOfYear,
                            value: selectedYear,
                            axis: Axis.vertical,
                            haptics: true,
                            zeroPad: true,
                            itemWidth: 50,
                            itemHeight: 40,
                            textStyle: AppThemes.baseTextStyle().copyWith(
                              fontSize: AppSizes.fwFontSize(16),
                              fontWeight: FontWeight.bold,
                            ),
                            selectedTextStyle: TextStyle(
                              fontSize: AppSizes.fwFontSize(16),
                              fontWeight: FontWeight.bold,
                              color: AppThemes.instance.currentTheme.activeItemColor,
                            ),
                            textMapper: (t){
                              return t.toString().localeNum();
                            },
                            onChanged: (val){
                              selectedYear = val;
                              final max = DateTools.calMaxMonthDay(selectedYear, selectedMonth);

                              if((maxDayOfMonth - max).abs() > 1){
                                selectedDay = MathHelper.backwardStepInRing(selectedDay, 1, max, true);
                              }

                              calcDate();

                              setState(() {});
                            },
                          ),
                        ),

                        ///--- month
                        IgnorePointer(
                          ignoring: widget.lockMonth,
                          child: NumberPicker(
                            minValue: 1,
                            maxValue: 12,
                            value: selectedMonth,
                            axis: Axis.vertical,
                            haptics: true,
                            zeroPad: true,
                            infiniteLoop: true,
                            itemWidth: 40,
                            itemHeight: 40,
                            textStyle: AppThemes.baseTextStyle().copyWith(
                              fontSize: AppSizes.fwFontSize(15),
                              fontWeight: FontWeight.bold,
                            ),
                            selectedTextStyle: TextStyle(
                              fontSize: AppSizes.fwFontSize(16),
                              fontWeight: FontWeight.bold,
                              color: AppThemes.instance.currentTheme.activeItemColor,//AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor),
                            ),
                            textMapper: (t){
                              return t.toString().localeNum();
                            },
                            onChanged: (val){
                              selectedMonth = val;
                              final max = DateTools.calMaxMonthDay(selectedYear, selectedMonth);

                              if((maxDayOfMonth - max).abs() > 1){
                                selectedDay = MathHelper.backwardStepInRing(selectedDay, 1, max, true);
                              }
                              calcDate();

                              setState(() {});
                            },
                          ),
                        ),

                        ///--- day
                        IgnorePointer(
                          ignoring: widget.lockDay,
                          child: NumberPicker(
                            minValue: 1,
                            maxValue: maxDayOfMonth,
                            value: selectedDay,
                            axis: Axis.vertical,
                            haptics: true,
                            zeroPad: true,
                            infiniteLoop: true,
                            itemWidth: 40,
                            itemHeight: 40,
                            textStyle: AppThemes.baseTextStyle().copyWith(
                              fontSize: AppSizes.fwFontSize(15),
                              fontWeight: FontWeight.bold,
                            ),
                            selectedTextStyle: TextStyle(
                              fontSize: AppSizes.fwFontSize(16),
                              fontWeight: FontWeight.bold,
                              color: AppThemes.instance.currentTheme.activeItemColor,//AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor),
                            ),
                            textMapper: (t){
                              return t.toString().localeNum();
                            },
                            onChanged: (val){
                              selectedDay = val;
                              calcDate();

                              setState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  void onButtonClick(){
    ADateStructure date = DateTools.getADateByCalendar(selectedYear, selectedMonth, selectedDay)!;

    if(!date.isValidDate()){
      AppSnack.showError(context, context.tInMap('dateSection', 'dateIsNotValid')!);
      return;
    }

    final sd = date.convertToSystemDate();

    if(widget.onSelect != null) {
      widget.onSelect?.call(sd);
    }
    else {
      AppNavigator.pop(context, result: sd);
    }
  }

  void calcDate(){
    maxDayOfMonth = DateTools.calMaxMonthDay(selectedYear, selectedMonth);

    if(selectedDay > maxDayOfMonth){
      selectedDay = maxDayOfMonth;
    }

    curDate = DateTools.getDateByCalendar(selectedYear, selectedMonth, selectedDay)!;

    messageView = widget.onChange?.call(curDate);
  }

  void changeCalendar(CalendarType cal){
    DateTools.saveAppCalendar(cal);

    final list = DateTools.splitDateByCalendar(curDate);
    selectedYear = list[0];
    selectedMonth = list[1];
    selectedDay = list[2];

    curDateRelative = DateTools.convertToADateByCalendar(curDate)!;
    maxDayOfMonth = DateTools.calMaxMonthDay(selectedYear, selectedMonth);
    final toDay = DateTools.convertToADateByCalendar(DateTime.now())!;

    if(widget.maxYearAsGregorian != null){
      final d = DateTime(widget.maxYearAsGregorian!, 12, 1);
      maxOfYear = DateTools.convertToADateByCalendar(d)!.getYear();
    }
    else {
      maxOfYear = toDay.getYear() +1;
    }

    if(widget.minYearAsGregorian != null){
      final d = DateTime(widget.minYearAsGregorian!, 1, 1);
      minOfYear = DateTools.convertToADateByCalendar(d)!.getYear();
    }
    else {
      minOfYear = toDay.getYear();
    }

    if(selectedYear > maxOfYear){
      selectedYear = maxOfYear;
    }
  }
}
