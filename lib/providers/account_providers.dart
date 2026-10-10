import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/profile_repository.dart';
import '../services/auth/auth_service.dart';

/// True when `Firebase.initializeApp` succeeded in `main()`. When false the
/// app runs in guest mode only and account features show as unavailable.
final firebaseAvailableProvider = Provider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// The signed-in account, or null in guest mode.
final authUserProvider = StreamProvider<User?>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return Stream.value(null);
  return ref.watch(authServiceProvider).authStateChanges();
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

/// Live profile of the signed-in account; null in guest mode.
final profileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authUserProvider).value;
  final email = user?.email;
  if (user == null || email == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watch(user.uid, email);
});
