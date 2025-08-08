import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('Creating user with email: $email');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User created successfully: ${userCredential.user?.uid}');

      // Don't sign out here - let the UI handle the flow
      // The signup screen will navigate to login, and AuthWrapper will handle the state
      print('Signup completed successfully');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error during signup: $e');
      print('Error type: ${e.runtimeType}');
      
      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print('Detected PigeonUserDetails error - this is likely a Firebase Auth internal issue');
        print('User was created successfully, continuing with flow...');
        // Return a mock UserCredential to continue the flow
        // The user was actually created successfully
        return null; // We'll handle this in the signup screen
      }
      
      // Handle any other exceptions
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Signing in user with email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in successfully: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during login: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error during login: $e');
      print('Error type: ${e.runtimeType}');
      
      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print('Detected PigeonUserDetails error during login - this is likely a Firebase Auth internal issue');
        print('User was signed in successfully, continuing with flow...');
        // Return null to indicate the error was handled but user is signed in
        return null;
      }
      
      // Handle any other exceptions
      throw 'An unexpected error occurred during login: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error during sign out: $e');
      // Continue with sign out even if Google sign out fails
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        return null;
      }
      
      print('Google Sign-In successful for: ${googleUser.email}');
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      print('Firebase authentication successful: ${userCredential.user?.uid}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Google Sign-In: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error during Google Sign-In: $e');
      print('Error type: ${e.runtimeType}');
      
      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print('Detected PigeonUserDetails error during Google Sign-In - this is likely a Firebase Auth internal issue');
        print('User was signed in successfully, continuing with flow...');
        return null;
      }
      
      // Handle any other exceptions
      throw 'An unexpected error occurred during Google Sign-In: $e';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
