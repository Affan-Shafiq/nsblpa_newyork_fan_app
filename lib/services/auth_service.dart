import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_config.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      print('Creating user with email: $email');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User created successfully: ${userCredential.user?.uid}');

      // Create user profile in Firestore under users/{uid} as the first step
      final createdUser = userCredential.user;
      if (createdUser != null) {
        await _ensureUserDocument(createdUser,
            explicitEmail: email, explicitDisplayName: displayName, explicitPhotoUrl: photoUrl);

        // Try to update display name, but ignore the PigeonUserDetails error
        try {
          await createdUser.updateDisplayName(displayName);
        } catch (e) {
          final message = e.toString();
          if (message.contains('PigeonUserDetails')) {
            print('Ignoring PigeonUserDetails error from updateDisplayName');
          } else {
            rethrow;
          }
        }
      }

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
        // Ensure user document exists even if error happened earlier
        try {
          final current = _auth.currentUser;
          if (current != null) {
            await _ensureUserDocument(current,
                explicitEmail: email, explicitDisplayName: displayName);
          }
        } catch (ensureError) {
          print('Failed ensuring user document after PigeonUserDetails: $ensureError');
        }
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
    } catch (e) {
      print('Error during sign out: $e');
      // Continue with sign out even if Google sign out fails
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process');
      
      // Create Google Auth Provider with additional scopes
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
      googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
      
      // Sign in with the provider (works on mobile and web)
      final userCredential = await _auth.signInWithProvider(googleProvider);
      print('Firebase authentication successful: ${userCredential.user?.uid}');
      
      // Ensure Firestore user document exists with Google account details
      final signedInUser = userCredential.user;
      if (signedInUser != null) {
        print('Firebase user display name: ${signedInUser.displayName}');
        print('Firebase user email: ${signedInUser.email}');
        print('Firebase user photo URL: ${signedInUser.photoURL}');
        
        // Force reload to get the latest user data
        await signedInUser.reload();
        final refreshedUser = _auth.currentUser;
        
        print('After reload - display name: ${refreshedUser?.displayName}');
        print('After reload - email: ${refreshedUser?.email}');
        print('After reload - photo URL: ${refreshedUser?.photoURL}');
        
        // Use the refreshed user data
        final displayName = refreshedUser?.displayName ?? signedInUser.displayName;
        final photoUrl = refreshedUser?.photoURL ?? signedInUser.photoURL;
        
        print('Final display name to use: $displayName');
        print('Final photo URL to use: $photoUrl');
        
        // Explicitly pass the display name from Google account
        await _ensureUserDocument(
          refreshedUser ?? signedInUser,
          explicitDisplayName: displayName,
          explicitPhotoUrl: photoUrl,
        );
      }

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
        try {
          final current = _auth.currentUser;
          if (current != null) {
            // Force reload to get the latest data
            await current.reload();
            final refreshedUser = _auth.currentUser;
            
            print('PigeonUserDetails error - refreshed display name: ${refreshedUser?.displayName}');
            
            // Ensure we still capture the display name even if there's an error
            await _ensureUserDocument(
              refreshedUser ?? current,
              explicitDisplayName: refreshedUser?.displayName ?? current.displayName,
              explicitPhotoUrl: refreshedUser?.photoURL ?? current.photoURL,
            );
          }
        } catch (ensureError) {
          print('Failed ensuring user document after Google PigeonUserDetails: $ensureError');
        }
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

  // Ensure Firestore document exists for a user
  Future<void> _ensureUserDocument(User user, {String? explicitEmail, String? explicitDisplayName, String? explicitPhotoUrl}) async {
    try {
      final uid = user.uid;
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final snapshot = await docRef.get();
      
      print('_ensureUserDocument - UID: $uid');
      print('_ensureUserDocument - User display name: ${user.displayName}');
      print('_ensureUserDocument - Explicit display name: $explicitDisplayName');
      print('_ensureUserDocument - User email: ${user.email}');
      print('_ensureUserDocument - Explicit email: $explicitEmail');
      print('_ensureUserDocument - User photo URL: ${user.photoURL}');
      print('_ensureUserDocument - Explicit photo URL: $explicitPhotoUrl');
      
      if (snapshot.exists) {
        // Merge updates including new fields if they don't exist
        final existingData = snapshot.data() ?? {};
        final finalDisplayName = explicitDisplayName ?? user.displayName;
        final finalEmail = explicitEmail ?? user.email;
        final finalPhotoUrl = explicitPhotoUrl ?? user.photoURL;
        
        print('_ensureUserDocument - Final display name to save: $finalDisplayName');
        print('_ensureUserDocument - Final email to save: $finalEmail');
        print('_ensureUserDocument - Final photo URL to save: $finalPhotoUrl');
        
        await docRef.set({
          'email': finalEmail,
          'displayName': finalDisplayName,
          'photoUrl': finalPhotoUrl,
          'teamId': AppConfig.teamId,
          // Add new fields if they don't exist
          if (!existingData.containsKey('points')) 'points': 0,
          if (!existingData.containsKey('badges')) 'badges': [],
          if (!existingData.containsKey('postsShared')) 'postsShared': 0,
          if (!existingData.containsKey('role')) 'role': 'fan', // Ensure role is set
        }, SetOptions(merge: true));
        return;
      }

      final finalDisplayName = explicitDisplayName ?? user.displayName;
      final finalEmail = explicitEmail ?? user.email;
      final finalPhotoUrl = explicitPhotoUrl ?? user.photoURL;
      
      print('_ensureUserDocument - Creating new user with display name: $finalDisplayName');
      
      final appUser = AppUser(
        email: finalEmail ?? '',
        displayName: finalDisplayName,
        photoUrl: finalPhotoUrl,
        teamId: AppConfig.teamId,
        points: 0,
        badges: [],
        postsShared: 0,
        role: 'fan', // Default role for new users
      );
      await docRef.set(appUser.toJson());
    } catch (e) {
      print('Error ensuring user document: $e');
      rethrow;
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
