import 'package:flutter/material.dart';

class BackBtn extends StatelessWidget {
  final Color? color;

  const BackBtn({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: BackButton(color: color),
      ),
    );
  }
}
