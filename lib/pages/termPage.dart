import 'package:flutter/material.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/views/genAppBar.dart';

class TermPage extends StatefulWidget {
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
