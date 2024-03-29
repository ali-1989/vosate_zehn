import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:shaped_bottom_bar/models/shaped_item_object.dart';
import 'package:shaped_bottom_bar/shaped_bottom_bar.dart';
import 'package:shaped_bottom_bar/utils/arrays.dart';

import 'package:app/services/aid_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/baseComponents/drawer_builder.dart';
import 'package:app/views/pages/home_page.dart';
import 'package:app/views/pages/levels/bucket_page.dart';
import 'package:app/views/pages/search_page.dart';

class LayoutPage extends StatefulWidget{

  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => LayoutPageState();
}
///=============================================================================
class LayoutPageState extends StateSuper<LayoutPage> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  int selectedPage = 0;
  late PageController pageController;
  ValueKey<int> bottomBarKey = const ValueKey<int>(1);

  bool onPop<s extends StateSuper>(s state, bool? last) {
    if(last != null){
      MoveToBackground.moveTaskToBack();
    }

    return false;
  }

  @override
  initState(){
    super.initState();

    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: onPop(this, null),
      onPopInvoked: (s)=> onPop(this, s),
      child: Assist(
        controller: assistCtr,
          builder: (context, ctr, data) {
          return Scaffold(
            key: scaffoldState,
            appBar: buildAppBar(),
            body: SafeArea(
              bottom: false,
                child: buildBody()
            ),
            drawer: DrawerMenuBuilder.getDrawer(),
            extendBody: true,
            bottomNavigationBar: buildNavBar(),
          );
        }
      ),
    );
  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: PageView(
          physics: const NeverScrollableScrollPhysics(),
        allowImplicitScrolling: false,
        controller: pageController,
        children: [
          HomePage(),
          BucketPage(injectData: BucketPageInjectData()..bucketTypes = BucketTypes.meditation),
          BucketPage(injectData: BucketPageInjectData()..bucketTypes = BucketTypes.motion),
          BucketPage(injectData: BucketPageInjectData()..bucketTypes = BucketTypes.video),
          BucketPage(injectData: BucketPageInjectData()..bucketTypes = BucketTypes.focus),
        ],
      ),
    );
  }

  AppBar buildAppBar(){
    return AppBarCustom(
      title: Text(AppMessages.appName),
      /*leading: IconButton(
          onPressed: (){
          },
          icon: Icon(AppIcons.list)
      ),*/

      actions: [
        GestureDetector(
          onTap: gotoAidPage,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(AppIcons.cashMultiple, size: 20,),
              Text(AppMessages.aid, maxLines: 1, softWrap: false),
            ],
          ),
        ),

        IconButton(
            onPressed: (){
              RouteTools.pushPage(context, const SearchPage());
            },
            icon: const Icon(AppIcons.search)
        ),
      ],
    );
  }

  Widget buildNavBar(){
    return ShapedBottomBar(
      key: bottomBarKey,
        backgroundColor: AppThemes.instance.currentTheme.primaryColor,
        iconsColor: Colors.black,
        bottomBarTopColor: Colors.transparent,
        shapeColor: AppThemes.instance.currentTheme.differentColor,
        selectedIconColor: Colors.white,
        shape: ShapeType.PENTAGON,
        animationType: ANIMATION_TYPE.FADE,
        selectedItemIndex: selectedPage,
        //textStyle: AppThemes.instance.currentTheme.baseTextStyle,
        listItems: [
          ShapedItemObject(iconData: AppIcons.home, title: AppMessages.home),
          ShapedItemObject(iconData: AppIcons.meditation, title: AppMessages.meditation),
          ShapedItemObject(iconData: AppIcons.motion, title: AppMessages.motion),
          ShapedItemObject(iconData: AppIcons.playArrow, title: AppMessages.video),
          ShapedItemObject(iconData: AppIcons.zoomIn, title: AppMessages.focus),
        ],
        onItemChanged: (position) {
          selectedPage = position;

          pageController.jumpToPage(selectedPage);
          //setState(() {});
        },
    );
  }

  void gotoPage(idx){
    selectedPage = idx;
    pageController.jumpToPage(idx);

    bottomBarKey = ValueKey(bottomBarKey.value +1);
    setState(() {});
  }

  void gotoAidPage(){
    AidService.gotoAidPage();
  }
}
