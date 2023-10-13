import 'package:flutter/material.dart';

import 'package:app/tools/app/app_messages.dart';

class EmptyData extends StatelessWidget {
  final TextStyle? textStyle;
  final String? message;
  final VoidCallback? onTryAgain;
  final Widget? backButton;
  final Color? backgroundColor;

  const EmptyData({
    this.textStyle,
    this.message,
    this.onTryAgain,
    this.backgroundColor,
    this.backButton,
    Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor?? Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),

          Visibility(
            visible: backButton != null,
            child: backButton?? SizedBox(),
          ),

          Expanded(
            child: SizedBox(
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message?? AppMessages.thereAreNoResults,
                            style: textStyle?? const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          /// --- onTryAgain
                          Visibility(
                              visible: onTryAgain != null,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 10),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 23,
                                    constraints: BoxConstraints.tightFor(),
                                    onPressed: (){
                                      onTryAgain?.call();
                                    },
                                    icon: Icon(Icons.refresh, color: Colors.blue),
                                  )
                                ],
                              )
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
