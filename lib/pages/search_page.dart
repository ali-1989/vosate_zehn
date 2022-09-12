import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/search',
    name: (SearchPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => SearchPage(),
  );

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}
///====================================================================================================
class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
