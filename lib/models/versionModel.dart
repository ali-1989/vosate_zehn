
class VersionModel {
  String? versionName;
  String? newVersionName;
  int? versionCode;
  int? newVersionCode;
  String? description;
  bool restricted = false;
  String? link;
  String? newVersionTs;
  String? pkgName;
  int? os;

  VersionModel();

  VersionModel.fromMap(Map map) {
    versionName = map['version_name'];
    versionCode = map['version_code'];
    newVersionName = map['new_version_name'];
    newVersionCode = map['new_version_code'];
    description = map['description'];
    restricted = map['restricted'];
    link = map['link'];
    pkgName = map['pkg_name'];
    os = map['os'];
    newVersionTs = map['new_version_ts'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['version_name'] = versionName;
    map['version_code'] = versionCode;
    map['new_version_name'] = newVersionName;
    map['new_version_code'] = newVersionCode;
    map['description'] = description;
    map['restricted'] = restricted;
    map['link'] = link;
    map['pkg_name'] = pkgName;
    map['os'] = os;
    map['new_version_ts'] = newVersionTs;

    return map;
  }
}
