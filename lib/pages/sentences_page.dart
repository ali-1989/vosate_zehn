import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/waitToLoad.dart';

class SentencesPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/Sentences',
    name: (SentencesPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => SentencesPage(),
  );

  const SentencesPage({Key? key}) : super(key: key);

  @override
  State<SentencesPage> createState() => _SentencesPageState();
}
///==================================================================================
class _SentencesPageState extends StateBase<SentencesPage> {

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
              title: Text(AppMessages.sentencesTitle),
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
      return Center(child: Text('بدون دیتا'));
    }
  }
}
