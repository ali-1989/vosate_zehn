import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? errorLog;

  const ErrorPage({super.key, this.errorLog});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.expand(
          child: ColoredBox(
            color: Colors.brown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('an Error is occurred.'),
                Text(errorLog?? ''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
