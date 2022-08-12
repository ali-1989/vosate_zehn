import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:shaped_bottom_bar/models/shaped_item_object.dart';
import 'package:shaped_bottom_bar/shaped_bottom_bar.dart';
import 'package:shaped_bottom_bar/utils/arrays.dart';
import 'package:vosate_zehn/services/aidService.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/genDrawerMenu.dart';

class HomePage extends StatefulWidget {
  static final route = GoRoute(
    path: '/',
    name: (HomePage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => HomePage(key: AppBroadcast.homeScreenKey,),
  );

  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}
///=================================================================================================
class HomePageState extends StateBase<HomePage> {
  late GlobalKey<ScaffoldState> scaffoldState;
  int selectedItem = 0;


  @override
  initState(){
    super.initState();
    scaffoldState = GlobalKey<ScaffoldState>();
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
              child: buildBody()
          ),
          drawer: DrawerMenuBuilder.getDrawer(),
          bottomNavigationBar: buildNavBar(),
        );
      }
    );
  }

  Widget buildBody(){
    return Builder(
        builder: (ctx){
          /*if(assistCtr.hasState(AssistController.state$normal)){

          }*/

          return PageView(
            children: [
              Text('p1'),
              Text('p2'),
            ],
          );
        }
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
        selectedItemIndex: selectedItem,
        //textStyle: AppThemes.instance.currentTheme.baseTextStyle,
        listItems: [
          ShapedItemObject(iconData: AppIcons.home, title: AppMessages.home),
          ShapedItemObject(iconData: AppIcons.meditation, title: AppMessages.meditation),
          ShapedItemObject(iconData: AppIcons.zoomIn, title: AppMessages.tamarkoz),
          ShapedItemObject(iconData: AppIcons.motion, title: AppMessages.motion),
          ShapedItemObject(iconData: AppIcons.playArrow, title: AppMessages.video),
        ],
        onItemChanged: (position) {
          selectedItem = position;
          //setState(() {});
        },
    );
  }

  static void gotoAidPage(){
    AidService.gotoAidPage();
  }
}
