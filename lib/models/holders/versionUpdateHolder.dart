
class VersionUpdateHolder {
  int? version;
  String? pkgName;
  int? os;

  VersionUpdateHolder({
    this.version,
    this.pkgName,
    this.os,
  });

  VersionUpdateHolder.fromJson(Map map) {
    version = map['new_version_code'];
    pkgName = map['pkg_name'];
    os = map['os'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['new_version_code'] = version;
    map['pkg_name'] = pkgName;
    map['os'] = os;

    return map;
  }
}
