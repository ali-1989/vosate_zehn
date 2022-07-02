import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';

class AppLoading {
  AppLoading._();

  static Future<void> showWaiting({bool dismiss = true}){
    return EasyLoading.show(
        status: AppMessages.pleaseWait,
        dismissOnTap: dismiss,
    );
  }
}