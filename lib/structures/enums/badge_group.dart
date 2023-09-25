import 'package:iris_tools/modules/stateManagers/updater_state.dart';

enum BadgesGroup implements UpdaterGroupId {
  none(100);

  final int _number;

  const BadgesGroup(this._number);

  int getNumber(){
    return _number;
  }
}
