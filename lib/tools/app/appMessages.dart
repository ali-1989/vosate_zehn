import '/system/extensions.dart';

import 'package:vosate_zehn/tools/app/appRoute.dart';

class AppMessages {
  AppMessages._();

  static const _noText = "nn";
  static const errorOccur = "خطایی رخ داده است";
  static const pleaseWait = 'چند لحظه صبر کنید...';

  static String get yes {
    return AppRoute.getContext().tC('yes')?? _noText;
  }

  static String get no {
    return AppRoute.getContext().tC('no')?? _noText;
  }

  static String get wantToLeave {
    return AppRoute.getContext().tC('wantToLeave')?? _noText;
  }

  static String get netConnectionIsDisconnect {
    return AppRoute.getContext().tC('netConnectionIsDisconnect')?? _noText;
  }

  static String get errorCommunicatingServer {
    return AppRoute.getContext().tC('errorCommunicatingServer')?? _noText;
  }

  static String get serverNotRespondProperly {
    return AppRoute.getContext().tC('serverNotRespondProperly')?? _noText;
  }

  static String get operationCannotBePerformed {
    return AppRoute.getContext().tC('operationCannotBePerformed')?? _noText;
  }

  static String get successOperation {
    return AppRoute.getContext().tC('successOperation')?? _noText;
  }

  static String get operationFailed {
    return AppRoute.getContext().tC('operationFailed')?? _noText;
  }

  static String get operationFailedTryAgain {
    return AppRoute.getContext().tC('operationFailedTryAgain')?? _noText;
  }

  static String get operationCanceled {
    return AppRoute.getContext().tC('operationCanceled')?? _noText;
  }
}