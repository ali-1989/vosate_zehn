import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';
import 'package:webviewx/webviewx.dart';

class ZarinpalPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/payPage',
    name: (ZarinpalPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => ZarinpalPage(),
  );

  const ZarinpalPage({Key? key}) : super(key: key);

  @override
  State<ZarinpalPage> createState() => _ZarinpalPageState();
}
///==================================================================================
class _ZarinpalPageState extends StateBase<ZarinpalPage> {
  bool isInPreparing = true;
  WebViewXController? webController;

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
              title: Text(AppMessages.aidUs),
            ),
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    if(isInPreparing) {
      return WaitToLoad();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: WebViewX(
        height: double.infinity,
        width: double.infinity,
        initialContent: 'https://zarinp.al/vosatezehn.ir',
        initialSourceType: SourceType.url,
        onWebViewCreated: (ctr){
          isInPreparing = false;

          if(webController == null) {
            print('========= webController');
            webController = ctr;
            assistCtr.updateMain();
          }
        },
        onPageFinished: (str){
          print('========= onPageFinished  $str');
        },
        onPageStarted: (str){
          print('========= onPageStarted  $str');
        },
      ),
    );
  }
}
