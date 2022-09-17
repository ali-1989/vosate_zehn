
class VersionModel {
  String? newVersionName;
  int newVersionCode = 0;
  String? description;
  bool restricted = false;
  String? link;
  String? newVersionTs;
  String? pkgName;
  int? os;

  VersionModel();

  VersionModel.fromMap(Map map) {
    newVersionName = map['new_version_name'];
    newVersionCode = map['new_version_code']?? 0;
    description = map['description'];
    restricted = map['restricted'];
    link = map['link'];
    pkgName = map['pkg_name'];
    os = map['os'];
    newVersionTs = map['new_version_ts'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

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
