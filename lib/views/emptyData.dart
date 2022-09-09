import 'package:flutter/material.dart';

import 'package:app/tools/app/appMessages.dart';

class EmptyData extends StatelessWidget {
  final TextStyle? textStyle;

  const EmptyData({
    this.textStyle,
    Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppMessages.thereAreNoResults,
            style: textStyle?? TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
