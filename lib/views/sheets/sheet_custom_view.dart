import 'package:flutter/material.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_decoration.dart';

class AppSheetCustomView extends StatefulWidget {
  final Widget description;
  final Widget? title;
  final Widget? positiveButton;
  final Widget? negativeButton;
  final MainAxisAlignment buttonsAlignment;
  final Color contentColor;
  final EdgeInsets? titlePadding;
  final EdgeInsets? descriptionPadding;
  final EdgeInsets? buttonsPadding;

  const AppSheetCustomView({
    super.key,
    required this.description,
    required this.contentColor,
    this.buttonsAlignment = MainAxisAlignment.end,
    this.titlePadding,
    this.descriptionPadding,
    this.buttonsPadding,
    this.title,
    this.positiveButton,
    this.negativeButton,
  });

  @override
  State<AppSheetCustomView> createState() => _AppSheetCustomViewState();
}
///=============================================================================
class _AppSheetCustomViewState extends StateSuper<AppSheetCustomView> {
  late EdgeInsets descriptionPadding;
  late EdgeInsets titlePadding;
  late EdgeInsets buttonsPadding;

  @override
  void initState() {
    super.initState();

    descriptionPadding = widget.descriptionPadding?? const EdgeInsets.fromLTRB(12, 2, 12, 2);
    titlePadding = widget.titlePadding?? EdgeInsets.fromLTRB(12, 5, 12, 8 *hRel);
    buttonsPadding = widget.buttonsPadding?? EdgeInsets.fromLTRB(12, 8, 12, 15 * hRel);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: widget.contentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5),

          Visibility(
            visible: widget.title != null,
            child: Padding(
              padding: titlePadding,
              child: DefaultTextStyle(
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: AppDecoration.fontSizeRelative(2),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
                child: widget.title?? const SizedBox(),
              ),
            ),
          ),

          Padding(
            padding: descriptionPadding,
            child: widget.description,
          ),

          Visibility(
            visible: widget.positiveButton != null || widget.negativeButton != null,
            child: Padding(
              padding: buttonsPadding,
              child: Row(
                mainAxisAlignment: widget.buttonsAlignment,
                children: [
                  widget.positiveButton ?? const SizedBox(),
                  widget.negativeButton ?? const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
