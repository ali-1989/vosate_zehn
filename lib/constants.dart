
class Constants {
  Constants._();

  /// used for (app folder, send to server)
  static const appName = 'VosateZehn';
  /// used for (app title)
  static String appTitle = 'vosate zehn';
  static final _major = 5;
  static final _minor = 3;
  static final _patch = 1;

  static String appVersionName = '$_major.$_minor.$_patch';
  static int appVersionCode = _major *10000 + _minor *100 + _patch;
}
