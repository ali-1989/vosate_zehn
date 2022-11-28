
class AppParameterModel {
  String? aidPopMessage;
  int aidRepeatDays = 10;

  AppParameterModel();

  AppParameterModel.fromMap(Map map) {
    aidPopMessage = map['aid_pop_message'];
    aidRepeatDays = map['aid_pop_repeat_days']?? 10;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['aid_pop_message'] = aidPopMessage;
    map['aid_pop_repeat_days'] = aidRepeatDays;

    return map;
  }
}
