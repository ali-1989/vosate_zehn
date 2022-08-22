import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/system/stateBase.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/waitToLoad.dart';

class LastSeenPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/LastSeenPage',
    name: (LastSeenPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => LastSeenPage(),
  );

  const LastSeenPage({Key? key}) : super(key: key);

  @override
  State<LastSeenPage> createState() => _LastSeenPageState();
}
///==================================================================================
class _LastSeenPageState extends StateBase<LastSeenPage> {

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
