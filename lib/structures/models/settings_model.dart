import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/calendarTools.dart';

import 'package:app/managers/font_manager.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/date_tools.dart';

class SettingsModel {
  // http://192.168.43.140, 1.103
  static const defaultHttpAddress = 'http://vosatezehn.com:7436';
  static const defaultWsAddress = 'ws://vosatezehn.com:7438/ws';
  static const Locale defaultAppLocale = Locale('fa', 'IR');
  static const CalendarType defaultCalendarType = CalendarType.solarHijri;
  static final defaultDateFormat = DateFormat.yyyyMmDd.format();
  static int webSocketPeriodicHeartMinutes = 3;
  static int drawerMenuTimeMill = 350;

  /// must for any record ,create a file in assets/locales directory
  static List<Locale> locals = [
    SettingsModel.defaultAppLocale,
    //const Locale('fa', 'IR'),
  ];

  String? lastUserId;
  Locale appLocale = defaultAppLocale;
  CalendarType calendarType = defaultCalendarType;
  String dateFormat = defaultDateFormat;
  String? colorTheme;
  String? lastToBackgroundTs;
  bool confirmOnExit = true;
  String httpAddress = defaultHttpAddress;
  String wsAddress = defaultWsAddress;
  Orientation? appRotationState; // null: free
  int? currentVersion;
  bool notificationDailyText = true;


  SettingsModel();

  SettingsModel.fromMap(Map map){
    final localeMap = map['app_locale'];

    if(localeMap != null){
      appLocale = Locale(localeMap[Keys.languageIso], localeMap[Keys.countryIso]);
    }

    lastUserId = map['last_user_id'];
    calendarType = CalendarTypeHelper.calendarTypeFrom(map['calendar_type_name']);
    dateFormat = map['date_format']?? defaultDateFormat;
    colorTheme = map[Keys.setting$colorThemeName];
    confirmOnExit = map[Keys.setting$confirmOnExit]?? true;
    httpAddress = map['http_address']?? defaultHttpAddress;
    wsAddress = map['ws_address']?? defaultWsAddress;
    currentVersion = map[Keys.setting$currentVersion];
    notificationDailyText = map[Keys.setting$notificationDailyText]?? true;
    ///-- Lock
    {
      //lockApp = map[Keys.setting$lockApp] ?? false;
      //unLockByBiometric = map[Keys.setting$unLockByBiometric] ?? false;
      //unLockByNumber = map[Keys.setting$unLockByNumber] ?? false;
      //appNumberLock = map[Keys.setting$numberLock];
      lastToBackgroundTs = map[Keys.setting$toBackgroundTs];
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['last_user_id'] = lastUserId;
    map['app_locale'] = {Keys.languageIso: appLocale.languageCode, Keys.countryIso: appLocale.countryCode};
    map['calendar_type_name'] = calendarType.name;
    map['date_format'] = dateFormat;
    map[Keys.setting$colorThemeName] = colorTheme;
    map[Keys.setting$toBackgroundTs] = lastToBackgroundTs;
    map[Keys.setting$confirmOnExit] = confirmOnExit;
    map[Keys.setting$currentVersion] = currentVersion;
    map['http_address'] = httpAddress;
    map['ws_address'] = wsAddress;
    map[Keys.setting$notificationDailyText] = notificationDailyText;

    return map;
  }

  void matchBy(SettingsModel other) {
    lastUserId = other.lastUserId;
    appLocale = other.appLocale;
    calendarType = other.calendarType;
    dateFormat = other.dateFormat;
    colorTheme = other.colorTheme;
    confirmOnExit = other.confirmOnExit;
    lastToBackgroundTs = other.lastToBackgroundTs;
    httpAddress = other.httpAddress;
    wsAddress = other.wsAddress;
    notificationDailyText = other.notificationDailyText;
  }

  @override
  String toString(){
    return toMap().toString();
  }
}
