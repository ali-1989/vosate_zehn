import 'package:app/managers/appParameterManager.dart';
import 'package:app/pages/aid_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class AidService {
  AidService._();

  static void gotoAidPage(){
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushNamed(AppRoute.getContext(), AidPage.route.name!);
  }

  static void showAidDialog(){
    final msg = AppParameterManager.parameterModel?.aidPopMessage?? 'aid of us';

    /*if(msg == null){
      return;
    }*/

    AppDialogIris.instance.showYesNoDialog(
        AppRoute.materialContext,
       title: AppMessages.aidUs,
      yesText: AppMessages.aid,
      noText: AppMessages.later,
      yesFn: gotoAidPage,
      desc: msg,
    );

    AppDB.setReplaceKv(Keys.setting$lastAidDialogShowTime, DateHelper.getNowTimestampToUtc());
  }

  static void checkShowDialog() async {
    await Future.delayed(Duration(seconds: 20), (){});

    if(!Session.hasAnyLogin()){
      return;
    }

    final lastTime = AppDB.fetchKv(Keys.setting$lastAidDialogShowTime);
    var lastTimeDt = DateHelper.tsToSystemDate(lastTime);

    if(lastTimeDt != null){
      lastTimeDt = lastTimeDt.toUtc();
    }
    else {
      //AppDB.setReplaceKv(Keys.setting$lastAidDialogShowTime, DateHelper.getNowTimestampToUtc());
      //return;
    }

    if(lastTime == null || DateHelper.isPastOf(lastTimeDt, Duration(days: 1))){
      showAidDialog();
    }
  }
}