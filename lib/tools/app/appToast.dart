// ignore_for_file: file_names
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AppToast {
  AppToast._();

  Future<void> showToast(String msg, {bool dismiss = true, Duration duration = const Duration(milliseconds: 3500)}){
    return EasyLoading.showToast(
      msg,
      duration: duration,
      dismissOnTap: dismiss,
      toastPosition: EasyLoadingToastPosition.bottom,
      maskType: EasyLoadingMaskType.none,
    );
  }
}
