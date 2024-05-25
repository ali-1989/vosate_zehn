import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';

import 'package:app/tools/app/app_images.dart';

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(
                AppImages.loadingLottie,
                width: 300,
                height: 300,
                reverse: false,
                animate: true,
                fit: BoxFit.fill,
              ),

              Text(AppMessages.slogan).bold().fsR(1),

              const SizedBox(height: 15),

              FadeIn(
                duration: const Duration(milliseconds: 700),
                child: Image.asset(AppImages.appIcon,
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
