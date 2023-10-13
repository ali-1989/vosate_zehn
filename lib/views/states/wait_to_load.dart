import 'package:flutter/material.dart';

class WaitToLoad extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? backButton;

  const WaitToLoad({
    this.backgroundColor,
    this.backButton,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor?? Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),

          Visibility(
            visible: backButton != null,
            child: backButton?? SizedBox(),
          ),

          Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
