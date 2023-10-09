// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/calendarTools.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/system/extensions.dart';
import '/managers/settings_manager.dart';

enum DateFormat {
  yyyyMmDd('YYYY/MM/DD'),
  yyMmDd('YY/MM/DD'),
  yyyyNnYd('YYYY/NN /DD'),
  yyNnDd('YY/NN /DD'),
  mmDdYyyy('MM/DD/YYYY'),
  nnDdYyyy('NN /DD/YYYY'),
  mmDdYy('MM/DD/YY'),
  nnDdYy('NN /DD/YY');

  final String _format;

  const DateFormat(this._format);

  String format(){
    return _format;
  }

  static DateFormat? fromName(String name){
    for(final t in DateFormat.values){
      if(t.name == name){
        return t;
      }
    }

    return null;
  }

  static DateFormat? fromFormat(String format) {
    for (final t in DateFormat.values) {
      if (t._format == format) {
        return t;
      }
    }

    return null;
  }
}
///===================================================================================
class DateTools {
  DateTools._();

  static List<CalendarType> calendarList = [
    CalendarType.gregorian,
    CalendarType.solarHijri,
  ];

  static String dateRelativeByAppFormat(DateTime? date, {bool isUtc = true, String? format}){
    if(date == null) {
      return '';
    }

    format ??= SettingsManager.localSettings.dateFormat;
    ADateStructure mDate;

    if(SettingsManager.localSettings.calendarType == CalendarType.solarHijri){
      mDate = SolarHijriDate.from(date);
    }
    else {
      mDate = GregorianDate.from(date);
    }

    if(isUtc) {
      mDate.attachTimeZone('utc');
      mDate.moveUtcToLocal();
    }

    return LocaleHelper.overrideLtr(mDate.format(format, 'en').localeNum());
  }

  static String dateOnlyRelative$String(String date, {bool isUtc = true}){
    return dateRelativeByAppFormat(DateHelper.timestampToSystem(date)!, isUtc: isUtc);
  }

  static String dateOnlyRelative(DateTime? date, {bool isUtc = true}){
    return dateRelativeByAppFormat(date, isUtc: isUtc);
  }

  static String dateAndHmRelative(DateTime? date, {bool isUtc = true}){
    if(date == null) {
      return '';
    }

    ADateStructure mDate;

    if(SettingsManager.localSettings.calendarType == CalendarType.solarHijri){
      mDate = SolarHijriDate.from(date);
    }
    else {
      mDate = GregorianDate.from(date);
    }

    if(isUtc) {
      mDate.attachTimeZone('UTC');
      mDate.moveUtcToLocal();
    }

    return LocaleHelper.overrideLtr(mDate.format('${SettingsManager.localSettings.dateFormat} HH:mm', 'en')
        .localeNum());
  }

  static String dateAndHmRelative$String(String date, {bool isUtc = true}){
    return dateAndHmRelative(DateHelper.timestampToSystem(date), isUtc: isUtc);
  }

  static String ymOnlyRelative(DateTime? date, {bool isUtc = true}){
    if(date == null) {
      return '';
    }

    ADateStructure mDate;

    if(SettingsManager.localSettings.calendarType == CalendarType.solarHijri){
      mDate = SolarHijriDate.from(date);
    }
    else {
      mDate = GregorianDate.from(date);
    }

    if(isUtc) {
      mDate.attachTimeZone('UTC');
      mDate.moveUtcToLocal();
    }

    return LocaleHelper.overrideLtr(mDate.format('YYYY/MM', 'en').localeNum());
  }

  static String hmOnlyRelative(DateTime? date, {bool isUtc = true}){
    if(date == null) {
      return '';
    }

    ADateStructure mDate;

    if(SettingsManager.localSettings.calendarType == CalendarType.solarHijri){
      mDate = SolarHijriDate.from(date);
    }
    else {
      mDate = GregorianDate.from(date);
    }

    if(isUtc) {
      mDate.attachTimeZone('UTC');
      mDate.moveUtcToLocal();
    }

    return LocaleHelper.overrideLtr(mDate.format('HH:mm', 'en').localeNum());
  }

  static String dateHmOnlyRelative$String(String? date, {bool isUtc = true}){
    return hmOnlyRelative(DateHelper.timestampToSystem(date), isUtc: isUtc);
  }
  ///---------------------------------------------------------------------------------------
  static Future saveAppCalendar(CalendarType calendarType, {BuildContext? context}) {
    SettingsManager.localSettings.calendarType = calendarType;
    return SettingsManager.saveLocalSettingsAndNotify();
  }

  static Future saveAppCalendarByName(String calName, {BuildContext? context}) {
    final cal = CalendarTypeHelper.calendarTypeFrom(calName);
    return saveAppCalendar(cal, context: context);
  }

  static DateTime? getDateByCalendar(int year, int month, int day, {int hour = 0, int minutes = 0, CalendarType? calendarType}){
    return getADateByCalendar(year, month, day, hour: hour, minutes: minutes, calendarType: calendarType)?.convertToSystemDate();
  }

  static ADateStructure? getADateByCalendar(int year, int month, int day, {int hour = 0, int minutes = 0, CalendarType? calendarType}){
    switch(calendarType?? SettingsManager.localSettings.calendarType){
      case CalendarType.gregorian:
        return GregorianDate.hm(year, month, day, hour, minutes);
      case CalendarType.solarHijri:
        return SolarHijriDate.hm(year, month, day, hour, minutes);
      case CalendarType.unKnow:
        return null;
    }
  }

  static int calMaxMonthDay(int year, int month, {CalendarType? calendarType}){
    ADateStructure? ad;

    switch(calendarType?? SettingsManager.localSettings.calendarType){
      case CalendarType.gregorian:
        ad = GregorianDate();
        break;
      case CalendarType.solarHijri:
        ad = SolarHijriDate();
        break;
      case CalendarType.unKnow:
        break;
    }

    return ad!.getLastDayOfMonthFor(year, month);
  }

  static ADateStructure? convertToADateByCalendar(DateTime date, {CalendarType? calendarType}){
    switch(calendarType?? SettingsManager.localSettings.calendarType){
      case CalendarType.gregorian:
        return GregorianDate.from(date);
      case CalendarType.solarHijri:
        return SolarHijriDate.from(date);
      case CalendarType.unKnow:
        return null;
    }
  }

  static List<int> splitDateByCalendar(DateTime date, {CalendarType? calendarType}){
    final res = <int>[0,0,0];

    if((calendarType?? SettingsManager.localSettings.calendarType) == CalendarType.gregorian) {
      res[0] = date.year;
      res[1] = date.month;
      res[2] = date.day;
    }

    final c = convertToADateByCalendar(date, calendarType: calendarType)!;
    res[0] = c.getYear();
    res[1] = c.getMonth();
    res[2] = c.getDay();

    return res;
  }
  ///---------------------------------------------------------------------------------------
  static int calMinBirthdateYear({CalendarType? calendarType}){
    switch(calendarType?? SettingsManager.localSettings.calendarType){
      case CalendarType.gregorian:
        return DateTime.now().year-90;
      case CalendarType.solarHijri:
        return SolarHijriDate().getYear()-90;
      default:
        return DateTime.now().year-100;
    }
  }

  static int calMaxBirthdateYear({CalendarType? calendarType}){
    switch(calendarType?? SettingsManager.localSettings.calendarType){
      case CalendarType.gregorian:
        return DateTime.now().year-7;
      case CalendarType.solarHijri:
        return SolarHijriDate().getYear()-7;
      default:
        return DateTime.now().year;
    }
  }
}
