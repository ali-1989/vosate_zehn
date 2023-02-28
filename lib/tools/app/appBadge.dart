import 'package:app/tools/app/appBroadcast.dart';

class AppBadge {
  AppBadge._();

  static final _homePageBadges = <int, int>{};

  static void setMessageBadge(int count) async {
    _homePageBadges[3] = count;
  }

  static int getMessageBadge() {
    return getBadge(3);
  }

  static refreshViews() async {
    AppBroadcast.layoutPageKey.currentState?.assistCtr.updateHead();
  }

  static int getBadge(int itemIdx) {
    return _homePageBadges[itemIdx]?? 0;
  }
}
