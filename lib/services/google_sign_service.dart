import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iris_tools/api/cancelable_future.dart';

class GoogleSignService {
  GoogleSignIn? _signObj;
  GoogleSignInAccount? _signUser;
  UserCredential? _credentialUser;

  static GoogleSignService? _instance;

  GoogleSignService._();

  factory GoogleSignService(){
    _instance ??= GoogleSignService._();

    return _instance!;
  }

  GoogleSignIn get googleSignIn {
    if(_signObj == null){
      if(kIsWeb){
        _signObj = GoogleSignIn();

        /*signObj = GoogleSignIn(
        //client_type:3
        clientId: '579668054514-ojuoo3o4cj1vjbcqfavq6upv9e8h4d1h.apps.googleusercontent.com',
        signInOption: SignInOption.standard,
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );*/
      }
      else {
        //signObj = GoogleSignIn();
        _signObj = GoogleSignIn(
          signInOption: SignInOption.standard,
          scopes: [
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
            //'https://www.googleapis.com/auth/cloud-platform.read-only',
            //'https://www.googleapis.com/auth/contacts.readonly',
            //'https://accounts.google.com/o/oauth2/auth',
          ],
        );
      }
    }

    return _signObj!;
  }

  GoogleSignInAccount? get signedUser => _signUser;
  UserCredential? get credentialUser => _credentialUser;

  /// this usable after sign with Credential
  User? get currentAuthUser => FirebaseAuth.instance.currentUser;

  Future<(GoogleSignInAccount?, Exception?)> signIn() async {
    try {
      final CancelableFuture canF;

      if (kIsWeb) {
        canF = CancelableFuture.timeout(googleSignIn.signIn(), const Duration(seconds: 120));
      }
      else {
        canF = CancelableFuture.timeout(googleSignIn.signIn(), const Duration(seconds: 120));
      }

      _signUser = await canF.future;
      return (_signUser, null);
    }
    catch (e) {
      return (null, e as Exception);
    }
  }

  /// (Need Vpn in Iran), must add localhost:2023 to js domain in auth section GoogleCloud
  /// after this operation, can call some google API without problem.
  Future<(UserCredential? , Exception?)> getCredentialInfo({GoogleSignInAccount? signedUser}) async {
    signedUser ??= this.signedUser;

    if(signedUser == null){
      return (null, Exception('Signed user is null.'));
    }

    final CancelableFuture<GoogleSignInAuthentication> canFuAuth;
    final CancelableFuture<UserCredential> canFuSign;

    try {
      canFuAuth = CancelableFuture.timeout(signedUser.authentication, const Duration(seconds: 120));
      final googleAuth = await canFuAuth.future;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth!.accessToken,
        idToken: googleAuth.idToken, // maybe be null
      );

      canFuSign = CancelableFuture.timeout(FirebaseAuth.instance.signInWithCredential(credential), const Duration(seconds: 120));

      _credentialUser = await canFuSign.future;

      return (_credentialUser, null);
    }
    catch (e) {
      return (null, e as Exception);
    }
  }

  Future<void> signOut() async {
    try {
      //await googleSignIn.signOut();
      final cf = CancelableFuture.timeout(FirebaseAuth.instance.signOut(), const Duration(seconds: 20));
      return cf.future;
    }
    catch (e) {/**/}
  }

  /// no need be Credential
  Future<bool> isSignIn() async {
    try {
      final cf = CancelableFuture<bool>.timeout(googleSignIn.isSignedIn(), const Duration(seconds: 20));
      return cf.future as bool;
    }
    catch (e) {
      return false;
    }
  }

  Future<GoogleSignInAccount?> signInSilently({bool reAuthenticate = false}) async {
    try {
      return await googleSignIn.signInSilently(reAuthenticate: reAuthenticate);
    }
    catch (e) {
      return null;
    }
  }
}
