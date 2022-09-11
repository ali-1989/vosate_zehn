import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:shaped_bottom_bar/models/shaped_item_object.dart';
import 'package:shaped_bottom_bar/shaped_bottom_bar.dart';
import 'package:shaped_bottom_bar/utils/arrays.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/pages/home_to_home_page.dart';
import 'package:app/pages/levels/bucket_page.dart';
import 'package:app/services/aidService.dart';
import 'package:app/system/enums.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/genDrawerMenu.dart';

class HomePage extends StatefulWidget {
  static final route = GoRoute(
    path: '/',
    name: (HomePage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => HomePage(key: AppBroadcast.homeScreenKey),
  );

  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}
///=================================================================================================
class HomePageState extends StateBase<HomePage> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  int selectedPage = 0;
  late PageController pageController;


  @override
  initState(){
    super.initState();

    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
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
    );
  }

  Widget buildBody(){
    return Padding(
      padding: EdgeInsets.only(bottom: 50),
      child: PageView(
          physics: NeverScrollableScrollPhysics(),
        allowImplicitScrolling: false,
        controller: pageController,
        children: [
          HomeToHomePage(),
          BucketPage(injectData: BucketPageInjectData()..bucketTypes = BucketTypes.meditation),
          BucketPage(injectData: BucketPageInjectData()..bucketTypes = BucketTypes.focus),
          BucketPage(injectData: BucketPageInjectData()..bucketTypes = BucketTypes.motion),
          BucketPage(injectData: BucketPageInjectData()..bucketTypes = BucketTypes.video),
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
        IconButton(
            onPressed: gotoAidPage,
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.cashMultiple, size: 20,),
                Text(AppMessages.aid, style: TextStyle(fontSize: 11),),
              ],
            )
        ),

        IconButton(
            onPressed: (){},
            icon: Icon(AppIcons.search)
        ),
      ],
    );
  }

  Widget buildNavBar(){
    return ShapedBottomBar(
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
          ShapedItemObject(iconData: AppIcons.zoomIn, title: AppMessages.focus),
          ShapedItemObject(iconData: AppIcons.motion, title: AppMessages.motion),
          ShapedItemObject(iconData: AppIcons.playArrow, title: AppMessages.video),
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

    //setState(() {});
  }

  void gotoAidPage(){
    AidService.gotoAidPage();
  }
}
