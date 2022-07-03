import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/stateManagers/assist.dart';
import 'package:vosate_zehn/system/stateBase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
///=================================================================================================
class _HomePageState extends StateBase<HomePage> {

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
            return ElevatedButton(
                onPressed: (){
                  assistCtr.removeState(AssistController.state$normal);
                  assistCtr.updateMain();
                  },
                child: Text('hi')
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
