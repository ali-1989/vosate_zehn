import 'package:iris_tools/modules/stateManagers/assist.dart';

enum AssistGroup implements GroupId {
  updateAudioSeen(100);

  final int _number;

  const AssistGroup(this._number);

  int getNumber(){
    return _number;
  }
}
