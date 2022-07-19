import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:shaped_bottom_bar/models/shaped_item_object.dart';
import 'package:shaped_bottom_bar/shaped_bottom_bar.dart';
import 'package:shaped_bottom_bar/utils/arrays.dart';
import 'package:vosate_zehn/pages/e404_page.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';

class HomePage extends StatefulWidget {
  static final route = GoRoute(
    path: '/',
    name: (HomePage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => const HomePage(),
  );

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
///=================================================================================================
class _HomePageState extends StateBase<HomePage> {
  int selectedItem = 0;


  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
              child: buildBody()
          ),
          bottomNavigationBar: genNavBar(),
        );
      }
    );
  }

  Widget buildBody(){
    return Builder(
        builder: (ctx){
          if(assistCtr.hasState(AssistController.state$normal)){
            return Column(
              children: [
                ElevatedButton(
                    onPressed: (){
                      assistCtr.removeState(AssistController.state$normal);
                      assistCtr.updateMain();
                      },
                    child: Text('hi')
                ),

                ElevatedButton(
                    onPressed: (){
                      AppRoute.pushNamed(context, (E404Page).toString().toLowerCase());
                    },
                    child: Text('hi')
                ),
              ],
            );
          }

          return ElevatedButton(
              onPressed: (){
                assistCtr.addStateAndUpdate(AssistController.state$normal);
                },
              child: Text('bay')
          );
        }
    );
  }

  Widget genNavBar(){
    return ShapedBottomBar(
        backgroundColor:  Colors.grey,
        iconsColor:  Colors.white,
        listItems: [
          ShapedItemObject(iconData: Icons.settings, title: 'Settings'),
          ShapedItemObject(iconData: Icons.account_balance_outlined, title: 'Account'),
          ShapedItemObject(iconData: Icons.verified_user_rounded, title: 'User'),
          ShapedItemObject(iconData: Icons.login, title: 'Logout'),
        ],
        onItemChanged: (position) {
          setState(() {
            selectedItem = position;
          });
        },
        shapeColor: Colors.pink,
        selectedIconColor: Colors.white,
        shape: ShapeType.HEXAGONE,
        animationType: ANIMATION_TYPE.ROTATE,
    );
  }
}
