import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'package:app/system/constants.dart';
import 'package:app/tools/app/app_themes.dart';

class NotificationSettingsModel {
  String channelId = '${Constants.appName}_channel';
  String groupId = '${Constants.appName}_group';
  bool enableLights = true;
  bool enableVibration = true;
  bool playSound = true;
  bool showBadge = true;
  bool isPublic = true;
  ImportanceTypes importance = ImportanceTypes.defaultImportance;
  Color defaultColor = AppThemes.instance.currentTheme.successColor;
  Color ledColor = AppThemes.instance.currentTheme.successColor;

  NotificationSettingsModel.fromMap(Map? map){
    if(map == null){
      return;
    }

    channelId = map['channel_id']?? '${Constants.appName}_channel';
    groupId = map['group_id']?? '${Constants.appName}_group';
    enableLights = map['enable_lights']?? true;
    enableVibration = map['enable_vibration']?? true;
    playSound = map['play_sound']?? true;
    showBadge = map['show_badge']?? true;
    isPublic = map['is_public']?? true;
    importance = ImportanceTypes.from(map['importance']);

    if(map['default_color'] != null){
      defaultColor = Color(map['default_color']);
    }
    else {
      defaultColor = AppThemes.instance.currentTheme.successColor;
    }

    if(map['led_color'] != null){
      ledColor = Color(map['led_color']);
    }
    else {
      ledColor = AppThemes.instance.currentTheme.successColor;
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['channel_id'] = channelId;
    map['group_id'] = groupId;
    map['enable_lights'] = enableLights;
    map['enable_vibration'] = enableVibration;
    map['play_sound'] = playSound;
    map['show_badge'] = showBadge;
    map['is_public'] = isPublic;
    map['importance'] = importance.id();
    map['default_color'] = defaultColor.value;
    map['led_color'] = ledColor.value;

    return map;
  }
}
///=============================================================================
enum ImportanceTypes {
  defaultImportance(1),
  low(2),
  high(3),
  max(4);

  final int _id;

  const ImportanceTypes(this._id);

  factory ImportanceTypes.from(dynamic data){
    if(data == null){
      return defaultImportance;
    }

    if(data is String){
      return values.firstWhere((element) => element.name == data, orElse: ()=> defaultImportance);
    }

    if(data is int){
      return values.firstWhere((element) => element._id == data, orElse: ()=> defaultImportance);
    }

    return defaultImportance;
  }

  int id(){
    return _id;
  }

  NotificationImportance getImportance(){
    switch(_id){
      case 1:
        return NotificationImportance.Default;
      case 2:
        return NotificationImportance.Low;
      case 3:
        return NotificationImportance.High;
      case 4:
        return NotificationImportance.Max;
    }

    return NotificationImportance.Default;
  }
}