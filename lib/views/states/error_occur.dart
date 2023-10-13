import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';

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
    return ColoredBox(
      color: backgroundColor?? Colors.transparent,//Colors.grey.shade200
      child: Column(
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
                      		Text(message?? AppMessages.errorOccurTryAgain,
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
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}
