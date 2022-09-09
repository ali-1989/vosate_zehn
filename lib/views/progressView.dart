import 'package:flutter/material.dart';


class ProgressView extends StatelessWidget {

  const ProgressView({
    Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
