
typedef EventCaller = void Function(dynamic param);
///-----------------------------------------------------------------
class PagesEventService {
  PagesEventService._();

  static final List<EventBus> _events = [];

  static EventBus getEventBus(String pageId){
    final idx = _events.indexWhere((element) => element.id == pageId);

    if(idx > -1){
      return _events[idx];
    }

    final e = EventBus._()..id = pageId;
    _events.add(e);

    return e;
  }

  static void removeFor(String pageId){
    _events.removeWhere((element) => element.id == pageId);
  }
}
///===============================================================================
class EventBus {
  late final String id;
  final List<Event> _events = [];

  EventBus._();

  void addEvent(String eventName, EventCaller event){
    if(exist(eventName)){
      _get(eventName)!.event = event;
      return;
    }

    final e = Event();
    e.name = eventName;
    e.event = event;

    _events.add(e);
  }

  void removeEvent(String name){
    _events.removeWhere((element) => element.name == name);
  }

  bool exist(String name){
    return _events.indexWhere((element) => element.name == name) > -1;
  }

  Event? _get(String name){
    final idx = _events.indexWhere((element) => element.name == name);

    if(idx > -1){
      return _events[idx];
    }

    return null;
  }

  void callEvent(String name, dynamic parameters){
    try {
      _get(name)?.event.call(parameters);
    }
    catch (e){/**/}
  }
}
///===============================================================================
class Event {
  late String name;
  late EventCaller event;
}