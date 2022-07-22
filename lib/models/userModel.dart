import 'package:vosate_zehn/models/countryModel.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:vosate_zehn/tools/uriTools.dart';

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
  String? profileImageId;
  String? profileImageUrl;
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
    token = map[Keys.token] != null ? Token.fromMap(map[Keys.token]) : null;
    profileImageId = map[Keys.profileImageId];
    profileImageUrl = map[Keys.profileImageUrl];
    countryModel = CountryModel.fromMap(map['country_js']);
    email = map['email'];
    userType = map['user_type'];

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

    profileImageUrl = UriTools.correctAppUrl(profileImageUrl, domain: domain);
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
    map['profile_image_id'] = profileImageId;
    map[Keys.profileImageUrl] = profileImageUrl;
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
    profileImageId = other.profileImageId;
    profileImageUrl = other.profileImageUrl;
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

  @override
  String toString(){
    return '$userId _ userName: $userName _ name: $name _ family: $family _ mobile: $mobile _ sex: $sex ';
  }
}
///=======================================================================================================
class Token {
  String? token;
  String? expireTs;

  Token();

  Token.fromMap(Map json) {
    token = json[Keys.token];
    expireTs = json[Keys.expire];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data[Keys.token] = token;
    data[Keys.expire] = expireTs;

    return data;
  }
}



/*

/*final map = js['object']?? {};
    statusServer = js['status'];
    message = js['message'];*/


Map<String, dynamic> toJsonServer() {
    final map = Map<String, dynamic>();
    map['object'] = toMap();
    map['status'] = status;
    map['message'] = message;

    return map;
  }
* */