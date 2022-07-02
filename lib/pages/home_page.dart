import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appNavigator.dart';
import 'package:vosate_zehn/tools/app/appSheet.dart';
import 'package:vosate_zehn/tools/app/appSnack.dart';

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
                    AppSheet.showSheetDialog(ccc,
                        title: 'hasan',
                        message: 'fgfg dfgfgfdg fdgg',
                      actions: [
                        IconsButton(
                          onPressed: () {},
                          text: 'Delete',
                          iconData: Icons.delete,
                          color: Colors.red,
                          textStyle: TextStyle(color: Colors.white),
                          iconColor: Colors.white,
                        )
                      ]
                    );
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
