import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';

class E404Page extends StatefulWidget{

  const E404Page({Key? key}) : super(key: key);

  @override
  State<E404Page> createState() => _E404PageState();
}
///============================================================================================
class _E404PageState extends State<E404Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  AppImages.e404Lottie,
                  width: 200,
                  height: 200,
                  reverse: false,
                  animate: true,
                  fit: BoxFit.fill,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.colorFilter(
                        ['Cactus.ai'],
                        //Colors.amber
                        value: ColorFilter.mode(AppThemes.instance.currentTheme.primaryColor.withAlpha(100), BlendMode.srcATop),
                      ),
                      ValueDelegate.color(
                        ['4  4', '**'],
                        value: AppThemes.instance.currentTheme.primaryColor,
                      ),
                      ValueDelegate.transformOpacity(
                        ['4  4'],
                        value: 60,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50,),

                Text(AppMessages.e404, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              ],
            ),
          )
      ),
    );
  }
}
