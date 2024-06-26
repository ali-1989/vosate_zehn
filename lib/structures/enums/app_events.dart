import 'package:iris_notifier/iris_notifier.dart';

enum AppEvents implements EventImplement {
  networkConnected(100),
  networkDisConnected(101),
  networkStateChange(102),
  webSocketConnected(105),
  webSocketDisConnected(106),
  webSocketStateChange(107),
  userPersonalInfoChange(110),
  newUserLogin(111),
  userLogoff(112),
  appResume(115),
  appPause(116),
  appDeAttach(117),
  firebaseTokenReceived(120),
  languageLevelChanged(130);

  final int _number;

  const AppEvents(this._number);

  int id(){
    return _number;
  }
}
