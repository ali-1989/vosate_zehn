import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:app/pages/about_us_page.dart';
import 'package:app/pages/aid_page.dart';
import 'package:app/pages/contact_us_page.dart';
import 'package:app/pages/e404_page.dart';
import 'package:app/pages/favorites_page.dart';
import 'package:app/pages/image_full_screen.dart';
import 'package:app/pages/last_seen_page.dart';
import 'package:app/pages/layout_page.dart';
import 'package:app/pages/levels/audio_player_page.dart';
import 'package:app/pages/levels/content_view_page.dart';
import 'package:app/pages/levels/sub_bucket_page.dart';
import 'package:app/pages/levels/video_player_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/login/register_page.dart';
import 'package:app/pages/profile/profile_page.dart';
import 'package:app/pages/search_page.dart';
import 'package:app/pages/sentences_page.dart';
import 'package:app/pages/term_page.dart';
import 'package:app/pages/zarinpal_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appNavigator.dart';

class AppRoute {
  static final List<GoRoute> freeRoutes = [];

  AppRoute._();

  static late BuildContext materialContext;

  static void init() {
    freeRoutes.add(LoginPage.route);
    freeRoutes.add(RegisterPage.route);
    freeRoutes.add(TermPage.route);
    freeRoutes.add(AboutUsPage.route);
  }

  static BuildContext getContext() {
    var res = WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;//deep: 50
    res ??= WidgetsBinding.instance.focusManager.primaryFocus?.context; //deep: 71

    return res?? getMaterialContext();
  }

  static BuildContext getMaterialContext() {
    return materialContext;
  }

  static Future<bool> saveRoutePageName(String routeName) async {
    final int res = await AppDB.setReplaceKv(Keys.setting$lastRouteName, routeName);

    return res > 0;
  }

  static String? fetchRoutePageName() {
    return AppDB.fetchKv(Keys.setting$lastRouteName);
  }

  /*static void navigateRouteScreen(String routeName) {
    saveRouteName(routeName);
    SettingsManager.settingsModel.currentRouteScreen = routeName;
    AppBroadcast.reBuildMaterial();
  }*/

  static void backRoute() {
    final lastCtx = AppNavigator.getLastRouteContext(getContext());
    AppNavigator.backRoute(lastCtx);
  }

  static void backToRoot(BuildContext context) {
    //AppNavigator.popRoutesUntilRoot(AppRoute.getContext());

    while(canPop(context)){
      popTopView(context);
    }
  }

  static bool canPop(BuildContext context) {
    return AppNavigator.canPop(context);
    //return GoRouter.of(context).canPop();
  }

  static void popTopView(BuildContext context) {
    AppNavigator.pop(context);
  }

  static void popPage(BuildContext context) {
    GoRouter.of(context).pop();
  }

  static void push(BuildContext context, String address, {dynamic extra}) {
    if(kIsWeb){
      GoRouter.of(context).go(address, extra: extra);
    }
    else {
      GoRouter.of(context).push(address, extra: extra);
    }
  }

  static void replace(BuildContext context, Widget page, {dynamic extra}) {
    final r = MaterialPageRoute(builder: (ctx){
      return page;
    });

    Navigator.of(context).pushReplacement(r);
  }

  static void pushNamed(BuildContext context, String name, {dynamic extra}) {
    if(kIsWeb){
      GoRouter.of(context).goNamed(name, params: {}, extra: extra);
    }
    else {
      GoRouter.of(context).pushNamed(name, params: {}, extra: extra);
    }
  }

  static void replaceNamed(BuildContext context, String name, {dynamic extra}) {
    GoRouter.of(context).replaceNamed(name, params: {}, extra: extra);
  }
}
///============================================================================================
final mainRouter = GoRouter(
    routes: <GoRoute>[
      E404Page.route,
      LayoutPage.route,
      LoginPage.route,
      RegisterPage.route,
      TermPage.route,
      AboutUsPage.route,
      AidPage.route,
      LastSeenPage.route,
      FavoritesPage.route,
      ContactUsPage.route,
      ZarinpalPage.route,
      ProfilePage.route,
      SubBucketPage.route,
      ContentViewPage.route,
      ImageFullScreen.route,
      VideoPlayerPage.route,
      AudioPlayerPage.route,
      SentencesPage.route,
      SearchPage.route,
    ],
    initialLocation: LayoutPage.route.path,
    routerNeglect: true,//In browser 'back' button not work
    errorBuilder: routeErrorHandler,
    redirect: _mainRedirect,
);

bool checkFreeRoute(GoRoute route, GoRouterState state){
  final routeIsTop = route.path.startsWith('/');
  final stateIsTop = state.subloc.startsWith('/');

  if((routeIsTop && stateIsTop) || (!routeIsTop && !stateIsTop)){
    return route.path == state.subloc;
  }

  if(!routeIsTop){
    //return '${HomePage.route.path}/${route.path}' == state.subloc;  if homePage is not backSlash, like:/admin
    return route.path == state.subloc;
  }

  return false;
}

String? _mainRedirect(GoRouterState state){
  if(state.subloc == LayoutPage.route.path){
    AppDirectories.generateNoMediaFile();
  }

  if(!Session.hasAnyLogin()){
    if(AppRoute.freeRoutes.any((r) => checkFreeRoute(r, state))){
      return null;
    }
    else {
      final from = state.subloc == '/' ? '' : '?gt=${state.location}';
      return '/${LoginPage.route.path}$from'.replaceFirst('//', '/');
    }
  }

  return state.queryParams['gt'];
}

Widget routeErrorHandler(BuildContext context, GoRouterState state) {
  /*final split = state.subloc.split('/');
  final count = state.subloc.startsWith('/')? 1 : 0;

  if(split.length > count){
    AppRoute.pushNamed(AppRoute.getContext(), state.subloc.substring(0, state.subloc.lastIndexOf('/')));
    return SizedBox();
  }*/

 return const E404Page();
}
///============================================================================================
class MyPageRoute extends PageRouteBuilder {
  final Widget widget;
  final String? routeName;

  MyPageRoute({
    required this.widget,
    this.routeName,
  })
      : super(
        settings: RouteSettings(name: routeName),
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return widget;
        },
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        //ScaleTransition, RotationTransition, SizeTransition, FadeTransition
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero,).animate(animation),
          child: child,
        );
      });
}
