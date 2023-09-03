import 'package:flutter/material.dart';

class AppSheetView extends StatefulWidget {
  final Widget Function(BuildContext context) childBuilder;
  final Color contentColor;
  final EdgeInsets padding = EdgeInsets.zero;

  const AppSheetView({super.key,
    required this.childBuilder,
    required this.contentColor,
  });

  @override
  State<AppSheetView> createState() => _AppSheetViewState();
}
///=============================================================================
class _AppSheetViewState extends State<AppSheetView> {
  double? fixHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, siz) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            final r = context.findRenderObject() as RenderBox;
            final parentH = siz.maxHeight;
            final realH = r.size.height;

            if(fixHeight == null && realH + bottomPadding + 10 > parentH){
              fixHeight = parentH - bottomPadding - 40;
              setState(() {});
            }
            else {
              fixHeight = null;
            }
          });

          return ColoredBox(
            color: widget.contentColor,
            child: Padding(
              /// move dialog to above when keyboard is open
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Padding(
                padding: widget.padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        height: fixHeight,
                        child: widget.childBuilder(context)
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
