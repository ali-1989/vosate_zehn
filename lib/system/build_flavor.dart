
class BuildFlavor {
  static late final String? _flavor;

  BuildFlavor._();

  static void initial(){
    _flavor = const String.fromEnvironment('flavor');
  }

  static bool isForBazar(){
    return _flavor != null && _flavor!.contains('bazar');
  }

  static bool connectToTest(){
    return _flavor != null && _flavor!.contains('local');
  }

  static bool resetToRelease(){
    return _flavor != null && _flavor!.contains('resetHttp');
  }
}