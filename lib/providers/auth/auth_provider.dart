import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/auth/user_model.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Constructor - initialize and listen to auth state changes
  AuthProvider() {
    _init();
  }

  // Initialize authentication state
  Future<void> _init() async {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      } else {
        await _fetchUserData(firebaseUser);
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(User firebaseUser) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (docSnapshot.exists) {
        _user = UserModel.fromFirestore(docSnapshot);
      } else {
        // Create new user document if it doesn't exist
        final newUser = UserModel.fromFirebaseUser(firebaseUser);
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toFirestore());
        _user = newUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      _user = UserModel.fromFirebaseUser(firebaseUser);
    }
  }

  // Sign up with email and password
  Future<void> signUp(
      String email, String password, String? displayName) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmail(email, password);

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      // User data will be updated via the auth state listener
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      // User data will be updated via the auth state listener
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      // User data will be updated via the auth state listener
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithApple();
      // User data will be updated via the auth state listener
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Phone number authentication - Step 1
  Future<void> verifyPhoneNumber(
      String phoneNumber, Function(String verificationId) onCodeSent) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification or instant verification
          await _authService.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _status = AuthStatus.error;
          _errorMessage = e.message;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          // Pass verification ID to the caller
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout
        },
      );
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Phone number authentication - Step 2
  Future<void> confirmPhoneVerification(
    String verificationId,
    String smsCode,
  ) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.confirmPhoneVerification(verificationId, smsCode);
      // User data will be updated via the auth state listener
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _errorMessage = null;

    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Biometric authentication setup
  Future<bool> canUseBiometrics() async {
    return await _authService.canUseBiometrics();
  }

  // Enable biometric login
  Future<void> enableBiometricLogin(String email, String password) async {
    await _authService.enableBiometricLogin(email, password);
  }

  // Check if biometric login is enabled
  Future<bool> isBiometricLoginEnabled() async {
    return await _authService.isBiometricLoginEnabled();
  }

  // Authenticate with biometrics and login
  Future<void> authenticateWithBiometrics() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final isAuthenticated = await _authService.authenticateWithBiometrics();

      if (isAuthenticated) {
        final email = await _authService.getStoredEmail();
        final password = await _authService.getStoredPassword();

        if (email != null && password != null) {
          await signIn(email, password);
        } else {
          _status = AuthStatus.error;
          _errorMessage =
              'Biometric authentication successful, but credentials not found.';
          notifyListeners();
        }
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Biometric authentication failed.';
        notifyListeners();
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Update user data
  Future<void> updateUserData({
    String? displayName,
    String? photoUrl,
    List<String>? addresses,
    Map<String, dynamic>? preferences,
  }) async {
    if (_user == null) return;

    try {
      final userData = <String, dynamic>{};

      if (displayName != null) userData['displayName'] = displayName;
      if (photoUrl != null) userData['photoUrl'] = photoUrl;
      if (addresses != null) userData['addresses'] = addresses;
      if (preferences != null) userData['preferences'] = preferences;

      await _firestore.collection('users').doc(_user!.id).update(userData);

      // Update local user data
      _user = _user!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        addresses: addresses,
        preferences: preferences,
      );

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user data: $e');
      }
    }
  }

  // Add loyalty points
  Future<void> addLoyaltyPoints(int points) async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.id).update({
        'loyaltyPoints': FieldValue.increment(points),
      });

      // Update local user data
      _user = _user!.copyWith(
        loyaltyPoints: _user!.loyaltyPoints + points,
      );

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding loyalty points: $e');
      }
    }
  }

  // Use loyalty points
  Future<bool> useLoyaltyPoints(int points) async {
    if (_user == null || _user!.loyaltyPoints < points) return false;

    try {
      await _firestore.collection('users').doc(_user!.id).update({
        'loyaltyPoints': FieldValue.increment(-points),
      });

      // Update local user data
      _user = _user!.copyWith(
        loyaltyPoints: _user!.loyaltyPoints - points,
      );

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error using loyalty points: $e');
      }
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.signOut();
      // Auth state listener will handle the rest
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
