import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? radius;

  const CustomCard({
    required this.child,
    this.padding,
    this.radius,
    this.color,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius?? 8),
        child: ColoredBox(
            color: color?? Colors.white,
            child: Padding(
              padding: padding?? EdgeInsets.zero,
              child: child,
            )
        )
    );
  }
}