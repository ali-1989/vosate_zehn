import 'package:google_sign_in/google_sign_in.dart';

class Google {
  Google._();

  static Future<GoogleSignInAccount?> handleSignIn() async {
    try {
      final signIn = GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          //'https://www.googleapis.com/auth/cloud-platform.read-only',
          //'https://www.googleapis.com/auth/contacts.readonly',
          //'https://accounts.google.com/o/oauth2/auth',
        ],
      );

      return signIn.signIn();
    }
    catch (error) {
      print(error);
      return null;
    }
  }
}