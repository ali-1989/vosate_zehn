import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/stateManagers/assist.dart';
import 'package:vosate_zehn/pages/e404_page.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
///=================================================================================================
class _LoginPageState extends StateBase<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, ctr, data) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
              child: buildBody()
          ),
        );
      }
    );
  }

  Widget buildBody(){
    return Builder(
        builder: (ctx){
          if(assistCtr.hasState(AssistController.state$normal)){
            return Column(
              children: [
                ElevatedButton(
                    onPressed: (){
                      assistCtr.removeState(AssistController.state$normal);
                      assistCtr.updateMain();
                      },
                    child: Text('hi')
                ),

                ElevatedButton(
                    onPressed: (){
                      AppRoute.pushNamed(context, (E404Page).toString().toLowerCase());
                    },
                    child: Text('hi')
                ),
              ],
            );
          }

          return ElevatedButton(
              onPressed: (){
                assistCtr.addStateAndUpdate(AssistController.state$normal);
                },
              child: Text('bay')
          );
        }
    );
  }
}
