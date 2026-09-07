import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../models/user_profile_model.dart';

/// Contract for remote authentication and user profile operations.
abstract class AuthRemoteDataSource {
  Future<UserProfileModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserProfileModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserProfileModel?> getCurrentUserProfile();

  Future<UserProfileModel> getUserProfile(String userId);

  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);

  Future<void> logout();
}

/// Implementation using Firebase Auth and Cloud Firestore.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      firestore.collection(AppConstants.usersCollection);

  @override
  Future<UserProfileModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw const AuthException(message: 'Authentication failed. No user found.');
      }

      // Fetch Firestore profile data
      return await getUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      final message = ErrorHandler.mapFirebaseAuthError(e);
      throw AuthException(message: message);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'An unexpected error occurred during login: $e');
    }
  }

  @override
  Future<UserProfileModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw const AuthException(message: 'Registration failed. User could not be created.');
      }

      // Update Firebase Auth display name
      await user.updateDisplayName(name.trim());

      // Create user profile in Firestore
      final newProfile = UserProfileModel(
        id: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
        themeMode: 'system',
      );

      await _usersRef.doc(user.uid).set(newProfile.toFirestoreMap());

      return newProfile;
    } on FirebaseAuthException catch (e) {
      final message = ErrorHandler.mapFirebaseAuthError(e);
      throw AuthException(message: message);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'An unexpected error occurred during registration: $e');
    }
  }

  @override
  Future<UserProfileModel?> getCurrentUserProfile() async {
    final User? currentUser = firebaseAuth.currentUser;
    if (currentUser == null) return null;

    try {
      return await getUserProfile(currentUser.uid);
    } catch (_) {
      // If Firestore profile doesn't exist yet, construct fallback
      return UserProfileModel(
        id: currentUser.uid,
        name: currentUser.displayName ?? 'User',
        email: currentUser.email ?? '',
        createdAt: DateTime.now(),
        themeMode: 'system',
      );
    }
  }

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _usersRef.doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserProfileModel.fromFirestore(docSnapshot);
      } else {
        // Create fallback if profile doc is missing
        final User? currentUser = firebaseAuth.currentUser;
        final fallback = UserProfileModel(
          id: userId,
          name: currentUser?.displayName ?? 'User',
          email: currentUser?.email ?? '',
          createdAt: DateTime.now(),
          themeMode: 'system',
        );
        await _usersRef.doc(userId).set(fallback.toFirestoreMap());
        return fallback;
      }
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore database error: ${e.code}');
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve user profile: $e');
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      await _usersRef.doc(profile.id).set(
            profile.toFirestoreMap(),
            SetOptions(merge: true),
          );

      // Update display name if changed
      if (firebaseAuth.currentUser != null &&
          firebaseAuth.currentUser!.displayName != profile.name) {
        await firebaseAuth.currentUser!.updateDisplayName(profile.name);
      }

      return profile;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore update error: ${e.code}');
    } catch (e) {
      throw ServerException(message: 'Failed to update user profile: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: 'Logout failed: $e');
    }
  }
}
