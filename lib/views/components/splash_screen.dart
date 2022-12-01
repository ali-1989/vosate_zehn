import 'package:animate_do/animate_do.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
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
    );
  }
}
