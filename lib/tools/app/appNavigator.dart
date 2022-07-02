import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppNavigator {
  AppNavigator._();

  static NavigatorState? getRootNavigator(){
    var ctx = FocusManager.instance.rootScope.context;

    if(ctx == null){
      final children = FocusManager.instance.rootScope.children;
      var dep = 100;

      for (var element in children) {
        final context = element.context;

        if(context != null){
          final elm = context as Element;

          if(elm.depth < dep){
            dep = elm.depth;
            ctx = context;
          }
        }
      }
    }

    late BuildContext navigatorCtx;

    touchChildren(ctx!, (elem) {
      if(elem.widget is Navigator){
        navigatorCtx = elem;
        return false;
      }

      return true;
    });


    return Navigator.maybeOf(navigatorCtx, rootNavigator: false);
  }

  static NavigatorState? getRootNavigatorBy(BuildContext context) {
    /// no need use: context.dirty

    try {
      /// for avoid: ErrorSummary("Looking up a deactivated widget's ancestor is unsafe.") in framework.dart
      if (context is StatefulElement) {
        if (!context.state.mounted) {
          return null;
        }
      }

      if (context is StatelessElement) {
        if (!(context.renderObject?.attached ?? false)) {
          return null;
        }
      }
    }
    catch (e){
      return null;
    }

    return Navigator.maybeOf(context, rootNavigator: true); // rootNavigator[true]: continue until root /
  }

  // nearest Upwards Navigator
  static NavigatorState? getNearestNavigator(BuildContext context){
    if (context is StatefulElement) {
      if (!context.state.mounted) { // || context.dirty
        return null;
      }
    }

    if (context is StatelessElement) {
      if (!(context.renderObject?.attached ?? false)) {
        return null;
      }
    }

    return Navigator.maybeOf(context, rootNavigator: false);
  }

  static BuildContext getStableContext(BuildContext context) {
    final m = findRouteByName(getAllModalRoutes(context: context), '/');

    return m!.subtreeContext!;
  }

  static ModalRoute? getModalRouteOfOld(BuildContext context){
    if (context is StatefulElement) {
      if (!context.state.mounted || context.dirty) {
        return null;
      }
    }

    if (context is StatelessElement) {
      if (!(context.renderObject?.attached ?? false) || context.dirty) {
        return null;
      }
    }

    return ModalRoute.of(context);
  }

  static ModalRoute? getModalRouteOf(BuildContext context){
    final element = context as Element;
    final runType = element.widget.runtimeType.toString();

    if(runType == '_ModalScopeStatus'){
      final dynamic d = element.widget;

      return d.route as ModalRoute;
    }

    ModalRoute? result;

    touchAncestorsToRoot(context, (elem){
      final runType = elem.widget.runtimeType.toString();

      if(runType == '_ModalScopeStatus'){
        final dynamic d = elem.widget;

        result = d.route as ModalRoute;
        return false;
      }

      return true;
    });

    return result;
  }

  static Future<List<Widget>> getAllChildren(BuildContext context) async {
    final res = <Widget>[];

    void func(BuildContext ctx) {
      ctx.visitChildElements((Element element) {
        try {
          res.add(element.widget);
        }
        catch (e){/**/}

        func(element);
      });
    }

    func(context);

    return res;
  }

  /// *** it is work else in initState, is best
  static List<ModalRoute> getAllModalRoutesByFocusScope({BuildContext? context, bool onlyActives = true}) {
    final nav = getRootNavigator();
    final res = <ModalRoute>[];

    if(nav == null) {
      return res;
    }

    //List children = nav.focusScopeNode.descendants.toList();    << exist repeat node
    final List children = nav.focusScopeNode.children.toList();

    for(FocusNode f in children) {
      final m = getModalRouteOf(f.context!);

      if(m == null) {
        continue;
      }

      if (onlyActives){
        if (m.isActive) {
          res.add(m);
        }
      }
      else {
        res.add(m);
      }
    }

    return res;
  }

  static List<ModalRoute> getAllModalRoutesByAncestor({BuildContext? context, bool onlyActives = true}) {
    final nav = getRootNavigator();
    final elements = <Element>[];
    final res = <ModalRoute>[];

    if(nav == null) {
      return res;
    }

    var beforeModalScopeStatus = false;

    void func(BuildContext ctx) {
      final elm = ctx as Element;

      elm.visitChildren((Element element) {
        try {
          final runType = element.widget.runtimeType.toString();

          if(runType == '_ModalScopeStatus') {// if add this: take error [Duplicate GlobalKeys]
            beforeModalScopeStatus = true;
          }
          else if(beforeModalScopeStatus && runType == 'Offstage') {
            elements.add(element);
          }
          else {
            beforeModalScopeStatus = false;
          }
        }
        catch (e){/**/}

        func(element);
      });
    }

    try {
      func(nav.context);
    }
    catch(e){
      rethrow;
    }

    for(var w in elements) {
      final m = getModalRouteOf(w);

      if(m == null) {
        continue;
      }

      if (onlyActives){
        if (m.isActive) {
          res.add(m);
        }
      }
      else {
        res.add(m);
      }
    }

    return res;
  }

  static List<ModalRoute> getAllModalRoutes({BuildContext? context, bool onlyActives = true}) {
    final nav = getRootNavigator();
    final res = <ModalRoute>[];

    if(nav == null) {
      return res;
    }

    void func(BuildContext ctx) {
      final elm = ctx as Element;

      elm.visitChildren((Element element) {
        try {
          final runType = element.widget.runtimeType.toString();

          if(runType == '_ModalScopeStatus') {// if add this: take error [Duplicate GlobalKeys]
            final dynamic d = element.widget;

            final m = d.route as ModalRoute?;

            if(m != null) {
              if (onlyActives){
                if (m.isActive) {
                  res.add(m);
                }
              }
              else {
                res.add(m);
              }
            }
          }
        }
        catch (e){
          //rint('$e');
        }

        func(element);
      });
    }

    func(nav.context);

    return res;
  }

  static ModalRoute? accessModalRouteByRouteName(BuildContext context, String name, {bool onlyActives = false}){
    final list = getAllModalRoutes(context: context, onlyActives: onlyActives);
    return findRouteByName(list, name);
  }

  static ModalRoute? findRouteByName(List<ModalRoute> list, String name) {
    ModalRoute? res;

    for(var m in list){
      if(m.settings.name == name) {
        res = m;
        break;
      }
    }

    return res;
  }

  static List<BuildContext> getAllModalRoutesContext(BuildContext context, {bool onlyActives = true}) {
    final list = getAllModalRoutes(context: context, onlyActives: onlyActives);
    final res = <BuildContext>[];

    for(var m in list){
      res.add(m.subtreeContext!);
    }

    return res;
  }

  static BuildContext findEndChildContext(BuildContext context){
    var last = context;
    var maxDepth = -1;

    void fn(Element element) {
      if(element.depth > maxDepth) {
        last = element;
        maxDepth = element.depth;
      }

      element.visitChildren(fn);
    }

    (context as Element).visitChildren(fn);

    return last;
  }

  static T? findAncestorWidgetOfExactType<T extends Widget>(BuildContext context, {bool onlyActives = true, bool onAllPages = true}){
    final list = getAllModalRoutesContext(context, onlyActives: onlyActives);
    BuildContext ctx;
    T? cas;

    if(onAllPages) {
      for (var i = list.length; i > 0; i--) {
        ctx = list[i - 1];
        ctx = findEndChildContext(ctx);
        cas = ctx.findAncestorWidgetOfExactType();

        if (cas != null) {
          break;
        }
      }
    }
    else {
      ctx = list.last;
      ctx = findEndChildContext(ctx);
      cas = ctx.findAncestorWidgetOfExactType();
    }

    return cas;
  }

  static void touchAncestorsToRoot(BuildContext context, bool Function(Element elem) onParent) {
    final e = context as Element;

    e.visitAncestorElements((element) {
      return onParent(element);
      //return true;
    });
  }

  static void touchChildren(BuildContext context, bool Function(Element elem) onChild) {
    final e = context as Element;
    //var hash = context.hashCode;

    void fn(element) {
      //hash = element.hashCode;
      if(!onChild(element)) {
        return;
      }

      element.visitChildren(fn);
    }

    //  visitChildElements() throw exception
    e.visitChildren(fn);
  }

  static ModalRoute findBefore(List<ModalRoute> list, ModalRoute current) {
    var before = list.first;

    for(var m in list){
      if(m == current) {
        break;
      }

      before = m;
    }

    return before;
  }

  static ModalRoute? findRouteByWidget<T extends Widget>(List<ModalRoute> list, T widget) {
    ModalRoute? res;

    for(var route in list){
      final elm = (route.subtreeContext as Element);

      final type = elm.findAncestorWidgetOfExactType();

      if(type != null) {
        res = route;
        break;
      }
    }

    if(res != null) {
      return res;
    }

    // in children -----------------------------------
    for(var route in list){
      final elm = (route.subtreeContext as Element);
      var lastHash = 0;

      if(res != null) {
        break;
      }

      void fn(element) {
        while(lastHash != element.hashCode){
          lastHash = element.hashCode;

          if(res != null) {
            break;
          }

          //if(element.toStringShort() == widget.toStringShort()){
          if(element.runtimeType == widget.runtimeType){
            res = route;
            break;
          }

          element.visitChildElements(fn);
        }
      }

      elm.visitChildren(fn);
    }

    return res;
  }

  static bool existRouteByName(BuildContext context, String name){
    final list = getAllModalRoutes(context: context);
    return findRouteByName(list, name) != null;
  }

  static BuildContext getLastRouteContext(BuildContext context){
    final list = getAllModalRoutesContext(context);
    return list.last;
  }

  static T? findWidgetIn<T extends Widget>(ModalRoute route){
    BuildContext ctx;
    T? cas;

    ctx = route.subtreeContext!;
    ctx = findEndChildContext(ctx);
    cas = ctx.findAncestorWidgetOfExactType();

    return cas;
  }

  static T? findStateIn<T extends State>(ModalRoute route){
    BuildContext ctx;
    T? cas;

    ctx = route.subtreeContext!;
    ctx = findEndChildContext(ctx);
    cas = ctx.findAncestorWidgetOfExactType();

    return cas;
  }

  static ModalRoute? accessModalRouteByWidget<T extends Widget>(BuildContext context, T widget, {bool onlyActives = false}){
    final list = getAllModalRoutes(context: context, onlyActives: onlyActives);
    return findRouteByWidget<T>(list, widget);
  }

  static ModalRoute? getPreviousModalRoute(BuildContext context){
    final list = getAllModalRoutes(context: context);
    final ModalRoute? current = ModalRoute.of(context);

    if(current == null) {
      return null;
    }

    return findBefore(list, current);
  }

  static bool isMountedPage(BuildContext context){
    return Navigator.of(context).mounted;
  }

  static Ticker createTicker(BuildContext context, void Function(Duration elapsed) fn) {
    final nav = Navigator.of(context);
    return nav.createTicker(fn);
  }

  static OverlayState? getOverlayState(BuildContext context) {
    final nav = Navigator.of(context);
    return nav.overlay;
  }

  ///usage in build(context) no in initState()
  static dynamic getPassedData(BuildContext context){
    return ModalRoute.of(context)?.settings.arguments;
  }

  static Object? getArgumentsOf(BuildContext context){
    return ModalRoute.of(context)?.settings.arguments;
  }

  static RouteSettings? getSettingsOf(BuildContext context){
    return ModalRoute.of(context)?.settings;
  }

  static String? getCurrentRouteName(BuildContext context){
    return ModalRoute.of(context)?.settings.name;
  }

  /*  guide:
    Future<bool> Function() popListener;

    popListener = (){
      ModalRoute.of(ctx).removeScopedWillPopCallback(popListener);
      ModalRoute.of(ctx).navigator.pop("return back");

      return Future.value(true);
    };

    if(!ctr.exist("addListener"))
      ModalRoute.of(ctx).addScopedWillPopCallback(popListener);
   */

  static void addPopListener(BuildContext context, Future<bool> Function() fn){
    ModalRoute.of(context)?.addScopedWillPopCallback(fn);
  }

  static void removePopListener(BuildContext context, Future<bool> Function() fn){
    ModalRoute.of(context)?.removeScopedWillPopCallback(fn);
  }

  static bool isDisabledAnimations(BuildContext context){
    return MediaQuery.of(context).disableAnimations;
  }

  static void setHide(BuildContext context, bool offstage){
    ModalRoute.of(context)?.offstage = offstage;
  }

  static bool canPop(BuildContext context){
    return Navigator.of(context).canPop();
  }

  static bool canPopCurrent(BuildContext context){
    return ModalRoute.of(context)?.canPop?? false;
  }

  /// not call pop listeners
  static void removeRoute(BuildContext context, ModalRoute? route){
    if(route == null) {
      return;
    }

    Navigator.of(context).removeRoute(route);
  }

  /// not call pop listeners
  static void removeRouteByName(BuildContext context, String routeName){
    final route = accessModalRouteByRouteName(context, routeName);

    if(route == null) {
      return;
    }

    Navigator.of(context).removeRoute(route);
  }

  static bool isCurrentTopPage(BuildContext context) {
    return ModalRoute.of(context)?.isCurrent?? false;
  }

  static OverlayState? getOverlay(BuildContext context) {
    return Overlay.of(context);
  }

  static OverlayState? insertOverlay(BuildContext context, OverlayEntry entry) {
    return Overlay.of(context)?..insert(entry);
  }
  ///--------------------------------------------------------------------------------------------------
  static Future pushNextPageIfNotExist(BuildContext context, Widget next, {required String name, dynamic arguments, bool maintainState = true}) {
    final list = getAllModalRoutes(context: context);
    var find = false;

    /// find by type ---------------------------------------------
    for(var m in list){
      var lastHash = 0;

      if(find) {
        break;
      }

      final elm = (m.subtreeContext as Element);

      void fn(element) {
        while(lastHash != element.hashCode){
          lastHash = element.hashCode;

          if(find) {
            break;
          }

          //if(element.toStringShort() == next.toStringShort()){
          if(element.runtimeType == next.runtimeType){
            find = true;
            break;
          }

          element.visitChildElements(fn);
        }
      }

      elm.visitChildren(fn);
    }

    /// find bu name ---------------------------------------------
    if(!find){
      find = findRouteByName(list, name) != null;
    }

    if(find) {
      return Future.value(null);
    }

    return pushNextPage(context, next, name: name, arguments: arguments, maintainState: maintainState);
  }

  static Future pushNextPageIfNotCurrent<T extends Widget>(BuildContext context, T next,
      {required String name, dynamic arguments, bool maintainState = true}) {

    /// find parents are same T
    final type = (context as Element).findAncestorWidgetOfExactType();

    if(type != null) {
      return Future.value(null);
    }

    return pushNextPage(context, next, name: name, arguments: arguments, maintainState: maintainState);
  }

  static Future<T?> pushNextPage<T>(BuildContext context, Widget next, {required String name, dynamic arguments, bool maintainState = true}) {
    return Navigator.push<T>(context,
        MaterialPageRoute(builder: (ctx) {return next;},
            settings: RouteSettings(name: name, arguments: arguments),
            maintainState: maintainState)
    );
  }

  static Future<T?> pushNextPageExtra<T>(BuildContext context, Widget next, {
    required String name,
    dynamic arguments,
    bool maintainState = true,
    Duration duration = const Duration(milliseconds: 700),
  }) {
    return Navigator.push<T>(
      context,
        PageRouteBuilder(
            transitionDuration: duration,
            reverseTransitionDuration: duration,
            barrierLabel: name,
            settings: RouteSettings(name: name, arguments: arguments),
            maintainState: maintainState,
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
              return next;
            }),
    );
  }

  static Future pushNextPageWithSettings(BuildContext context, Widget next, RouteSettings settings) {
    final mr = MaterialPageRoute(builder: (buildContext) {return next;}, settings: settings);

    return Navigator.push(context, mr);
  }

  // Material(type: MaterialType.transparency,)
  static Future pushNextTransparentPage(BuildContext context, Widget next, {required String name}) {
    return Navigator.push(context,
        PageRouteBuilder(
            opaque: false,
          pageBuilder: (ctx, ani1, anim2) {return next;},
            settings: RouteSettings(name: name))
    );
  }

  static Future replaceCurrentRoute(BuildContext context, Widget next, {required String name, dynamic data}) {
    return Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (buildContext) {return next;}, settings: RouteSettings(name: name, arguments: data)),);
  }

  static Future pushNextAndRemoveUntilRoot(BuildContext context, Widget next, {required String name, dynamic data}) {
    final mpr = MaterialPageRoute(builder: (buildContext) {return next;},
        settings: RouteSettings(name: name, arguments: data));

    return Navigator.of(context).pushAndRemoveUntil(mpr, (route) => route.settings.name == '/');
    // or
    //return Navigator.pushAndRemoveUntil(context, mpr, ModalRoute.withName('/'));
  }

  static void popRoutesUntilRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.settings.name == '/');
  }

  static void popRoutesUntil(BuildContext context, ModalRoute? keep) {
    if(keep == null) {
      return;
    }

    Navigator.of(context).popUntil((route) => route == keep);
  }

  static void popRoutesUntilPageName(BuildContext context, String name) {
    final m = findRouteByName(getAllModalRoutes(context: context), name);
    popRoutesUntil(context, m);
  }

  static Future pushNextWithRoute(BuildContext context, PageRoute route){
    return Navigator.push(context, route); // same: Navigator.of(context).push(route)
  }

  static Future pushNextWithCreator(BuildContext context, Widget Function(BuildContext context) screenCreator, {RouteSettings? settings}){
    return Navigator.push(context, MaterialPageRoute(builder: screenCreator, settings: settings));
  }

  static void pop(BuildContext context, {dynamic result}) async {
    Navigator.of(context).pop(result);
  }

  /// check willPop before pop
  static Future maybePop(BuildContext context, {dynamic result}){
    return Navigator.of(context).maybePop(result);
  }

  static bool popByRouteNameForce(BuildContext context, String routeName, {dynamic result}){
    final route = accessModalRouteByRouteName(context, routeName);

    if(route == null) {
      return false;
    }

    if(route.isCurrent) {
      Navigator.of(context).pop(result);
    }
    else {
      Navigator.of(context).removeRoute(route);
    }

    return true;
  }

  static bool popByRouteName(BuildContext context, String routeName, {dynamic result}){
    final route = accessModalRouteByRouteName(context, routeName);

    if(route == null || !route.isCurrent) {
      return false;
    }

    Navigator.of(context).pop(result);
    return true;
  }

  static void backRoute(BuildContext curPageContext, {Duration? delay}) async {
    void run() {
      final list = getAllModalRoutes(context: curPageContext);
      final ModalRoute? myPage = ModalRoute.of(curPageContext);

      if(myPage == null) {
        return;
      }

      final before = findBefore(list, myPage);
      Navigator.of(curPageContext).popUntil((route) => route == before);
    }

    if(delay == null) {
      run();
    } else{
      Future.delayed(delay, run);
    }
  }

  static void backSimulate(BuildContext context) async{
    BuildContext lastCtx;
    BuildContext stableCtx;

    lastCtx = getLastRouteContext(context);
    stableCtx = getStableContext(lastCtx);

    final ScaffoldState? scaffoldState = findEndChildContext(lastCtx).findAncestorStateOfType();
    final ModalRoute? myPage = ModalRoute.of(lastCtx);

    if(myPage == null) {
      return;
    }

    if(scaffoldState != null){
      ScaffoldMessenger.of(lastCtx).removeCurrentSnackBar();
      //old: scaffoldState.removeCurrentSnackBar();

      if(scaffoldState.isDrawerOpen) {
        Navigator.pop(scaffoldState.context);
        await Future.delayed(const Duration(milliseconds: 200), (){});
      }
    }

    /// if is opened dialog, page, ...
    while (!myPage.isCurrent && Navigator.of(stableCtx).canPop()) {
      Navigator.pop(stableCtx);
      await Future.delayed(const Duration(milliseconds: 200), () {});
      //ctx = findLastContextA(ctx);
    }

    if(Navigator.of(stableCtx).canPop()) {
      Navigator.pop(stableCtx);
      Navigator.of(stableCtx).finalizeRoute(myPage);
    }
  }

  static PageRouteBuilder generatePageRouteByAnimation(BuildContext context,
      Widget Function(dynamic ctx, dynamic anim1, dynamic anim2) pageBuilder,
      Widget Function(dynamic ctx, dynamic anim1, dynamic anim2, dynamic w) transitionBuilder,
      Duration dur, {RouteSettings? settings}){

    return PageRouteBuilder(pageBuilder: pageBuilder, //(context, animation, secondaryAnimation) ==> screen()
        settings: settings,
        transitionDuration: dur,
        transitionsBuilder: transitionBuilder //(context, animation, secondaryAnimation, child){}
    );
  }



//============================================================================================
/*
    - [FocusScope/_FocusScopeState] extends [Focus] extends StatefulWidget
    - [ExcludeFocus] extends StatelessWidget
    - [_FocusMarker] extends InheritedNotifier

    - [FocusScopeNode] extends [FocusNode] with ChangeNotifier

    * children VS descendants:
      children : contains first child of object.
      descendants : contains first child of object and children of them.

    - Navigator is widget Included ModalRoute.
    - ModalRoute is a (page or dialog) that hold a tree of widgets

* -------------------------------------------------------------------------------------------------------------
    * Navigator:

    - Navigator.of()    =>    return current Navigator
    - Navigator.of(ctx, rootNavigator: false);    ==    ModalRoute.of(ctx).navigator;
    - Navigator.of().focusScopeNode.context  OR  Navigator.of().context  ==> return First element of scope of active page.

    - children of Navigator:
      * HeroControllerScope
          Listener
            AbsorbPointer
              FocusScope
                Semantics
                  _FocusMarker
                    UnmanagedRestorationScope
                      Overlay
                        _Theatre
                          _OverlayEntryWidget       <<-- root page
                            TickerMode
                              _EffectiveTickerMode
                                Semantics
                                  _ModalScope
                                    _ModalScopeStatus
                                      Offstage
                          _OverlayEntryWidget       <<-- page 1
                            TickerMode
                              _EffectiveTickerMode
                                Semantics
                                  _ModalScope
                                    _ModalScopeStatus
                                      Offstage
* -----------------------------------------------------------------------------------------------------------------
    * ModalRoute:

    - ModalRoute.of()   =>    return current page
    - ModalRoute.of().subtreeContext  ==> return First widget of current page.

    - children of Module:
        Builder < Semantics < [ManagerRootScreen] < WillPopScope < Scaffold ...
*----------------------------------------------------------------------------------------------------------------
    * any Push() rebuild widgets
 */
//============================================================================================
  /*
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.1, 0.0);
      var end = Offset(0.0, 0.1);
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );

SlideTransition()
FadeTransition()
RotationTransition()
ScaleTransition()
SizeTransition()
------------------------------------------------------------------------------
PageRouteBuilder(
  pageBuilder: (c, a1, a2) => new NextScreen(),
  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
  transitionDuration: Duration(milliseconds: 2000),
),
------------------------------------------------------------------------------
extends CupertinoPageRoute
extends MaterialPageRoute
------------------------------------------------------------------------------
@override
Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
  return new RotationTransition(
      turns: animation,
      child: new ScaleTransition(
        scale: animation,
        child: new FadeTransition(
          opacity: animation,
          child: new SecondPage(),
        ),
      ));
}
   */

//============================================================================================
}