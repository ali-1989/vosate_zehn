
class Constants {
  Constants._();

  /// used for (app folder, send to server)
  static const appName = 'VosateZehn';
  /// used for (app title)
  static String appTitle = 'vosate zehn';
  static final _major = 5;         //match by pubspec.yaml
  static final _minor = 2;
  static final _patch = 7;

  static String appVersionName = '$_major.$_minor.$_patch';
  static int appVersionCode = _major *10000 + _minor *100 + _patch;
}
