import 'package:flutter/material.dart';

class AppRouterDelegate<T> extends RouterDelegate<T> {
  static AppRouterDelegate? _instance;

  AppRouterDelegate._();

  static AppRouterDelegate<T> instance<T>(){
    _instance ??= AppRouterDelegate<T>._();

    return _instance! as AppRouterDelegate<T>;
  }

  @override
  void addListener(VoidCallback listener) {
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Future<bool> popRoute() async {
    return true;
  }

  @override
  void removeListener(VoidCallback listener) {
  }

  @override
  Future<void> setNewRoutePath(configuration) async {
    return;
  }
}