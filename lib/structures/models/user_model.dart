import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/media_model.dart';

import 'package:app/structures/enums/user_type.dart';
import 'package:app/structures/models/country_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_locale.dart';
import 'package:app/tools/uri_tools.dart';

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
  late UserType userType;
  VipOptionsModel vipOptions = VipOptionsModel();
  //---------------- locale
  DateTime? loginDate;

  UserModel();

  UserModel.fromMap(Map map, {String? domain}) {
    final tLoginDate = map[Keys.setting$lastLoginDate];
    final brDate = map[Keys.birthdate];
    final regDate = map[Keys.registerDate];
    final vip = map['vip_model'];

    userId = map[Keys.userId].toString();
    userName = map[Keys.userName];
    name = map[Keys.name];
    family = map[Keys.family];
    mobile = map[Keys.mobileNumber]?.toString();
    sex = map[Keys.sex];
    countryModel = CountryModel.fromMap(map['country_js']);
    email = map['email'];
    userType = UserType.from(map['user_type']?? 1);

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
      birthDate = DateHelper.millToDateTime(brDate);
    }
    else if(brDate is String) {
      birthDate = DateHelper.timestampToSystem(brDate);
    }

    if(regDate is int) {
      registerDate = DateHelper.millToDateTime(regDate);
    }
    else if(regDate is String) {
      registerDate = DateHelper.timestampToSystem(regDate);
    }

    if(vip is Map){
      vipOptions = VipOptionsModel.fromMap(vip);
    }

    profileModel?.url = UriTools.correctAppUrl(profileModel?.url, domain: domain);
    //----------------------- local
    if (tLoginDate is int) {
      loginDate = DateHelper.millToDateTime(tLoginDate);
    }
    else if (tLoginDate is String) {
      loginDate = DateHelper.timestampToSystem(tLoginDate);
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
    map['user_type'] = userType.id();

    if (token != null) {
      map[Keys.token] = token!.toMap();
    }

    if(countryModel.countryIso != null) {
      map['country_js'] = countryModel.toMap();
    }

    map['vip_model'] = vipOptions.toMap();
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
    vipOptions = other.vipOptions;
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

  String getSexEquivalent({int? sexNum}){
    sexNum?? sex;

    if(sexNum == null) {
      return AppLocale.appLocalize.translate('unknown')!;
    }

    switch(sexNum){
      case 0:
        return AppLocale.appLocalize.translate('unknown')!;
      case 1:
        return AppLocale.appLocalize.translate('man')!;
      case 2:
        return AppLocale.appLocalize.translate('woman')!;
      case 5:
        return AppLocale.appLocalize.translate('bisexual')!;
    }

    return AppLocale.appLocalize.translate('unknown')!;
  }

  /*String get countryName {
    return CountryTools.countryShowNameByCountryIso(countryModel.countryIso?? 'US');
  }*/

  String? get avatarFileName {
    if(profileModel != null && profileModel?.id != null){
      return '${userId}_${profileModel!.id}.jpg';
    }


    return '$userId.jpg';
  }

  bool hasAvatar(){
    return profileModel != null && profileModel!.path != null;
  }

  @override
  String toString(){
    return '$userId _ userName: $userName _ name: $name _ family: $family _ mobile: $mobile _ sex: $sex | token: ${token?.token} , refresh Token: ${token?.refreshToken} ';
  }
}
///=============================================================================
class Token {
  String? token;
  String? refreshToken;
  DateTime? expireDate;

  Token();

  Token.fromMap(Map json) {
    token = json[Keys.token];
    refreshToken = json['refreshToken'];
    expireDate = DateHelper.timestampToSystem(json[Keys.expire]);

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
///=============================================================================
class VipOptionsModel {
  DateTime? expireDate;
  String? productId;

  VipOptionsModel();// : expireDate = DateHelper.nowMinusUtcOffset();

  VipOptionsModel.fromMap(Map map){
    expireDate = DateHelper.timestampToSystem(map['expire_time']);// ?? DateHelper.nowMinusUtcOffset();
    productId = map['product_id'];
  }

  Map<String, dynamic> toMap(){
    final res = <String, dynamic>{};
    res['expire_time'] = DateHelper.toTimestampNullable(expireDate);
    res['product_id'] = productId;

    return res;
  }

  Duration _getDuration(){
    if(expireDate == null){
      return const Duration(seconds: 0);
    }

    return expireDate!.difference(DateHelper.nowMinusUtcOffset());
  }

  int getDays(){
    return _getDuration().inDays;
  }

  int getHours(){
    final dur = _getDuration();
    return dur.inHours - (dur.inDays * 24);
  }

  bool isVip(){
    return getDays() > 0 || getHours() > 0;
  }

  String getHumanVipTime(){
    String ret = '';

    if(getDays() > 0){
      ret = '${getDays()} روز ';

      if(getHours() > 0){
        ret += ' و ${getHours()} ساعت ';
      }

      return ret;
    }

    if(getHours() > 0){
      return '${getHours()} ساعت ';
    }

    return '-';
  }
}