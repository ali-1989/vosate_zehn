import 'package:flutter/material.dart';

class EmptyApp extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  EmptyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      builder: (ctx, home){
        return const SizedBox.expand();
      },
    );
  }
}
