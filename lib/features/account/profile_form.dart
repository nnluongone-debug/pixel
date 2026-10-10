import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../data/models/user_profile.dart';
import '../../providers/account_providers.dart';
import 'account_identity.dart';
import 'account_parts.dart';
import 'profile_avatar.dart';
import 'profile_form_sections.dart';
import 'profile_input.dart';

/// Editable profile. Field state starts from [initial] and is not reset by
/// later stream updates, so a save never overwrites what is being typed.
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key, required this.identity, required this.initial});

  final AccountIdentity identity;
  final UserProfile initial;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  late final _name = TextEditingController(text: widget.initial.name);
  late final _birthYear = TextEditingController(
    text: widget.initial.birthYear?.toString() ?? '',
  );
  late final _address = TextEditingController(text: widget.initial.address);
  late Gender _gender = widget.initial.gender;

  bool _saving = false;
  ProfileInput? _input;

  @override
  void dispose() {
    _name.dispose();
    _birthYear.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final input = ProfileInput.parse(
      name: _name.text,
      birthYearText: _birthYear.text,
      address: _address.text,
      currentYear: DateTime.now().year,
    );
    setState(() => _input = input);
    if (!input.isValid) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final profile = UserProfile(
      email: widget.identity.email,
      name: _name.text,
      birthYear: input.birthYear,
      gender: _gender,
      address: _address.text,
    );
    // Firestore completes the write only on server ack, which never comes
    // offline: report it as saved now and surface a late failure separately.
    setState(() => _saving = true);
    try {
      final write = ref
          .read(profileRepositoryProvider)
          .save(widget.identity.uid, profile);
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountSaved)));
      unawaited(
        write.catchError((Object _) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.accountActionFailed)),
          );
        }),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountActionFailed)));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final input = _input;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ListenableBuilder(
            listenable: _name,
            builder: (_, _) =>
                ProfileAvatar(name: _name.text, email: widget.identity.email),
          ),
        ),
        const SizedBox(height: 24),
        ProfileSection(
          tag: '01',
          title: l10n.accountNameLabel,
          trailing: l10n.accountMaxChars(UserProfile.maxNameLength),
          child: AccountTerminalField(
            controller: _name,
            hint: l10n.accountNameHint,
            maxLength: UserProfile.maxNameLength,
            textInputAction: TextInputAction.next,
            errorText: input?.nameTooLong == true
                ? l10n.accountErrTooLong(UserProfile.maxNameLength)
                : null,
          ),
        ),
        ProfileSection(
          tag: '02',
          title: l10n.accountBirthYearLabel,
          child: BirthYearField(
            controller: _birthYear,
            errorText: input?.birthYearInvalid == true
                ? l10n.accountErrBirthYear(
                    UserProfile.minBirthYear,
                    DateTime.now().year,
                  )
                : null,
          ),
        ),
        ProfileSection(
          tag: '03',
          title: l10n.accountGenderLabel,
          child: GenderChips(
            value: _gender,
            onChanged: (g) => setState(() => _gender = g),
          ),
        ),
        ProfileSection(
          tag: '04',
          title: l10n.accountEmailLabel,
          child: VerifiedEmailField(email: widget.identity.email),
        ),
        ProfileSection(
          tag: '05',
          title: l10n.accountAddressLabel,
          trailing: l10n.accountMaxChars(UserProfile.maxAddressLength),
          child: AccountTerminalField(
            controller: _address,
            hint: l10n.accountAddressHint,
            maxLength: UserProfile.maxAddressLength,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            errorText: input?.addressTooLong == true
                ? l10n.accountErrTooLong(UserProfile.maxAddressLength)
                : null,
          ),
        ),
        AccountButton(label: l10n.accountSave, busy: _saving, onPressed: _save),
      ],
    );
  }
}
