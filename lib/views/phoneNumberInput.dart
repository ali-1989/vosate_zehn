import 'package:flutter/material.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';

class PhoneNumberInput extends StatefulWidget {
  final PhoneNumberInputController controller;
  final String? countryCode;
  final BoxDecoration? boxDecoration;
  final EdgeInsets? padding;

  const PhoneNumberInput({
    Key? key,
    required this.controller,
    this.countryCode,
    this.boxDecoration,
    this.padding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PhoneNumberInputState();
}
///================================================================================
class PhoneNumberInputState extends State<PhoneNumberInput> {
  late PhoneNumberInputController controller;
  late ThemeData theme;
  late BoxDecoration decoration;
  late InputDecoration inputDecoration;
  TextEditingController countryCtr = TextEditingController();
  TextEditingController phoneNumberCtr = TextEditingController();


  @override
  void initState() {
    super.initState();

    onInit();
  }

  @override
  void dispose() {
    countryCtr.dispose();
    phoneNumberCtr.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(PhoneNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    //if(oldWidget.controller != widget.controller){
    onInit();
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
                  onChanged: controller.onCountryTyping,
                  decoration: inputDecoration,
                ),
              ),

              const SizedBox(width: 8,),
              GestureDetector(
                onTap: controller.onTapCountryArrow,
                child: Baseline(
                  baselineType: TextBaseline.alphabetic,
                  baseline: 20,
                  child: RotatedBox(
                    quarterTurns: 3,
                      child: Icon(AppIcons.arrowLeftIos,
                        size: 14,
                        color: theme.textTheme.bodyText1!.color!.withAlpha(180),
                      )
                  ),
                ),
              ),
              const SizedBox(width: 8,),

              Expanded(
                child: TextField(
                  controller: phoneNumberCtr,
                  onChanged: controller.onNumberTyping,
                  decoration: inputDecoration,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onInit(){
    controller = widget.controller;
    controller._setState(this);

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
}
///================================================================================
typedef OnTyping = void Function(String text);

class PhoneNumberInputController {
  PhoneNumberInputState? _state;
  VoidCallback? onTapCountryArrow;
  OnTyping? onCountryTyping;
  OnTyping? onNumberTyping;

  void _setState(PhoneNumberInputState state){
    _state = state;
  }

  void setOnCountryTyping(OnTyping? typing){
    onCountryTyping = typing;
  }

  void setOnNumberTyping(OnTyping? typing){
    onNumberTyping = typing;
  }

  void setOnTapCountryArrow(VoidCallback? call){
    onTapCountryArrow = call;
  }

  String? getCountry(){
    return _state?.countryCtr.text;
  }

  String? getPhoneNumber(){
    return _state?.phoneNumberCtr.text;
  }

  TextEditingController? getCountryController(){
    return _state?.countryCtr;
  }

  TextEditingController? getNumberController(){
    return _state?.phoneNumberCtr;
  }
}