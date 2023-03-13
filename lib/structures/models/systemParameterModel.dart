
class SystemParameterModel {
  String? aidPopMessage;
  int aidRepeatDays = 30;

  SystemParameterModel();

  SystemParameterModel.fromMap(Map map) {
    aidPopMessage = map['aid_pop_message'];
    aidRepeatDays = map['aid_pop_repeat_days']?? 30;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['aid_pop_message'] = aidPopMessage;
    map['aid_pop_repeat_days'] = aidRepeatDays;

    return map;
  }
}