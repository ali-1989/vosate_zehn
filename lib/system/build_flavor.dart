class BuildFlavor {
  static String? _flavor;

  BuildFlavor._();

  static void initial(String? flavor){
    _flavor = flavor;
  }

  static bool isForBazar(){
    return _flavor != null && _flavor!.contains('bazar');
  }

  static bool connectToLocal(){
    return _flavor != null && _flavor!.contains('local');
  }
}