import 'package:firebase_auth/firebase_auth.dart';
import 'package:iris_tools/api/cancelable_future.dart';

class GithubSignService {
  GithubAuthProvider? _signProvider;
  UserCredential? _credentialUser;

  static GithubSignService? _instance;

  GithubSignService._();

  factory GithubSignService(){
    _instance ??= GithubSignService._();

    return _instance!;
  }

  GithubAuthProvider get signInProvider {
    _signProvider ??= GithubAuthProvider();

    return _signProvider!;
  }

  UserCredential? get credentialUser => _credentialUser;

  User? get currentAuthUser => FirebaseAuth.instance.currentUser;

  Future<(UserCredential?, Exception?)> signIn() async {
    try {
      final cf = CancelableFuture.timeout(FirebaseAuth.instance.signInWithProvider(signInProvider), const Duration(seconds: 120));

      _credentialUser = await cf.future;

      return (_credentialUser, null);
    }
    catch (e) {
      return (null, e as Exception);
    }
  }


  Future<void> signOut() async {
    try {
      return await FirebaseAuth.instance.signOut();
    }
    catch (e) {/**/}
  }
}
