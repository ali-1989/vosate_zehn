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
          const SizedBox(height: 40),

          /*Flexible(
            flex: 2,
              child: AspectRatio(
                  aspectRatio: 3/5,
                  child: Image.asset(AppImages.notFound)
              )
          ),*/

          Flexible(
            flex: 1,
            child: Center(
              child: Text(AppMessages.thereAreNoResults,
                style: textStyle?? const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
