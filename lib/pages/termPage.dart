import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/views/genAppBar.dart';

class TermPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/term',
    name: (TermPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => TermPage(),
  );

  const TermPage({Key? key}) : super(key: key);

  @override
  State<TermPage> createState() => _TermPageState();
}
///==================================================================================
class _TermPageState extends StateBase<TermPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenAppBar(
            title: Text(AppMessages.termTitle),
      ),
      body: SafeArea(
          child: buildBody()
      ),
    );
  }

  Widget buildBody(){
    return Text('');
  }
}
