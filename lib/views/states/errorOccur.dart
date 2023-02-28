import 'package:flutter/material.dart';

import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/views/widgets/customCard.dart';

class ErrorOccur extends StatelessWidget {
  final TextStyle? textStyle;
  final String? message;
  final VoidCallback? onTryAgain;
  final Color? backgroundColor;
  final Widget? backButton;

  ErrorOccur({
    this.textStyle,
    this.message,
    this.backgroundColor,
    this.onTryAgain,
    this.backButton,
    Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ColoredBox(
        color: backgroundColor?? Colors.grey.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            /*Flexible(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 3/5,
                  child: Image.asset(AppImages.errorTry)
              )
            ),*/


            Flexible(
              child: Center(
                child: CustomCard(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //Image.asset(AppIcons.close),
                      Icon(AppIcons.close),
                      const SizedBox(width: 10),
                      Text(AppMessages.errorOccurTryAgain,
                        style: textStyle?? const TextStyle(fontWeight: FontWeight.bold),
                      ),

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
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
