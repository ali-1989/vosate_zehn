enum UserType {
  guest(0),
  common(1),
  admin(9);

  final int _id;

  const UserType(this._id);

  static UserType from(dynamic data){
    if(data == null){
      return UserType.common;
    }

    if(data is String) {
      values.firstWhere((e) => e.name == data, orElse: ()=> UserType.common);
    }

    if(data is int) {
      values.firstWhere((e) => e._id == data, orElse: ()=> UserType.common);
    }

    return UserType.common;
  }

  int id(){
    return _id;
  }
}