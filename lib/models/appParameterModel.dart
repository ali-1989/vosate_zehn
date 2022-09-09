
class AppParameterModel {
  String? aidPopMessage;

  AppParameterModel();

  AppParameterModel.fromMap(Map map) {
    aidPopMessage = map['aid_pop_message'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['aid_pop_message'] = aidPopMessage;

    return map;
  }
}
