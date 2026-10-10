import '../../data/models/user_profile.dart';

/// Parsed and validated text of the profile form.
class ProfileInput {
  ProfileInput._({
    required this.birthYear,
    required this.nameTooLong,
    required this.birthYearInvalid,
    required this.addressTooLong,
  });

  /// Validates raw field text; an empty birth year means "not set".
  factory ProfileInput.parse({
    required String name,
    required String birthYearText,
    required String address,
    required int currentYear,
  }) {
    final yearText = birthYearText.trim();
    final year = int.tryParse(yearText);
    return ProfileInput._(
      birthYear: year,
      nameTooLong: name.trim().length > UserProfile.maxNameLength,
      birthYearInvalid:
          yearText.isNotEmpty &&
          (year == null ||
              year < UserProfile.minBirthYear ||
              year > currentYear),
      addressTooLong: address.trim().length > UserProfile.maxAddressLength,
    );
  }

  final int? birthYear;
  final bool nameTooLong;
  final bool birthYearInvalid;
  final bool addressTooLong;

  bool get isValid => !nameTooLong && !birthYearInvalid && !addressTooLong;
}
