enum UserType {
  guest(0),
  common(1),
  admin(9);

  final int _type;

  const UserType(this._type);

  static UserType from(int type){
    for(final k in UserType.values){
      if(k._type == type){
        return k;
      }
    }

    return UserType.common;
  }

  int type(){
    return _type;
  }
}