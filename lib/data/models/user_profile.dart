enum Gender {
  male,
  female,
  other,
  unspecified;

  static Gender fromName(String? name) => Gender.values.firstWhere(
    (g) => g.name == name,
    orElse: () => Gender.unspecified,
  );
}

/// Account profile stored at Firestore `users/{uid}`. [email] comes from the
/// verified sign-in and is never edited by the user.
class UserProfile {
  const UserProfile({
    required this.email,
    this.name = '',
    this.birthYear,
    this.gender = Gender.unspecified,
    this.address = '',
  });

  static const int maxNameLength = 40;
  static const int maxAddressLength = 160;
  static const int minBirthYear = 1900;

  final String email;
  final String name;
  final int? birthYear;
  final Gender gender;
  final String address;

  static const Object _keep = Object();

  UserProfile copyWith({
    String? name,
    Object? birthYear = _keep,
    Gender? gender,
    String? address,
  }) => UserProfile(
    email: email,
    name: name ?? this.name,
    birthYear: identical(birthYear, _keep) ? this.birthYear : birthYear as int?,
    gender: gender ?? this.gender,
    address: address ?? this.address,
  );

  /// Editable fields only; `email` and timestamps are written by the
  /// repository.
  Map<String, Object?> toEditableMap() => {
    'name': name.trim(),
    'birthYear': birthYear,
    'gender': gender.name,
    'address': address.trim(),
  };

  factory UserProfile.fromMap(String email, Map<String, Object?>? map) =>
      UserProfile(
        email: email,
        name: map?['name'] as String? ?? '',
        birthYear: (map?['birthYear'] as num?)?.toInt(),
        gender: Gender.fromName(map?['gender'] as String?),
        address: map?['address'] as String? ?? '',
      );
}
