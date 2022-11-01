import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:webviewx/webviewx.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/progressView.dart';

class PayWebPage extends StatefulWidget {
  final String url;

  static final route = GoRoute(
    path: '/payPage',
    name: (PayWebPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => PayWebPage(url: state.extra as String),
  );

  const PayWebPage({required this.url, Key? key}) : super(key: key);

  @override
  State<PayWebPage> createState() => _PayWebPageState();
}
///==================================================================================
class _PayWebPageState extends StateBase<PayWebPage> {
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
    return Stack(
      children: [
        Opacity(
          opacity: isInPreparing? 0.01 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: WebViewX(
              height: double.infinity,
              width: double.infinity,
              initialContent: widget.url,
              initialSourceType: SourceType.url,
              onWebViewCreated: (ctr){
                if(webController == null) {
                  webController = ctr;
                  assistCtr.updateMain();
                }
              },
              onPageFinished: (str){
                isInPreparing = false;
                assistCtr.updateMain();
              },
            ),
          ),
        ),

      if(isInPreparing)
        ProgressView(),
      ],
    );
  }
}
