import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:lottie/lottie.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.logoSplash),
                fit: BoxFit.fill,
              )
          ),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 200),
              FadeIn(
                duration: const Duration(milliseconds: 700),
                child: Image.asset(AppImages.appIcon,
                  width: 100,
                  height: 100,
                ),
              ),

              const SizedBox(height: 20),
              CustomCard(
                  color: AppDecoration.mainColor,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  child: Text(AppMessages.slogan).color(AppDecoration.sormei)
              ),
              const SizedBox(height: 5),

              Lottie.asset(
                AppImages.loadingLottie,
                width: 300,
                height: 300,
                reverse: false,
                animate: true,
                fit: BoxFit.fill,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
