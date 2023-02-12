import 'dart:async';

import 'package:iris_tools/api/generator.dart';


/*
Alternative:
  import 'package:iris_tools/modules/stateManagers/notifyRefresh.dart';
  static final NotifyBroadcast userProfileNotifier = NotifyBroadcast();
 */

typedef EventFunction = void Function({dynamic data});
///==============================================================================
class EventDispatcherService {
  static final Map<EventDispatcher, List<EventFunction>> _functions = {};
  static final Map<EventDispatcher, StreamController<int>> _streams = {};

  EventDispatcherService._();

  static void attachFunction(EventDispatcher event, EventFunction func){
    if(!_functions.containsKey(event)){
      _functions[event] = <EventFunction>[];
    }

    if(_functions[event]!.contains(func)){
      return;
    }

    _functions[event]?.add(func);
  }

  static void deAttachFunction(EventDispatcher event, EventFunction func){
    if(!_functions.containsKey(event)){
      return;
    }

    if(_functions[event]!.remove(func)){
      return;
    }
  }

  static Stream<dynamic> getStream(EventDispatcher event){
    if(!_streams.containsKey(event)){
      _streams[event] = StreamController.broadcast();
    }

    return _streams[event]!.stream;
  }

  static notify(EventDispatcher event, {dynamic data}){
    for (final ef in _functions.entries) {
      if (ef.key == event) {
        for (final f in ef.value) {
          try {
            f.call(data: data);
          }
          catch (e) {
            /**/
          }
        }
        break;
      }
    }

    for(final ef in _streams.entries){
      if(ef.key == event){
        try{
          ef.value.sink.add(data?? Generator.getRandomInt(10, 9999));
        }
        catch(e){/**/}
        break;
      }
    }
  }

  static notifyFor(List<EventDispatcher> events, {dynamic data}){
    for(final e in events){
      notify(e, data: data);
    }
  }
}
///==============================================================================
enum EventDispatcher {
  networkConnected(100),
  networkDisConnected(101),
  networkStateChange(102),
  webSocketConnected(105),
  webSocketDisConnected(106),
  webSocketStateChange(107),
  userProfileChange(110),
  userLogin(111),
  userLogoff(112),
  appResume(115),
  appPause(116),
  appDeatach(117);

  final int _number;

  const EventDispatcher(this._number);

  int getNumber(){
    return _number;
  }
}