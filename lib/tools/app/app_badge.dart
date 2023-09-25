import 'package:iris_tools/modules/stateManagers/updater_state.dart';

import 'package:app/structures/enums/badge_group.dart';

class AppBadge {
  AppBadge._();

  static final _appBadges = <BadgesGroup, int>{};

  static int getBadge(BadgesGroup badgesGroup) {
    return _appBadges[badgesGroup]?? 0;
  }

  static int setBadge(BadgesGroup badgesGroup, int count) {
    return _appBadges[badgesGroup] = count;
  }

  static void setBadgeAndRefresh(BadgesGroup badgesGroup, int count) {
    _appBadges[badgesGroup] = count;
    refreshBadge(badgesGroup);
  }

  static void refreshBadge(BadgesGroup badgesGroup) async {
    UpdaterController.updateByGroup(badgesGroup);
  }
}
