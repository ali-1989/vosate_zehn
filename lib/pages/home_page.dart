import 'package:flutter/material.dart';
import 'package:vosate_zehn/tools/app/appLoading.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appNotification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
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

          Builder(
            builder: (ccc) {
              return ElevatedButton(
                  onPressed: (){
                    AppNotification.sendNormalNotification('سلام', 'سلام چطوری');
                  },
                  child: Text('dialog'),
              );
            }
          ),
        ],
      ),
    );
  }
}
