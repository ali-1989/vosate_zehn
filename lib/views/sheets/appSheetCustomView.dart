import 'package:flutter/material.dart';

class AppSheetCustomView extends StatefulWidget {
  final Widget description;
  final Widget? title;
  final Widget? positiveButton;
  final Widget? negativeButton;
  final MainAxisAlignment buttonsAlignment;
  final Color contentColor;
  final EdgeInsets titlePadding;
  final EdgeInsets descriptionPadding;
  final EdgeInsets buttonsPadding;

  const AppSheetCustomView({
    super.key,
    required this.description,
    required this.contentColor,
    this.buttonsAlignment = MainAxisAlignment.end,
    this.titlePadding = const EdgeInsets.fromLTRB(12, 5, 12, 10),
    this.descriptionPadding = const EdgeInsets.fromLTRB(12, 2, 12, 2),
    this.buttonsPadding = const EdgeInsets.fromLTRB(12, 8, 12, 18),
    this.title,
    this.positiveButton,
    this.negativeButton,
  });

  @override
  State<AppSheetCustomView> createState() => _AppSheetCustomViewState();
}
///=============================================================================
class _AppSheetCustomViewState extends State<AppSheetCustomView> {

  @override
  void initState() {
    super.initState();
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
              padding: widget.titlePadding,
              child: DefaultTextStyle(
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
                child: widget.title?? const SizedBox(),
              ),
            ),
          ),

          Padding(
            padding: widget.descriptionPadding,
            child: widget.description,
          ),

          Visibility(
            visible: widget.positiveButton != null || widget.negativeButton != null,
            child: Padding(
              padding: widget.buttonsPadding,
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
