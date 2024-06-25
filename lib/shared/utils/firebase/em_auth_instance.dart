import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class EMAuthInstance {
  static FirebaseAuth get firebaseInstance => FirebaseAuth.instance;

  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final item = await firebaseInstance.signInWithCredential(credential);

      return AuthResponse(
        status: true,
        userCredential: item,
        message: 'User signed in successfully',
      );
    } on Exception catch (e) {
      return AuthResponse(
        status: false,
        message: e.toString(),
      );
    } catch (e) {
      return AuthResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<bool> signOutFromGoogle() async {
    try {
      await firebaseInstance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static bool checkAuth() {
    bool check = false;

    firebaseInstance.authStateChanges().listen((User? user) {
      if (user == null) {
        check = false;
      } else {
        check = true;
      }
    });

    return check;
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final item = await firebaseInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResponse(
        status: true,
        userCredential: item,
        message: 'User created successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResponse(
        status: false,
        message: e.message,
      );
    } catch (e) {
      return AuthResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final item = await firebaseInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResponse(
        status: true,
        userCredential: item,
        message: 'User signed in successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResponse(
        status: false,
        message: e.message,
      );
    } catch (e) {
      return AuthResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
}

class AuthResponse {
  final bool status;
  final UserCredential? userCredential;
  final String? message;

  AuthResponse({
    required this.status,
    this.userCredential,
    this.message,
  });
}
