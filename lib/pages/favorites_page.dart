import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

class FavoritesPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/FavoritesPage',
    name: (FavoritesPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => FavoritesPage(),
  );

  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}
///==================================================================================
class _FavoritesPageState extends StateBase<FavoritesPage> {

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (context, ctr, data) {
          return Scaffold(
            appBar: AppBarCustom(
              title: Text(AppMessages.lastSeenItem),
            ),
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    if(true) {
      return WaitToLoad();
    }
  }
}
