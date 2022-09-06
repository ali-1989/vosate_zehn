
class PagesEventBus {
  PagesEventBus._();

  static final List<EventBus> _events = [];

  static EventBus getEventBus(String id){
    final idx = _events.indexWhere((element) => element.id == id);

    if(idx > -1){
      return _events[idx];
    }

    final e = EventBus._()..id = id;
    _events.add(e);

    return e;
  }

  static void removeFor(String id){
    _events.removeWhere((element) => element.id == id);
  }
}
///===============================================================================
class EventBus {
  late final String id;
  final List<_Event> _events = [];

  EventBus._();

  void addEvent(String name, void Function(dynamic param) event){
    if(exist(name)){
      _get(name)!.event = event;
      return;
    }

    final e = _Event();
    e.name = name;
    e.event = event;

    _events.add(e);
  }

  void removeEvent(String name){
    _events.removeWhere((element) => element.name == name);
  }

  bool exist(String name){
    return _events.indexWhere((element) => element.name == name) > -1;
  }

  _Event? _get(String name){
    final idx = _events.indexWhere((element) => element.name == name);

    if(idx > -1){
      return _events[idx];
    }

    return null;
  }

  void callEvent(String name, dynamic data){
    try {
      _get(name)?.event.call(data);
    }
    catch (e){/**/}
  }
}
///===============================================================================
class _Event {
  late String name;
  late void Function(dynamic param) event;
}