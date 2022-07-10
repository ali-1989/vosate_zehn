import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Google {
  late GoogleSignIn obj;

  Google(){
    obj = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/userinfo.email',
        //'https://www.googleapis.com/auth/cloud-platform.read-only',
        //'https://www.googleapis.com/auth/contacts.readonly',
        //'https://accounts.google.com/o/oauth2/auth',
      ],
    );
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return (await obj.signIn().timeout(const Duration(seconds: 30)));
    }
    on PlatformException /*catch (e)*/{
      return null;
    }
    catch (e) {
      return null;
    }
  }

  Future<GoogleSignInAccount?> signOut() async {
    try {
      return await obj.signOut();
    }
    catch (error) {
      return null;
    }
  }

  Future<bool> isSignIn() async {
    try {
      return await obj.isSignedIn();
    }
    catch (error) {
      return false;
    }
  }
}