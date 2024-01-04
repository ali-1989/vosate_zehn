import 'package:flutter/material.dart';

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;

import 'package:app/views/sign_in/google_stub_button.dart';

Widget buildSignInButton({HandleSignInFn? onPressed}) {
  web.GSIButtonConfiguration conf = web.GSIButtonConfiguration(
    type: web.GSIButtonType.standard,
    locale: 'EN',
    shape: web.GSIButtonShape.rectangular,
    theme: web.GSIButtonTheme.filledBlue,
  );

  return (GoogleSignInPlatform.instance as web.GoogleSignInPlugin)
      .renderButton(configuration: conf);
}
