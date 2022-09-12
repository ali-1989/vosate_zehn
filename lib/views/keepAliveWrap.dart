import 'package:flutter/material.dart';

class KeepAliveWrap extends StatefulWidget {
  final Widget child;

  const KeepAliveWrap({required this.child, Key? key}) : super(key: key);

  @override
  State<KeepAliveWrap> createState() => _KeepAliveWrapState();
}
///===================================================================================
class _KeepAliveWrapState extends State<KeepAliveWrap> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
   bool get wantKeepAlive => true;
}
