import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/*class GenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar child;

  const GenAppBar({
    Key? key,
    required super.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(isWeb()){
      return const SizedBox();
    }

    return child;
  }

  @override
  Size get preferredSize {
    //MediaQuery.of(context).padding.top + kToolbarHeight;
    // AppBar().preferredSize.height;

    if(isWeb()){
      return Size.zero;
    }

    return const Size.fromHeight(kToolbarHeight);
  }

  bool isWeb(){
    return kIsWeb;
  }
}*/

class AppBarCustom extends AppBar {

  AppBarCustom({
    super.key,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.centerTitle,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    //super.shape,
  }) : super(
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
    )
  );

  @override
  Size get preferredSize {
    //MediaQuery.of(context).padding.top + kToolbarHeight;
    // AppBar().preferredSize.height;

    if(isWeb()){
      return const Size.fromHeight(60);
    }

    return const Size.fromHeight(kToolbarHeight);
  }

  bool isWeb(){
    return kIsWeb;
  }
}
