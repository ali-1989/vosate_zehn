import 'package:app/tools/app/appThemes.dart';
import 'package:app/system/extensions.dart';
import 'package:flutter/material.dart';


typedef OnButton = void Function(String name, String family);

class ChangeNameFamilyViewInjection {
  String? pageTitle;
  String? description;
  String? buttonText;
  TextStyle? textStyle;
  String? name;
  String? family;
  String? nameHint;
  String? familyHint;
  OnButton? onButton;
}
///================================================================================================
class ChangeNameFamilyView extends StatefulWidget {
  final ChangeNameFamilyViewInjection injection;

  ChangeNameFamilyView({
    required this.injection,
    Key? key,
    }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChangeNameFamilyViewState();
  }
}
///==============================================================================================
class ChangeNameFamilyViewState extends State<ChangeNameFamilyView> {
  TextEditingController nameCtr = TextEditingController();
  TextEditingController familyCtr = TextEditingController();
  late InputDecoration inputDecoration;

  @override
  void initState() {
    super.initState();

    inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    nameCtr.text = widget.injection.name?? '';
    familyCtr.text = widget.injection.family?? '';
  }

  @override
  void dispose(){
    nameCtr.dispose();
    familyCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Color itemColor = iconColor?? AppThemes.currentTheme.textColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.injection.pageTitle?? ''),
      ),
      body: ColoredBox(
        color: AppThemes.instance.currentTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 16),

              Visibility(
                visible: widget.injection.description != null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Row(
                    children: [
                      Text('${widget.injection.description}')
                          .color(AppThemes.instance.currentTheme.textColor),
                    ],
                  ),
                ),
              ),

              TextField(
                controller: nameCtr,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration.copyWith(
                  hintText: widget.injection.nameHint?? '',
                ),
              ),

              SizedBox(height: 10),

              TextField(
                controller: familyCtr,
                decoration: inputDecoration.copyWith(
                  hintText: widget.injection.familyHint?? '',
                ),
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: onButtonClick,
                    child: Text('تغییر')
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void onButtonClick(){
    widget.injection.onButton?.call(nameCtr.text, familyCtr.text);
  }
}
