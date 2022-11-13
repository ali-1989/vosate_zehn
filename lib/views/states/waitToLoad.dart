import 'package:flutter/material.dart';

class WaitToLoad extends StatelessWidget {

  const WaitToLoad({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
