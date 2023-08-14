import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:webviewx/webviewx.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/views/baseComponents/appBarBuilder.dart';
import 'package:app/views/states/waitToLoad.dart';

class PayWebPage extends StatefulWidget{
  final String url;

  const PayWebPage({required this.url, Key? key}) : super(key: key);

  @override
  State<PayWebPage> createState() => _PayWebPageState();
}
///==================================================================================
class _PayWebPageState extends StateBase<PayWebPage> {
  bool isInPreparing = true;
  WebViewXController? webController;

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
                  assistCtr.updateHead();
                }
              },
              onPageFinished: (str){
                isInPreparing = false;
                assistCtr.updateHead();
              },
            ),
          ),
        ),

      if(isInPreparing)
        WaitToLoad(),
      ],
    );
  }
}
