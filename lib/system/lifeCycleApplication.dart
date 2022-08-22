import 'package:app/tools/app/appCache.dart';

class LifeCycleApplication {
  LifeCycleApplication._();

  static void onPause() async {
    if(!AppCache.timeoutCache.addTimeout('onPause', const Duration(seconds: 5))) {
      return;
    }

    /*if(LockScreenTools.mustLock()) {
      SettingsManager.settingsModel.lastForegroundTs = DateHelper.getNowTimestamp();
      await SettingsManager.saveSettings();
    }*/
  }

  static void onDetach() async {
    if(!AppCache.timeoutCache.addTimeout('onDetach', const Duration(seconds: 5))) {
      return;
    }

    /*if(LockScreenTools.mustLock()) {
      SettingsManager.settingsModel.lastForegroundTs = null;
      await SettingsManager.saveSettings();
    }*/
  }

  static void onResume() {
    /*if (LockScreenTools.mustLock()) {
      final screen = PatternLockScreen(
        controller: AppBroadcast.lockController,
        description: LockScreenTools.getDescription(AppRoute.materialContext),
        onBack: (ctx, result) {
          SystemNavigator.pop();
          return false;
        },
        onResult: (BuildContext context, List<int>? result) {
          if (result == null) {
            return false;
          }

          final current = DbCenter.fetchKv(Keys.sk$patternKey);

          if (result.join() == current) {
            return true;
          }

          return false;
        },
      );

      AppNavigator.pushNextPage(AppRoute.getContext(), screen, name: PatternLockScreen.screenName);
    }*/
  }
}
