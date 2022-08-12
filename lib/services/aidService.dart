import 'package:vosate_zehn/pages/aid_page.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';

class AidService {
  AidService._();

  static void gotoAidPage(){
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushNamed(AppRoute.getContext(), AidPage.route.name!);
  }
}