
class BuildFlavor {
  static late final String? _flavor;

  BuildFlavor._();

  static void initial(){
    _flavor = const String.fromEnvironment('flavor');
  }

  static bool isForBazar(){
    return _flavor != null && _flavor!.contains('bazar');
  }

  static bool connectToLocal(){
    return _flavor != null && _flavor!.contains('local');
  }
}