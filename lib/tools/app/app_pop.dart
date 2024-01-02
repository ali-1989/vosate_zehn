import 'package:flutter/cupertino.dart';

class AppPop {
  AppPop._();

  static RelativeRect findPosition(BuildContext context, {Offset offset = Offset.zero}){
    final renderObj = context.findRenderObject()! as RenderBox;
    final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;

    final rect = Rect.fromPoints(
      renderObj.localToGlobal(offset, ancestor: overlay),
      renderObj.localToGlobal(renderObj.size.bottomRight(Offset.zero) + offset, ancestor: overlay));

    return RelativeRect.fromRect(rect, Offset.zero & overlay.size);
  }
}


/*
showMenu(
    context: ctx,
    color: Colors.transparent,
    elevation: 0,
    position: AppPop.findPosition(ctx),
    items: [
      PopupMenuItem(child: Text('mmm '), height: 30),
      or
      PopupMenuItem(
         child: Card(
           child: Column(...)
         )
      ),
    ],
);
===================================================
 Theme(
      data: AppThemes.instance.themeData.copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton(
            itemBuilder: supportMenuItemBuilder,
            color: Colors.transparent,
            elevation: 0,
            child: Image.asset(AppImages.supportIco, width: 40, height: 40)
        )
     )



   List<PopupMenuEntry> supportMenuItemBuilder(BuildContext ctx) {
    return [
      PopupMenuItem()
      ];
    )
 */
