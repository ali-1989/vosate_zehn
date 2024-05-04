enum UiStates {
  normal(1),
  loading(2),
  error(3),
  noData(4);

  final int _id;

  const UiStates(this._id);

  factory UiStates.from(dynamic data) {
    if(data == null){
      return UiStates.normal;
    }

    if(data is String) {
      return values.firstWhere((e) => e.name == data, orElse: ()=> UiStates.normal);
    }

    if(data is int) {
      return values.firstWhere((e) => e._id == data, orElse: ()=> UiStates.normal);
    }

    return UiStates.normal;
  }

  int id(){
    return _id;
  }
}