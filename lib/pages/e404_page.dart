import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appThemes.dart';

class E404Page extends StatefulWidget {
  static final route = GoRoute(
  path: '/404page',
  name: (E404Page).toString().toLowerCase(),
  builder: (BuildContext context, GoRouterState state) => const E404Page(),
  );

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
