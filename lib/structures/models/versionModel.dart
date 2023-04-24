
class VersionModel {
  String? newVersionName;
  int newVersionCode = 0;
  String? description;
  bool restricted = false;
  String? directLink;
  Map<String, String> markets = {};
  String? newVersionTs;
  String? pkgName;
  int? os;

  VersionModel();

  VersionModel.fromMap(Map map) {
    newVersionName = map['new_version_name'];
    newVersionCode = map['new_version_code']?? 0;
    description = map['description'];
    restricted = map['restricted'];
    directLink = map['direct_link'];
    pkgName = map['pkg_name'];
    os = map['os'];
    newVersionTs = map['new_version_ts'];

    if(map['markets'] is Map) {
      markets = (map['markets'] as Map).map<String, String>((key, value) => MapEntry<String, String>(key, value));
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['new_version_name'] = newVersionName;
    map['new_version_code'] = newVersionCode;
    map['description'] = description;
    map['restricted'] = restricted;
    map['direct_link'] = directLink;
    map['pkg_name'] = pkgName;
    map['os'] = os;
    map['new_version_ts'] = newVersionTs;
    map['markets'] = markets;

    return map;
  }
}
