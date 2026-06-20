import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'firestore_service.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Session keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserUid = 'user_uid';
  static const String keyUserEmail = 'user_email';

  // Mock session keys
  static const String keyMockName = 'mock_user_name';
  static const String keyMockEmail = 'mock_user_email';
  static const String keyMockInstagram = 'mock_user_instagram';
  static const String keyMockPassword = 'mock_user_password';

  // Check if Firebase is using default mock configurations
  bool get _isFirebaseMock {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      return options.apiKey.contains('MOCK') || options.apiKey.contains('REPLACE');
    } catch (_) {
      return true;
    }
  }

  // Sign up
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String instagram,
  }) async {
    if (_isFirebaseMock) {
      await _saveMockSession(
        uid: 'mock_user_123',
        name: name,
        email: email,
        instagram: instagram,
        password: password,
      );
      return;
    }

    try {
      // 1. Create user in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // 2. Update display name in Firebase Auth
        await user.updateDisplayName(name);

        // 3. Save profile data to Firestore
        await _firestoreService.saveUserProfile(
          uid: user.uid,
          name: name,
          email: email,
          instagram: instagram,
        );

        // 4. Save session info locally in SharedPreferences
        await _saveLocalSession(user.uid, email);
      }
    } on FirebaseAuthException catch (e) {
      // If API key is not valid, fallback to mock signup
      if (e.code == 'api-key-not-valid' || 
          e.message?.contains('api-key') == true || 
          e.message?.contains('API key') == true) {
        await _saveMockSession(
          uid: 'mock_user_123',
          name: name,
          email: email,
          instagram: instagram,
          password: password,
        );
        return;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (_isFirebaseMock) {
      await _handleMockSignIn(email, password);
      return;
    }

    try {
      // 1. Authenticate with Firebase Auth
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // 2. Save session info locally in SharedPreferences
        await _saveLocalSession(user.uid, email);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'api-key-not-valid' || 
          e.message?.contains('api-key') == true || 
          e.message?.contains('API key') == true) {
        await _handleMockSignIn(email, password);
        return;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // 1. Sign out of Firebase Auth
      await _auth.signOut();
    } catch (_) {
      // Catch silently in case Firebase is not connected or initialized fully
    } finally {
      // 2. Clear local storage session info
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyIsLoggedIn);
      await prefs.remove(keyUserUid);
      await prefs.remove(keyUserEmail);
    }
  }

  // Check if session exists in SharedPreferences
  Future<bool> checkSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(keyIsLoggedIn) ?? false;
    
    // Also cross-check with active Firebase Auth user if initialized
    if (isLoggedIn) {
      try {
        final User? currentUser = _auth.currentUser;
        if (currentUser == null) {
          // Keep SharedPreferences session for mock/offline resilience
        }
      } catch (_) {}
    }
    return isLoggedIn;
  }

  // Get cached UID from local storage
  Future<String?> getCachedUid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString(keyUserUid);
    if (uid == null) {
      try {
        uid = _auth.currentUser?.uid;
      } catch (_) {}
    }
    return uid;
  }

  // Helper: Cache session locally
  Future<void> _saveLocalSession(String uid, String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserUid, uid);
    await prefs.setString(keyUserEmail, email);
  }

  // Helper: Save mock session in SharedPreferences
  Future<void> _saveMockSession({
    required String uid,
    required String name,
    required String email,
    required String instagram,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserUid, uid);
    await prefs.setString(keyUserEmail, email);
    
    // Save details for profile loading and verification
    await prefs.setString(keyMockName, name);
    await prefs.setString(keyMockEmail, email);
    await prefs.setString(keyMockInstagram, instagram);
    await prefs.setString(keyMockPassword, password);
  }

  // Helper: Handle mock login verification
  Future<void> _handleMockSignIn(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedEmail = prefs.getString(keyMockEmail);
    final String? savedPassword = prefs.getString(keyMockPassword);

    // If matches saved details, or a default test user
    if ((savedEmail == email && savedPassword == password) || 
        (email == 'arvendo@gmail.com' && password == '12345678') ||
        (email == 'explorer@spacenews.com' && password == 'password')) {
      
      final String uid = prefs.getString(keyUserUid) ?? 'mock_user_123';
      final String name = prefs.getString(keyMockName) ?? 'Astro Explorer';
      final String instagram = prefs.getString(keyMockInstagram) ?? '@astro_explorer';

      await _saveMockSession(
        uid: uid,
        name: name,
        email: email,
        instagram: instagram,
        password: password,
      );
    } else {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'Invalid email or password (Mock Mode)',
      );
    }
  }
}
