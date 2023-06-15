
class GlobalSettingsModel {
  String? aidPopMessage;
  int aidRepeatDays = 30;

  GlobalSettingsModel();

  GlobalSettingsModel.fromMap(Map map) {
    aidPopMessage = map['aid_pop_message'];
    aidRepeatDays = map['aid_pop_repeat_days']?? 30;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['aid_pop_message'] = aidPopMessage;
    map['aid_pop_repeat_days'] = aidRepeatDays;

    return map;
  }

  void matchBy(GlobalSettingsModel others){
    aidPopMessage = others.aidPopMessage;
    aidRepeatDays = others.aidRepeatDays;
  }
}
