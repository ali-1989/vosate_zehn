import 'package:app/tools/app/appThemes.dart';
import 'package:app/system/extensions.dart';
import 'package:flutter/material.dart';


typedef OnButton = void Function(String name, String family);

class ChangeNameFamilyViewInjection {
  String? title;
  String? buttonText;
  TextStyle? textStyle;
  String? name;
  String? family;
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

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(),
      body: ColoredBox(
        color: AppThemes.instance.currentTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 5),

              Visibility(
                visible: widget.injection.title != null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Text('${widget.injection.title}').color(AppThemes.instance.currentTheme.textColor),
                ),
              ),

              TextField(
                controller: nameCtr,
              ),

              TextField(
                controller: familyCtr,
              ),


              ElevatedButton(
                  onPressed: onButtonClick,
                  child: Text('تغییر')
              )
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
