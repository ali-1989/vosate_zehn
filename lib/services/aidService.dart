import 'package:app/pages/aid_page.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appRoute.dart';

class AidService {
  AidService._();

  static void gotoAidPage(){
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushNamed(AppRoute.getContext(), AidPage.route.name!);
  }
}