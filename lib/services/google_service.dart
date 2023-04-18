import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  late GoogleSignIn signObj;
  GoogleSignInAccount? _googleUser;

  GoogleService(){
    if(kIsWeb){
      signObj = GoogleSignIn(
        clientId: '731359726004-om1nsl47c9l9mjm246h3ebe0rt5lkgdi.apps.googleusercontent.com', //client_type:3
        signInOption: SignInOption.standard,
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
        ],
      );
    }
    else {
      signObj = GoogleSignIn(
        signInOption: SignInOption.standard,
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          //'https://www.googleapis.com/auth/cloud-platform.read-only',
          //'https://www.googleapis.com/auth/contacts.readonly',
          //'https://accounts.google.com/o/oauth2/auth',
        ],
      );
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      if(kIsWeb){
        _googleUser = await signObj.signInSilently().timeout(const Duration(seconds: 20));
        _googleUser ??= await signObj.signIn().timeout(const Duration(minutes: 5));
      }
      else {
        _googleUser = await signObj.signIn().timeout(const Duration(seconds: 60));
      }
    }
    on PlatformException catch (e){
      return null;
    }
    catch (e) {
      print('eeeeeeeeeeeeeeeeeeeeeeeee 2> $e');
    }

    return _googleUser;

    // https://www.technicalfeeder.com/2022/01/flutter-keep-login-state-and-get-authorization-bearer-token/
    /*final googleAuth = await _googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential loginUser = await FirebaseAuth.instance.signInWithCredential(credential);*/
  }

  Future<GoogleSignInAccount?> signOut() async {
    try {
      return await signObj.signOut();
    }
    catch (error) {
      return null;
    }
  }

  Future<bool> isSignIn() async {
    try {
      return await signObj.isSignedIn();
    }
    catch (error) {
      return false;
    }
  }
}
