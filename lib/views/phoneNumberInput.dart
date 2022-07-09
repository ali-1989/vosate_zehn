import 'package:flutter/material.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';

class PhoneNumberInput extends StatefulWidget {
  final String? countryCode;
  final BoxDecoration? boxDecoration;
  final EdgeInsets? padding;

  const PhoneNumberInput({
    Key? key,
    this.countryCode,
    this.boxDecoration,
    this.padding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PhoneNumberInputState();
}
///================================================================================
class PhoneNumberInputState extends State<PhoneNumberInput> {
  late ThemeData theme;
  late BoxDecoration decoration;
  late InputDecoration inputDecoration;
  TextEditingController countryCtr = TextEditingController();
  TextEditingController phoneNumberCtr = TextEditingController();


  @override
  void initState() {
    super.initState();

    countryCtr.text = widget.countryCode?? '';
    decoration = widget.boxDecoration ?? const BoxDecoration(
      //borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
      border: Border(bottom: BorderSide(color: Colors.black54)),
    );

    inputDecoration = const InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: widget.padding?? const EdgeInsets.all(0),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: TextField(
                  controller: countryCtr,
                  decoration: inputDecoration,
                ),
              ),

              const SizedBox(width: 8,),
              Baseline(
                baselineType: TextBaseline.alphabetic,
                baseline: 20,
                child: RotatedBox(
                  quarterTurns: 3,
                    child: Icon(AppIcons.arrowLeftIos, size: 14, color: theme.textTheme.bodyText1!.color!.withAlpha(180),)
                ),
              ),
              const SizedBox(width: 8,),

              Expanded(
                child: TextField(
                  controller: phoneNumberCtr,
                  decoration: inputDecoration,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}