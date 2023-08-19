import 'package:flutter/material.dart';

import 'package:app/tools/app/appIcons.dart';

class PhoneNumberInput extends StatefulWidget {
  final PhoneNumberInputController controller;
  final String? countryCode;
  final String? numberHint;
  final BoxDecoration? widgetDecoration;
  final BoxDecoration? countryDecoration;
  final BoxDecoration? numberDecoration;
  final EdgeInsets? padding;
  final bool showCountrySection;

  const PhoneNumberInput({
    Key? key,
    required this.controller,
    this.showCountrySection = true,
    this.countryCode,
    this.numberHint,
    this.widgetDecoration,
    this.countryDecoration,
    this.numberDecoration,
    this.padding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PhoneNumberInputState();
}
///================================================================================
class PhoneNumberInputState extends State<PhoneNumberInput> {
  late PhoneNumberInputController controller;
  late ThemeData theme;
  late BoxDecoration wholeDecoration;
  late BoxDecoration countryDecoration;
  late BoxDecoration numberDecoration;
  late InputDecoration inputDecoration;
  TextEditingController countryCtr = TextEditingController();
  TextEditingController phoneNumberCtr = TextEditingController();


  @override
  void initState() {
    super.initState();

    countryCtr.text = widget.countryCode?? '';
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

    if(oldWidget.countryCode != widget.countryCode){
      countryCtr.text = widget.countryCode?? '';
    }

    //if(oldWidget.controller != widget.controller){
    onInit();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: DecoratedBox(
        decoration: wholeDecoration,
        child: Padding(
          padding: widget.padding?? const EdgeInsets.all(0),
          child: Row(
            children: [

              Visibility(
                visible: widget.showCountrySection,
                child: DecoratedBox(
                  decoration: countryDecoration,
                  child: Row(
                  children: [
                    SizedBox(
                      width: 35,
                      child: TextField(
                        controller: countryCtr,
                        keyboardType: TextInputType.phone,
                        onChanged: controller.onCountryTyping,
                        decoration: inputDecoration,
                      ),
                    ),

                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: controller.onTapCountryArrow,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
                        child: Baseline(
                          baselineType: TextBaseline.ideographic,
                          baseline: 5,
                          child: RotatedBox(
                              quarterTurns: 3,
                              child: Icon(AppIcons.arrowLeftIos,
                                size: 14,
                                color: theme.textTheme.bodyLarge!.color!.withAlpha(180),
                              )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),

              const SizedBox(width: 10,),
              Expanded(
                child: DecoratedBox(
                  decoration: numberDecoration,
                  child: TextField(
                    controller: phoneNumberCtr,
                    keyboardType: TextInputType.phone,
                    onChanged: controller.onNumberTyping,
                    decoration: inputDecoration.copyWith(
                      hintText: widget.numberHint,
                    ),
                  ),
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

    wholeDecoration = widget.widgetDecoration ?? const BoxDecoration();

    countryDecoration = widget.countryDecoration ?? const BoxDecoration(
      //borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
      border: Border(bottom: BorderSide(color: Colors.black54)),
    );

    numberDecoration = widget.numberDecoration ?? countryDecoration;

    inputDecoration = const InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      isDense: true,
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

  String? getCountryCode(){
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
