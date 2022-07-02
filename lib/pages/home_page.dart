import 'package:flutter/material.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    print('==========================build');
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(AppMessages.operationCanceled),
          Text(AppMessages.sorryYouDoNotHaveAccess),
          Text(AppMessages.accountIsBlock),
          Text(AppMessages.thereAreNoResults),
          Text(AppMessages.errorOccur),
          Text(AppMessages.pleaseWait),
        ],
      ),
    );
  }
}
