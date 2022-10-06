import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/system/extensions.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';


typedef OnSelect = void Function(GenderType sex);

enum GenderType {
  woman,
  man,
  other
}
///================================================================================================
class SelectGenderView extends StatefulWidget {
  final String? title;
  final GenderType genderType;
  final String? buttonText;
  final TextStyle? textStyle;
  final bool showButton;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final OnSelect? onSelect;

  SelectGenderView({
    this.title,
    this.genderType = GenderType.other,
    this.buttonText,
    this.showButton = true,
    this.textStyle,
    this.borderRadius,
    this.border,
    this.onSelect,
    Key? key,
    }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectGenderViewState();
  }
}
///==============================================================================================
class SelectGenderViewState extends State<SelectGenderView> {
  late GenderType gender;

  @override
  void initState() {
    super.initState();

    gender = widget.genderType;
  }

  @override
  Widget build(BuildContext context) {
    //Color itemColor = iconColor?? AppThemes.currentTheme.textColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppThemes.instance.currentTheme.backgroundColor,
        borderRadius: widget.borderRadius,
        border: widget.border,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: widget.showButton,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: widget.showButton,
                    child: TextButton(
                      child: Text('${widget.buttonText?? context.t('select')}', style: widget.textStyle),
                      onPressed: (){
                        onButtonClick();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 5),

          Scrollbar(
            thumbVisibility: true,
            child: ListView(
              shrinkWrap: true,
              children: [
                Visibility(
                  visible: widget.title != null,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Text('${widget.title}').color(AppThemes.instance.currentTheme.textColor),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Align(
                    child: ToggleSwitch(
                      initialLabelIndex: gender.index,
                      totalSwitches: 2,
                      animate: true,
                      activeFgColor: Colors.white,
                      inactiveFgColor: Colors.white,
                      textDirectionRTL: true,
                      animationDuration: 400,
                      labels: [AppMessages.woman, AppMessages.man],
                      onToggle: (index) {
                        if(index != null){
                          gender = GenderType.values[index];
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          )
        ],
      ),
    );
  }

  void onButtonClick(){
    if(widget.onSelect != null){
      widget.onSelect!.call(gender);
    }
    else {
      AppNavigator.pop(context, result: gender);
    }
  }
}
