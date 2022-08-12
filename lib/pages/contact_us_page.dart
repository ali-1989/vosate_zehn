import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

class ContactUsPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/ContactUsPage',
    name: (ContactUsPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => ContactUsPage(),
  );

  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}
///==================================================================================
class _ContactUsPageState extends StateBase<ContactUsPage> {

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
