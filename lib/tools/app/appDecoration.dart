import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AppDecoration {
  AppDecoration._();

  static Color mainColor = Colors.amber;
  static Color secondColor = Colors.orange;
  static Color differentColor = const Color(0xFFFF006E);
  static Color orange = const Color(0xFFFF006E);

  static ClassicFooter classicFooter = const ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );
}