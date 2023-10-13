import 'package:flutter/material.dart';

class BackBtn extends StatelessWidget {
  final Color? color;
  final TextDirection textDirection;
  final Alignment align;
  final Widget? button;

  const BackBtn({
    Key? key,
    this.color,
    this.textDirection = TextDirection.ltr,
    this.align = Alignment.topLeft,
    this.button,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget backBtn = BackButton(color: color);

    if(button != null){
      backBtn = GestureDetector(
        onTap: (){
          Navigator.of(context).pop();
        },
        child: button,
      );
    }
    return Directionality(
      textDirection: textDirection,
      child: Align(
        alignment: Alignment.topLeft,
        child: backBtn,
      ),
    );
  }
}
