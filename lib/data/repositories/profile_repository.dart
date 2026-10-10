import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

/// Reads and writes the account profile at `users/{uid}`. Firestore's
/// offline cache lets edits made without network sync later.
class ProfileRepository {
  ProfileRepository({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  /// Resolved lazily so tests can subclass without Firebase.
  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, Object?>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  Stream<UserProfile> watch(String uid, String email) => _doc(
    uid,
  ).snapshots().map((snap) => UserProfile.fromMap(email, snap.data()));

  /// Saves the editable fields. [email] is written too so security rules can
  /// check it matches the signed-in account; it is never user-edited.
  Future<void> save(String uid, UserProfile profile) {
    _validate(profile);
    return _doc(uid).set({
      ...profile.toEditableMap(),
      'email': profile.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static void _validate(UserProfile p) {
    if (p.name.trim().length > UserProfile.maxNameLength) {
      throw ArgumentError.value(p.name, 'name');
    }
    if (p.address.trim().length > UserProfile.maxAddressLength) {
      throw ArgumentError.value(p.address, 'address');
    }
    final year = p.birthYear;
    if (year != null &&
        (year < UserProfile.minBirthYear || year > DateTime.now().year)) {
      throw ArgumentError.value(year, 'birthYear');
    }
  }
}
