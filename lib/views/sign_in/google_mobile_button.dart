import 'package:flutter/material.dart';

import 'package:app/views/sign_in/google_stub_button.dart';

Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: const Text('SIGN IN'),
  );
}
