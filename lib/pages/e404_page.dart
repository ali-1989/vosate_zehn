import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';

class E404Page extends StatefulWidget {
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
                        value: ColorFilter.mode(Colors.amber.withAlpha(100), BlendMode.srcATop),
                      ),
                      ValueDelegate.color(
                        ['4  4', '**'],
                        value: Colors.amber,
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
