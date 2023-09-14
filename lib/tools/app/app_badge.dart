import 'package:app/tools/app/app_broadcast.dart';

class AppBadge {
  AppBadge._();

  static final _homePageBadges = <int, int>{};

  static void setMessageBadge(int count) async {
    _homePageBadges[3] = count;
  }

   static void setLeitnerBadge(int count) async {
    _homePageBadges[1] = count;
  }

  static int getMessageBadge() {
    return getBadge(3);
  }

  static int getLeitnerBadge() {
    return getBadge(1);
  }

  static refreshViews() async {
    AppBroadcast.layoutPageKey.currentState?.assistCtr.updateHead();
  }

  static int getBadge(int itemIdx) {
    return _homePageBadges[itemIdx]?? 0;
  }
}
