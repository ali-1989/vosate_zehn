import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';

import 'package:app/tools/app/appDirectories.dart';

class LogTools {
  LogTools._();

  static late Logger logger;
  static late Reporter reporter;

  static Future<bool> init() async {
    try {

      if (!kIsWeb) {
        LogTools.reporter = Reporter(AppDirectories.getExternalAppFolder(), 'report');
      }

      LogTools.logger = Logger('${AppDirectories.getExternalTempDir()}/logs');

      return true;
    }
    catch (e){
      log('$e\n\n${StackTrace.current}');
      return false;
    }
  }
}
