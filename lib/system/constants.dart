
class Constants {
  Constants._();

  /// used for (app folder, send to server)
  static const appName = 'VosateZehn';
  /// used for (app title)
  static String appTitle = 'vosate zehn';
  static const _major = 5;
  static const _minor = 4;
  static const _patch = 2;

  static String appVersionName = '$_major.$_minor.$_patch';
  static int appVersionCode = _major *10000 + _minor *100 + _patch;
}
