import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iris_tools/api/cancelable_future.dart';

typedef OnChangeUser = void Function(GoogleSignInAccount? signInAccount);
///==============================================
class GoogleSignService {
  static GoogleSignService? _instance;
  static final List<OnChangeUser> _listeners = [];

  GoogleSignIn? _signObj;
  GoogleSignInAccount? _signUser;
  UserCredential? _credentialUser;
  StreamSubscription? changUserSubscription;

  GoogleSignService._();

  void addListener(OnChangeUser listener){
    if(!_listeners.contains(listener)){
      _listeners.add(listener);
    }

    _listenUserChanged();
  }

  void removeListener(OnChangeUser listener){
    _listeners.remove(listener);

    if(_listeners.isEmpty){
      unListen();
    }
  }

  factory GoogleSignService(){
    _instance ??= GoogleSignService._();

    return _instance!;
  }

  GoogleSignInAccount? get signedUser => _signUser;
  UserCredential? get credentialUser => _credentialUser;

  /// this usable after sign with Credential
  User? get currentAuthUser => FirebaseAuth.instance.currentUser;

  GoogleSignIn get googleSignIn {
    if(_signObj == null){
      final scopes = [
        'https://www.googleapis.com/auth/userinfo.email',
        //'https://www.googleapis.com/auth/userinfo.profile',
        //'https://www.googleapis.com/auth/cloud-platform.read-only',
        //'https://www.googleapis.com/auth/contacts.readonly',
        //'https://accounts.google.com/o/oauth2/auth',
      ];

      if(kIsWeb){
       // _signObj = GoogleSignIn();

        ///Credentials > web > Client IDs - web
        _signObj = GoogleSignIn(
          clientId: '731359726004-e3svv7n4orm66gg1om4errr1kmeg80dj.apps.googleusercontent.com',
          signInOption: SignInOption.standard,
          scopes: scopes,
        );
      }
      else {
        _signObj = GoogleSignIn(
          clientId: '731359726004-e3svv7n4orm66gg1om4errr1kmeg80dj.apps.googleusercontent.com',
          signInOption: SignInOption.standard,
          scopes: scopes,
          //forceCodeForRefreshToken: true,
        );
      }
    }

    return _signObj!;
  }

  void _listenUserChanged(){
    if(_listeners.isEmpty){
      return;
    }

    changUserSubscription = GoogleSignService().googleSignIn.onCurrentUserChanged.listen((event) {
      changUserSubscription?.cancel();

      _signUser = event;

      for(final x in _listeners){
        try{
          x.call(_signUser);
        }
        catch (e){/**/}
      }
    });
  }

  void unListen(){
    changUserSubscription?.cancel();
  }

  Future<(GoogleSignInAccount?, Object?)> signIn() async {
    try {
      final CancelableFuture canF;

      if (kIsWeb) {
        canF = CancelableFuture.timeout(googleSignIn.signIn(), const Duration(seconds: 360));
      }
      else {
        canF = CancelableFuture.timeout(googleSignIn.signIn(), const Duration(seconds: 120));
      }

      _signUser = await canF.future;

      return (_signUser, null);
    }
    catch (e) {
      /**
        # -- some errors:
       * ApiException 7: NETWORK_ERROR, Like VPN
       * ApiException 10: DEVELOPER_ERROR, something's wrong with your app configuration, Like ClientID
      **/
      return (null, e);
    }
  }

  /// (Need Vpn in Iran),
  /// must add localhost:2023 to js domain in auth section GoogleCloud
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
