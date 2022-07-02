import 'package:flutter/material.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';

class E404Page extends StatefulWidget {
  const E404Page({Key? key}) : super(key: key);

  @override
  State<E404Page> createState() => _E404PageState();
}
///============================================================================================
class _E404PageState extends State<E404Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SizedBox.expand(
              child: Center(
                child: Text(AppMessages.e404),
              )
          )
      ),
    );
  }
}
