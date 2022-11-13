import 'package:flutter/material.dart';

import 'package:app/tools/app/appThemes.dart';

class ProgressBarPrompt extends StatefulWidget {
  final EdgeInsets? padding;
  final Stream<double> stream;
  final String? message;
  final String? buttonText;
  final VoidCallback? buttonEvent;

  const ProgressBarPrompt({
    Key? key,
    required this.stream,
    this.padding,
    this.message,
    this.buttonText,
    this.buttonEvent,
  }) : super(key: key);

  @override
  State<ProgressBarPrompt> createState() => _ProgressBarPromptState();
}
///=======================================================================================
class _ProgressBarPromptState extends State<ProgressBarPrompt> {

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: Colors.black,
        child: Padding(
            padding: widget.padding?? EdgeInsets.symmetric(horizontal: 50, vertical: 14),
          child: StreamBuilder<double>(
            stream: widget.stream,
            builder: (context, snapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                      builder: (ctx){
                        if(snapshot.connectionState == ConnectionState.none
                            || snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if(snapshot.data != null && snapshot.data! >= 1.0) {
                          return CircularProgressIndicator(
                            color: AppThemes.instance.currentTheme.primaryColor,
                            backgroundColor: Colors.blueGrey,
                          );
                        }

                        return CircularProgressIndicator(value: snapshot.data!,
                          color: AppThemes.instance.currentTheme.primaryColor,
                          backgroundColor: Colors.blueGrey,
                          //valueColor: AlwaysStoppedAnimation(Colors.yellow),
                        );
                      }
                  ),

                  SizedBox(height: 12,),
                  if(widget.message != null)
                    Text('${widget.message}', style: TextStyle(color: Colors.white),),

                  SizedBox(height: 12,),
                  if(widget.buttonEvent != null && widget.buttonText != null)
                    TextButton(
                      onPressed: widget.buttonEvent,
                      child: Text('${widget.buttonText}'),
                    ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
