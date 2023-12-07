import 'package:flutter/cupertino.dart';

class AppPop {
  AppPop._();

  static RelativeRect findPosition(BuildContext context, {Offset offset = Offset.zero}){
    final button = context.findRenderObject()! as RenderBox;
    final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;

    final rect = Rect.fromPoints(
      button.localToGlobal(offset, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero) + offset, ancestor: overlay));

    return RelativeRect.fromRect(rect, Offset.zero & overlay.size);
  }
}


/*
showMenu(
    context: context,
    position: AppPop.findPosition(ctx),
    items: [
      PopupMenuItem(child: Text('mmm '), height: 30),
      PopupMenuItem(child: Text('zzz')),
    ],
);
 */
