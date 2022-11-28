import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:app/structures/models/countryModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/uriTools.dart';

class UserModel {
  late String userId;
  late String userName;
  String? name;
  String? family;
  DateTime? birthDate;
  String? mobile;
  DateTime? registerDate;
  int? sex;
  Token? token;
  MediaModel? profileModel;
  CountryModel countryModel = CountryModel();
  String? email;
  int? userType;
  //---------------- locale
  DateTime? loginDate;

  UserModel();

  UserModel.fromMap(Map map, {String? domain}) {
    final tLoginDate = map[Keys.setting$lastLoginDate];
    final brDate = map[Keys.birthdate];
    final regDate = map[Keys.registerDate];

    userId = map[Keys.userId].toString();
    userName = map[Keys.userName];
    name = map[Keys.name];
    family = map[Keys.family];
    mobile = map[Keys.mobileNumber]?.toString();
    sex = map[Keys.sex];
    countryModel = CountryModel.fromMap(map['country_js']);
    email = map['email'];
    userType = map['user_type'];

    if(map[Keys.token] is Map) {
      token = Token.fromMap(map[Keys.token]);
    }

    else if(map[Keys.token] is String) {
      token = Token()..token = map[Keys.token];
      //token?.parseToken();
    }

    final Map? avatarTemp = map['profile_image_model'];

    if(avatarTemp != null && avatarTemp.isNotEmpty) {
      profileModel = MediaModel.fromMap(map['profile_image_model']);
    }

    if(brDate is int) {
      birthDate = DateHelper.milToDateTime(brDate);
    }
    else if(brDate is String) {
      birthDate = DateHelper.tsToSystemDate(brDate);
    }

    if(regDate is int) {
      registerDate = DateHelper.milToDateTime(regDate);
    }
    else if(regDate is String) {
      registerDate = DateHelper.tsToSystemDate(regDate);
    }

    profileModel?.url = UriTools.correctAppUrl(profileModel?.url, domain: domain);
    //----------------------- local
    if (tLoginDate is int) {
      loginDate = DateHelper.milToDateTime(tLoginDate);
    }
    else if (tLoginDate is String) {
      loginDate = DateHelper.tsToSystemDate(tLoginDate);
    }
  }
  
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[Keys.userId] = userId;
    map[Keys.userName] = userName;
    map[Keys.name] = name;
    map[Keys.family] = family;
    map[Keys.birthdate] = birthDate == null? null: DateHelper.toTimestamp(birthDate!);
    map[Keys.registerDate] = registerDate == null? null: DateHelper.toTimestamp(registerDate!);
    map[Keys.mobileNumber] = mobile;
    map[Keys.sex] = sex;
    map['profile_image_model'] = profileModel?.toMap();
    map['email'] = email;
    map['user_type'] = userType;

    if (token != null) {
      map[Keys.token] = token!.toMap();
    }

    if(countryModel.countryIso != null) {
      map['country_js'] = countryModel.toMap();
    }
    //-------------------------- local
    map[Keys.setting$lastLoginDate] = loginDate == null ? null : DateHelper.toTimestamp(loginDate!);

    return map;
  }

  void matchBy(UserModel other) {
    userId = other.userId;
    userName = other.userName;
    name = other.name;
    family = other.family;
    birthDate = other.birthDate;
    mobile = other.mobile;
    registerDate = other.registerDate;
    sex = other.sex;
    profileModel = other.profileModel;
    email = other.email;
    userType = other.userType;
    countryModel = other.countryModel;
    token = other.token;

    //--------------------------------- local
    //_profilePath = read._profilePath;
    loginDate = other.loginDate;
  }

  String get nameFamily {
    return '$name $family';
  }

  int get age {
    if(birthDate == null) {
      return 0;
    }

    return DateHelper.calculateAge(birthDate!);
  }

  /*String get countryName {
    return CountryTools.countryShowNameByCountryIso(countryModel.countryIso?? 'US');
  }*/

  String? get avatarFileName {
    if(profileModel == null || profileModel?.id == null){
      return null;
    }

    return '${userId}_${profileModel!.id}.jpg';
  }

  @override
  String toString(){
    return '$userId _ userName: $userName _ name: $name _ family: $family _ mobile: $mobile _ sex: $sex ';
  }
}
///=======================================================================================================
class Token {
  String? token;
  String? refreshToken;
  DateTime? expireDate;

  Token();

  Token.fromMap(Map json) {
    token = json[Keys.token];
    refreshToken = json['refreshToken'];
    expireDate = DateHelper.tsToSystemDate(json[Keys.expire]);

    parseToken();
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data[Keys.token] = token;
    data[Keys.expire] = DateHelper.toTimestampNullable(expireDate);
    data['refreshToken'] = refreshToken;

    return data;
  }

  void parseToken(){
    final jwt = {};//JwtService.decodeToken(token?? '');
    final exp = jwt['exp'];

    if(exp != null && expireDate == null){
      expireDate = DateTime(1970, 1, 1);
      expireDate = expireDate!.add(Duration(seconds: exp));
    }
  }

  @override
  String toString(){
    return 'Token: $token | refreshToken: $refreshToken | expire Date: $expireDate';
  }
}