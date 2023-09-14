import 'package:iris_tools/modules/stateManagers/assist.dart';

enum AppAssistKeys implements GroupId {
  updateAudioSeen(100);

  final int _number;

  const AppAssistKeys(this._number);

  int getNumber(){
    return _number;
  }
}
