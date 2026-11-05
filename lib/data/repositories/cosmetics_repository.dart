import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/cosmetics/theme_catalog.dart';

/// The player's chosen brick theme plus device sound settings.
class CosmeticSelection {
  const CosmeticSelection({
    this.theme = ThemeId.neonGlow,
    this.soundEnabled = true,
    this.volume = 0.8,
    this.updatedAt = 0,
  });

  final ThemeId theme;
  final bool soundEnabled;

  /// 0..1.
  final double volume;

  /// Epoch ms of the last equip; resolves conflicts with the account copy.
  final int updatedAt;

  CosmeticSelection copyWith({
    ThemeId? theme,
    bool? soundEnabled,
    double? volume,
    int? updatedAt,
  }) => CosmeticSelection(
    theme: theme ?? this.theme,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    volume: volume ?? this.volume,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// Stores the selection on the device and mirrors the equipped theme to
/// `users/{uid}.cosmetics` so it follows the account. Sound settings stay
/// per device.
class CosmeticsRepository {
  CosmeticsRepository(this._prefs, {FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  static const _themeKey = 'cosmetics.skin';
  static const _updatedKey = 'cosmetics.updatedAt';
  static const _enabledKey = 'sound.enabled';
  static const _volumeKey = 'sound.volume';

  final SharedPreferences _prefs;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CosmeticSelection load() => CosmeticSelection(
    theme:
        ThemeId.fromName(_prefs.getString(_themeKey)) ??
        ThemeCatalog.defaultTheme.id,
    soundEnabled: _prefs.getBool(_enabledKey) ?? true,
    volume: (_prefs.getDouble(_volumeKey) ?? 0.8).clamp(0.0, 1.0),
    updatedAt: _prefs.getInt(_updatedKey) ?? 0,
  );

  /// Equipped theme. The timestamp goes first so an interrupted write can
  /// never pair a new theme with an older timestamp.
  Future<void> save(CosmeticSelection s) async {
    await _prefs.setInt(_updatedKey, s.updatedAt);
    await _prefs.setString(_themeKey, s.theme.name);
  }

  /// Sound on/off and volume only (per device, never synced).
  Future<void> saveSettings(CosmeticSelection s) async {
    await _prefs.setBool(_enabledKey, s.soundEnabled);
    await _prefs.setDouble(_volumeKey, s.volume);
  }

  DocumentReference<Map<String, Object?>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Equipped theme stored on the account, or null if none yet.
  Future<({ThemeId theme, int updatedAt})?> fetchRemote(String uid) async {
    final data = (await _doc(uid).get()).data()?['cosmetics'];
    if (data is! Map) return null;
    final theme = ThemeId.fromName(data['skin'] as String?);
    final updatedAt = (data['updatedAt'] as num?)?.toInt();
    if (theme == null || updatedAt == null) return null;
    return (theme: theme, updatedAt: updatedAt);
  }

  /// Writes the equipped theme (and its bundled sound pack, for readers);
  /// `email` is included because profile rules require it on every write.
  Future<void> pushRemote(String uid, String email, CosmeticSelection s) =>
      _doc(uid).set({
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
        'cosmetics': {
          'skin': s.theme.name,
          'sound': ThemeCatalog.of(s.theme).sound.name,
          'updatedAt': s.updatedAt,
        },
      }, SetOptions(merge: true));
}
