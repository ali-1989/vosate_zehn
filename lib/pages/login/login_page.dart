import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:vosate_zehn/services/google.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/views/genAppBar.dart';

class LoginPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/login',
    name: (LoginPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => const LoginPage(),
  );

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
///=================================================================================================
class _LoginPageState extends StateBase<LoginPage> {
  String? res1;
  String? res2;

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          appBar: GenAppBar(
            title: Text(AppMessages.loginTitle),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      }
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        Text('t1: $res1'),
        Text('t2: $res2'),

        ElevatedButton(
            onPressed: () async {
              //AppRoute.pushNamed(context, (E404Page).toString().toLowerCase());
              final res = await Google.handleSignIn();
              res1 = res?.displayName;
              res2 = res?.email;

              setState(() {});
            },
            child: Text('go')
        ),
      ],
    );
  }
}
