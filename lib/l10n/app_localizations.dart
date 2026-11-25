import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker - Pixel'**
  String get appTitle;

  /// No description provided for @editorModeTimes.
  ///
  /// In en, this message translates to:
  /// **'SPECIFIC TIMES'**
  String get editorModeTimes;

  /// No description provided for @editorModeRepeat.
  ///
  /// In en, this message translates to:
  /// **'REPEAT'**
  String get editorModeRepeat;

  /// No description provided for @editorEvery.
  ///
  /// In en, this message translates to:
  /// **'EVERY'**
  String get editorEvery;

  /// No description provided for @editorFrom.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get editorFrom;

  /// No description provided for @editorTo.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get editorTo;

  /// No description provided for @editorEveryMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String editorEveryMinutes(int count);

  /// No description provided for @editorRepeatSummary.
  ///
  /// In en, this message translates to:
  /// **'≈ {count} prompts a day ({first} → {last})'**
  String editorRepeatSummary(int count, String first, String last);

  /// No description provided for @editorErrWindow.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get editorErrWindow;

  /// No description provided for @configEveryRow.
  ///
  /// In en, this message translates to:
  /// **'every {interval} · {from}–{to}'**
  String configEveryRow(String interval, String from, String to);

  /// No description provided for @configSummary.
  ///
  /// In en, this message translates to:
  /// **'Scheduled {count} prompts, next at {when}'**
  String configSummary(int count, String when);

  /// No description provided for @configSummaryNone.
  ///
  /// In en, this message translates to:
  /// **'No prompts scheduled'**
  String get configSummaryNone;

  /// No description provided for @editorAddTime.
  ///
  /// In en, this message translates to:
  /// **'+ ADD TIME'**
  String get editorAddTime;

  /// No description provided for @editorRemoveTime.
  ///
  /// In en, this message translates to:
  /// **'Remove {time}'**
  String editorRemoveTime(String time);

  /// No description provided for @lockerTitle.
  ///
  /// In en, this message translates to:
  /// **'BRICK THEMES'**
  String get lockerTitle;

  /// No description provided for @lockerVaultTag.
  ///
  /// In en, this message translates to:
  /// **'VAULT'**
  String get lockerVaultTag;

  /// No description provided for @lockerActiveSkin.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SKIN'**
  String get lockerActiveSkin;

  /// No description provided for @lockerCollection.
  ///
  /// In en, this message translates to:
  /// **'THEME COLLECTION ({count} TIERS)'**
  String lockerCollection(int count);

  /// No description provided for @lockerTierLine.
  ///
  /// In en, this message translates to:
  /// **'TIER {tier} • {rarity}'**
  String lockerTierLine(int tier, String rarity);

  /// No description provided for @lockerRarityCommon.
  ///
  /// In en, this message translates to:
  /// **'COMMON'**
  String get lockerRarityCommon;

  /// No description provided for @lockerRarityRare.
  ///
  /// In en, this message translates to:
  /// **'RARE'**
  String get lockerRarityRare;

  /// No description provided for @lockerRarityEpic.
  ///
  /// In en, this message translates to:
  /// **'EPIC'**
  String get lockerRarityEpic;

  /// No description provided for @lockerRarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY'**
  String get lockerRarityLegendary;

  /// No description provided for @lockerRarityMythic.
  ///
  /// In en, this message translates to:
  /// **'MYTHIC'**
  String get lockerRarityMythic;

  /// No description provided for @lockerRarityCosmic.
  ///
  /// In en, this message translates to:
  /// **'COSMIC'**
  String get lockerRarityCosmic;

  /// No description provided for @lockerUnlockedMark.
  ///
  /// In en, this message translates to:
  /// **'UNLOCKED'**
  String get lockerUnlockedMark;

  /// No description provided for @lockerThemeGameBoy.
  ///
  /// In en, this message translates to:
  /// **'Game Boy DMG-01'**
  String get lockerThemeGameBoy;

  /// No description provided for @lockerThemeNeonGlow.
  ///
  /// In en, this message translates to:
  /// **'Arcade Neon Glow'**
  String get lockerThemeNeonGlow;

  /// No description provided for @lockerThemeCyberpunk.
  ///
  /// In en, this message translates to:
  /// **'Cyber Glitch & CRT'**
  String get lockerThemeCyberpunk;

  /// No description provided for @lockerThemeGemstone.
  ///
  /// In en, this message translates to:
  /// **'Pixel Gemstones'**
  String get lockerThemeGemstone;

  /// No description provided for @lockerThemePureGold.
  ///
  /// In en, this message translates to:
  /// **'Gold Relic & Obsidian'**
  String get lockerThemePureGold;

  /// No description provided for @lockerThemeNebula.
  ///
  /// In en, this message translates to:
  /// **'Starlight Nebula'**
  String get lockerThemeNebula;

  /// No description provided for @lockerEquip.
  ///
  /// In en, this message translates to:
  /// **'EQUIP'**
  String get lockerEquip;

  /// No description provided for @lockerActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get lockerActive;

  /// No description provided for @lockerStreakProgress.
  ///
  /// In en, this message translates to:
  /// **'{current}/{goal} D'**
  String lockerStreakProgress(int current, int goal);

  /// No description provided for @lockerLevelChip.
  ///
  /// In en, this message translates to:
  /// **'LVL {level}'**
  String lockerLevelChip(int level);

  /// No description provided for @lockerPro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get lockerPro;

  /// No description provided for @lockerReqStreak.
  ///
  /// In en, this message translates to:
  /// **'Requires {days}-Day Streak'**
  String lockerReqStreak(int days);

  /// No description provided for @lockerReqLevel.
  ///
  /// In en, this message translates to:
  /// **'Requires Hero LVL {level}'**
  String lockerReqLevel(int level);

  /// No description provided for @lockerReqLevelOrStreak.
  ///
  /// In en, this message translates to:
  /// **'Requires Hero LVL {level} or {days}-Day Streak'**
  String lockerReqLevelOrStreak(int level, int days);

  /// No description provided for @lockerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get lockerComingSoon;

  /// No description provided for @lockerEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{unlocked}/{total} UNLOCKED · SKINS & SOUND PACKS'**
  String lockerEntrySubtitle(int unlocked, int total);

  /// No description provided for @lockerNewTheme.
  ///
  /// In en, this message translates to:
  /// **'NEW THEME!'**
  String get lockerNewTheme;

  /// No description provided for @lockerEquipNow.
  ///
  /// In en, this message translates to:
  /// **'EQUIP NOW'**
  String get lockerEquipNow;

  /// No description provided for @lockerLater.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get lockerLater;

  /// No description provided for @soundCardTitle.
  ///
  /// In en, this message translates to:
  /// **'SOUND / ÂM THANH'**
  String get soundCardTitle;

  /// No description provided for @soundEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEnabled;

  /// No description provided for @soundVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get soundVolume;

  /// No description provided for @soundPackLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound pack: {name}'**
  String soundPackLabel(String name);

  /// No description provided for @soundPreview.
  ///
  /// In en, this message translates to:
  /// **'▶ PREVIEW'**
  String get soundPreview;

  /// No description provided for @soundPackChiptune.
  ///
  /// In en, this message translates to:
  /// **'4-Bit Chiptune Bleep'**
  String get soundPackChiptune;

  /// No description provided for @soundPackSynthPop.
  ///
  /// In en, this message translates to:
  /// **'8-Bit Synth Pop & Coin SFX'**
  String get soundPackSynthPop;

  /// No description provided for @soundPackLaserDrop.
  ///
  /// In en, this message translates to:
  /// **'Laser Drop SFX'**
  String get soundPackLaserDrop;

  /// No description provided for @soundPackCrystalChime.
  ///
  /// In en, this message translates to:
  /// **'Crystal Bell Chime'**
  String get soundPackCrystalChime;

  /// No description provided for @soundPackCoinCascade.
  ///
  /// In en, this message translates to:
  /// **'Coin Cascade SFX'**
  String get soundPackCoinCascade;

  /// No description provided for @soundPackCosmicWarp.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Warp Ambient'**
  String get soundPackCosmicWarp;

  /// No description provided for @configDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'DEMO // LOVE MATRIX'**
  String get configDemoTitle;

  /// No description provided for @configDemoBody.
  ///
  /// In en, this message translates to:
  /// **'Fills the matrix with 10 days of sample habits whose bricks spell LOVE — handy for screenshots and presentations.'**
  String get configDemoBody;

  /// No description provided for @configDemoButton.
  ///
  /// In en, this message translates to:
  /// **'BUILD LOVE MATRIX'**
  String get configDemoButton;

  /// No description provided for @configDemoConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'REPLACE DATA WITH DEMO?'**
  String get configDemoConfirmTitle;

  /// No description provided for @configDemoConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All habits, bricks and XP on this device are replaced by 12 sample habits. This can\'t be undone.'**
  String get configDemoConfirmBody;

  /// No description provided for @configDemoConfirm.
  ///
  /// In en, this message translates to:
  /// **'REPLACE'**
  String get configDemoConfirm;

  /// No description provided for @configDemoSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign out to use the demo, so it isn\'t synced to your account.'**
  String get configDemoSignedIn;

  /// No description provided for @configDemoDone.
  ///
  /// In en, this message translates to:
  /// **'Done! Open the Matrix tab to watch LOVE build.'**
  String get configDemoDone;

  /// No description provided for @configDemoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not build the demo: {error}'**
  String configDemoFailed(String error);

  /// No description provided for @accountErrUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The sign-in service isn\'t available right now. Please try again later.'**
  String get accountErrUnavailable;

  /// No description provided for @accountLoginTag.
  ///
  /// In en, this message translates to:
  /// **'AUTH_INIT.EXE'**
  String get accountLoginTag;

  /// No description provided for @accountLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get accountLoginTitle;

  /// No description provided for @accountProfileTag.
  ///
  /// In en, this message translates to:
  /// **'PLAYER_PROFILE.SYS'**
  String get accountProfileTag;

  /// No description provided for @accountProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get accountProfileTitle;

  /// No description provided for @accountEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get accountEmailLabel;

  /// No description provided for @accountSendCode.
  ///
  /// In en, this message translates to:
  /// **'SEND CODE'**
  String get accountSendCode;

  /// No description provided for @accountGuestLinkNote.
  ///
  /// In en, this message translates to:
  /// **'Habits you track as a guest stay on this device. They are linked to your account the first time you sign in, so nothing is lost.'**
  String get accountGuestLinkNote;

  /// No description provided for @accountCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. It can take a minute to arrive.'**
  String accountCodeSent(String email);

  /// No description provided for @accountCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'VERIFICATION CODE'**
  String get accountCodeLabel;

  /// No description provided for @accountPaste.
  ///
  /// In en, this message translates to:
  /// **'PASTE'**
  String get accountPaste;

  /// No description provided for @accountVerify.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get accountVerify;

  /// No description provided for @accountResendIn.
  ///
  /// In en, this message translates to:
  /// **'RESEND IN {seconds}S'**
  String accountResendIn(int seconds);

  /// No description provided for @accountResend.
  ///
  /// In en, this message translates to:
  /// **'RESEND CODE'**
  String get accountResend;

  /// No description provided for @accountChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'CHANGE EMAIL'**
  String get accountChangeEmail;

  /// No description provided for @accountErrInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get accountErrInvalidEmail;

  /// No description provided for @accountErrTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait before asking for another code.'**
  String get accountErrTooManyRequests;

  /// No description provided for @accountErrInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong code. Check it and try again.'**
  String get accountErrInvalidCode;

  /// No description provided for @accountErrInvalidCodeLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Wrong code. 1 attempt left.} other{Wrong code. {count} attempts left.}}'**
  String accountErrInvalidCodeLeft(int count);

  /// No description provided for @accountErrExpiredCode.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Request a new one.'**
  String get accountErrExpiredCode;

  /// No description provided for @accountErrTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong attempts. Request a new code.'**
  String get accountErrTooManyAttempts;

  /// No description provided for @accountErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get accountErrNetwork;

  /// No description provided for @accountErrUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get accountErrUnknown;

  /// No description provided for @accountUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'CLOUD UNAVAILABLE'**
  String get accountUnavailableTitle;

  /// No description provided for @accountUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Cloud accounts could not start on this device. Your habits still work and stay saved locally. Restart the app to try again.'**
  String get accountUnavailableBody;

  /// No description provided for @accountActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get accountActionFailed;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY NAME'**
  String get accountNameLabel;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get accountNameHint;

  /// No description provided for @accountBirthYearLabel.
  ///
  /// In en, this message translates to:
  /// **'BIRTH YEAR'**
  String get accountBirthYearLabel;

  /// No description provided for @accountBirthYearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1995'**
  String get accountBirthYearHint;

  /// No description provided for @accountGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'GENDER'**
  String get accountGenderLabel;

  /// No description provided for @accountGenderMale.
  ///
  /// In en, this message translates to:
  /// **'MALE'**
  String get accountGenderMale;

  /// No description provided for @accountGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'FEMALE'**
  String get accountGenderFemale;

  /// No description provided for @accountGenderOther.
  ///
  /// In en, this message translates to:
  /// **'OTHER'**
  String get accountGenderOther;

  /// No description provided for @accountGenderUnspecified.
  ///
  /// In en, this message translates to:
  /// **'NOT SAID'**
  String get accountGenderUnspecified;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get accountVerified;

  /// No description provided for @accountAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS'**
  String get accountAddressLabel;

  /// No description provided for @accountAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, city, country'**
  String get accountAddressHint;

  /// No description provided for @accountMaxChars.
  ///
  /// In en, this message translates to:
  /// **'MAX {count} CHR'**
  String accountMaxChars(int count);

  /// No description provided for @accountErrTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long (max {max} characters).'**
  String accountErrTooLong(int max);

  /// No description provided for @accountErrBirthYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a year between {min} and {max}.'**
  String accountErrBirthYear(int min, int max);

  /// No description provided for @accountSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE PROFILE'**
  String get accountSave;

  /// No description provided for @accountSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. It will sync when you are online.'**
  String get accountSaved;

  /// No description provided for @accountBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'PIXEL BADGES'**
  String get accountBadgesTitle;

  /// No description provided for @accountBadgesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No badges unlocked yet. Keep completing habits to earn your first one.'**
  String get accountBadgesEmpty;

  /// No description provided for @accountBadgeUnlockedOn.
  ///
  /// In en, this message translates to:
  /// **'UNLOCKED {date}'**
  String accountBadgeUnlockedOn(String date);

  /// No description provided for @accountSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'CLOUD SYNC'**
  String get accountSyncTitle;

  /// No description provided for @accountSyncIdle.
  ///
  /// In en, this message translates to:
  /// **'SYNCED'**
  String get accountSyncIdle;

  /// No description provided for @accountSyncSyncing.
  ///
  /// In en, this message translates to:
  /// **'SYNCING...'**
  String get accountSyncSyncing;

  /// No description provided for @accountSyncOffline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get accountSyncOffline;

  /// No description provided for @accountSyncError.
  ///
  /// In en, this message translates to:
  /// **'SYNC ERROR'**
  String get accountSyncError;

  /// No description provided for @accountSyncDisabled.
  ///
  /// In en, this message translates to:
  /// **'SYNC OFF'**
  String get accountSyncDisabled;

  /// No description provided for @accountSyncLast.
  ///
  /// In en, this message translates to:
  /// **'LAST SYNC {time}'**
  String accountSyncLast(String time);

  /// No description provided for @accountSyncNever.
  ///
  /// In en, this message translates to:
  /// **'NOT SYNCED YET'**
  String get accountSyncNever;

  /// No description provided for @accountSyncPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 CHANGE PENDING} other{{count} CHANGES PENDING}}'**
  String accountSyncPending(int count);

  /// No description provided for @accountSyncNow.
  ///
  /// In en, this message translates to:
  /// **'SYNC NOW'**
  String get accountSyncNow;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT'**
  String get accountSignOut;

  /// No description provided for @accountSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT?'**
  String get accountSignOutTitle;

  /// No description provided for @accountSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'When online, your data is uploaded to your account first, then removed from this device. Sign in again to restore it.'**
  String get accountSignOutBody;

  /// No description provided for @accountSignOutPendingBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change hasn\'t been uploaded (offline?). Sign out anyway and lose it?} other{{count} changes haven\'t been uploaded (offline?). Sign out anyway and lose them?}}'**
  String accountSignOutPendingBody(int count);

  /// No description provided for @accountKeepSignedIn.
  ///
  /// In en, this message translates to:
  /// **'STAY SIGNED IN'**
  String get accountKeepSignedIn;

  /// No description provided for @accountSignOutAnyway.
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT ANYWAY'**
  String get accountSignOutAnyway;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get accountDelete;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your account, profile, habits, bricks and XP are permanently deleted from the cloud and this device. This cannot be undone.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE FOREVER'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeleteOffline.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to delete your account.'**
  String get accountDeleteOffline;

  /// No description provided for @accountCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get accountCancel;

  /// No description provided for @statsTierCommon.
  ///
  /// In en, this message translates to:
  /// **'COMMON'**
  String get statsTierCommon;

  /// No description provided for @statsTierRare.
  ///
  /// In en, this message translates to:
  /// **'RARE'**
  String get statsTierRare;

  /// No description provided for @statsTierEpic.
  ///
  /// In en, this message translates to:
  /// **'EPIC'**
  String get statsTierEpic;

  /// No description provided for @statsTierLegendary.
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY'**
  String get statsTierLegendary;

  /// No description provided for @statsBadgeNewTitle.
  ///
  /// In en, this message translates to:
  /// **'NEW BADGE!'**
  String get statsBadgeNewTitle;

  /// No description provided for @statsBadgeNewDismiss.
  ///
  /// In en, this message translates to:
  /// **'AWESOME'**
  String get statsBadgeNewDismiss;

  /// No description provided for @statsMonthYear.
  ///
  /// In en, this message translates to:
  /// **'{monthName} {year}'**
  String statsMonthYear(String monthName, int month, int year);

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'HABIT ANALYTICS'**
  String get statsTitle;

  /// No description provided for @statsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load analytics'**
  String get statsLoadError;

  /// No description provided for @statsRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statsRangeWeek;

  /// No description provided for @statsRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsRangeMonth;

  /// No description provided for @statsRangeYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get statsRangeYear;

  /// No description provided for @statsRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get statsRangeAll;

  /// No description provided for @statsCaptionWeek.
  ///
  /// In en, this message translates to:
  /// **'LAST 7 DAYS'**
  String get statsCaptionWeek;

  /// No description provided for @statsCaptionMonth.
  ///
  /// In en, this message translates to:
  /// **'LAST 30 DAYS'**
  String get statsCaptionMonth;

  /// No description provided for @statsCaptionYear.
  ///
  /// In en, this message translates to:
  /// **'LAST 365 DAYS'**
  String get statsCaptionYear;

  /// No description provided for @statsCaptionAll.
  ///
  /// In en, this message translates to:
  /// **'ALL TIME'**
  String get statsCaptionAll;

  /// No description provided for @statsWindowWeek.
  ///
  /// In en, this message translates to:
  /// **'7D WINDOW'**
  String get statsWindowWeek;

  /// No description provided for @statsWindowMonth.
  ///
  /// In en, this message translates to:
  /// **'30D WINDOW'**
  String get statsWindowMonth;

  /// No description provided for @statsWindowYear.
  ///
  /// In en, this message translates to:
  /// **'365D WINDOW'**
  String get statsWindowYear;

  /// No description provided for @statsWindowAll.
  ///
  /// In en, this message translates to:
  /// **'ALL TIME'**
  String get statsWindowAll;

  /// No description provided for @statsSyncLine.
  ///
  /// In en, this message translates to:
  /// **'SYNCED: TODAY {time}'**
  String statsSyncLine(String time);

  /// No description provided for @statsTileCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'CURR STREAK'**
  String get statsTileCurrentStreak;

  /// No description provided for @statsTileBestStreak.
  ///
  /// In en, this message translates to:
  /// **'BEST STREAK'**
  String get statsTileBestStreak;

  /// No description provided for @statsTileRate.
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get statsTileRate;

  /// No description provided for @statsTileBlocks.
  ///
  /// In en, this message translates to:
  /// **'BLOCKS'**
  String get statsTileBlocks;

  /// No description provided for @statsUnitDays.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get statsUnitDays;

  /// No description provided for @statsUnitStack.
  ///
  /// In en, this message translates to:
  /// **'STACK'**
  String get statsUnitStack;

  /// No description provided for @statsCaptionStreakAlive.
  ///
  /// In en, this message translates to:
  /// **'Any block keeps it alive'**
  String get statsCaptionStreakAlive;

  /// No description provided for @statsCaptionRecord.
  ///
  /// In en, this message translates to:
  /// **'ALL-TIME RECORD'**
  String get statsCaptionRecord;

  /// No description provided for @statsCaptionHabitDays.
  ///
  /// In en, this message translates to:
  /// **'{done} / {due} habit-days'**
  String statsCaptionHabitDays(int done, int due);

  /// No description provided for @statsCaptionNothingDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing due · {range}'**
  String statsCaptionNothingDue(String range);

  /// No description provided for @statsCaptionPerfectClears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 perfect clear} other{{count} perfect clears}}'**
  String statsCaptionPerfectClears(int count);

  /// No description provided for @statsDeltaPoints.
  ///
  /// In en, this message translates to:
  /// **'{value} PTS'**
  String statsDeltaPoints(String value);

  /// No description provided for @statsHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY MATRIX // {month}'**
  String statsHeatmapTitle(String month);

  /// No description provided for @statsHeatmapEfficiency.
  ///
  /// In en, this message translates to:
  /// **'{percent}% EFFICIENCY'**
  String statsHeatmapEfficiency(int percent);

  /// No description provided for @statsLegendLess.
  ///
  /// In en, this message translates to:
  /// **'LESS'**
  String get statsLegendLess;

  /// No description provided for @statsLegendMore.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get statsLegendMore;

  /// No description provided for @statsPerfectClear.
  ///
  /// In en, this message translates to:
  /// **'PERFECT CLEAR: {days}D'**
  String statsPerfectClear(int days);

  /// No description provided for @statsPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get statsPrevMonth;

  /// No description provided for @statsNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get statsNextMonth;

  /// No description provided for @statsCellNoneDue.
  ///
  /// In en, this message translates to:
  /// **'{date}, none due'**
  String statsCellNoneDue(String date);

  /// No description provided for @statsCellDone.
  ///
  /// In en, this message translates to:
  /// **'{date}, {done} of {due} done'**
  String statsCellDone(String date, int done, int due);

  /// No description provided for @statsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'HABIT CONSISTENCY BREAKDOWN'**
  String get statsBreakdownTitle;

  /// No description provided for @statsBreakdownEmpty.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Create one with the + button.'**
  String get statsBreakdownEmpty;

  /// No description provided for @statsDaysTargetMet.
  ///
  /// In en, this message translates to:
  /// **'{met} / {due} Days Target Met'**
  String statsDaysTargetMet(int met, int due);

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak: {days}D'**
  String statsStreak(int days);

  /// No description provided for @statsStatDone.
  ///
  /// In en, this message translates to:
  /// **'{count} DONE'**
  String statsStatDone(int count);

  /// No description provided for @statsStatLogged.
  ///
  /// In en, this message translates to:
  /// **'≥ {duration} LOGGED'**
  String statsStatLogged(String duration);

  /// No description provided for @statsDurationHM.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String statsDurationHM(int hours, int minutes);

  /// No description provided for @statsDurationM.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String statsDurationM(int minutes);

  /// No description provided for @statsBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'PIXEL BADGES ({unlocked}/{total})'**
  String statsBadgesTitle(int unlocked, int total);

  /// No description provided for @statsViewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get statsViewAll;

  /// No description provided for @statsBadgesNoXp.
  ///
  /// In en, this message translates to:
  /// **'Badges are trophies only and award no XP.'**
  String get statsBadgesNoXp;

  /// No description provided for @statsBadgeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'UNLOCKED'**
  String get statsBadgeUnlocked;

  /// No description provided for @statsBadgeLocked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get statsBadgeLocked;

  /// No description provided for @statsBadgeSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {state}. {description}'**
  String statsBadgeSemantics(String title, String state, String description);

  /// No description provided for @statsBadgeFirstBlockName.
  ///
  /// In en, this message translates to:
  /// **'First Block'**
  String get statsBadgeFirstBlockName;

  /// No description provided for @statsBadgeFirstBlockDesc.
  ///
  /// In en, this message translates to:
  /// **'Place your first block'**
  String get statsBadgeFirstBlockDesc;

  /// No description provided for @statsBadgeBrickLayerName.
  ///
  /// In en, this message translates to:
  /// **'Brick Layer'**
  String get statsBadgeBrickLayerName;

  /// No description provided for @statsBadgeBrickLayerDesc.
  ///
  /// In en, this message translates to:
  /// **'Place 25 blocks'**
  String get statsBadgeBrickLayerDesc;

  /// No description provided for @statsBadgeBrickMasterName.
  ///
  /// In en, this message translates to:
  /// **'Brick Master'**
  String get statsBadgeBrickMasterName;

  /// No description provided for @statsBadgeBrickMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Place 100 blocks'**
  String get statsBadgeBrickMasterDesc;

  /// No description provided for @statsBadgeWarriorName.
  ///
  /// In en, this message translates to:
  /// **'7-Day Warrior'**
  String get statsBadgeWarriorName;

  /// No description provided for @statsBadgeWarriorDesc.
  ///
  /// In en, this message translates to:
  /// **'Place a block 7 days in a row'**
  String get statsBadgeWarriorDesc;

  /// No description provided for @statsBadgeLineClearerName.
  ///
  /// In en, this message translates to:
  /// **'Line Clearer'**
  String get statsBadgeLineClearerName;

  /// No description provided for @statsBadgeLineClearerDesc.
  ///
  /// In en, this message translates to:
  /// **'Place a block 10 days in a row'**
  String get statsBadgeLineClearerDesc;

  /// No description provided for @statsBadgeLegendName.
  ///
  /// In en, this message translates to:
  /// **'30-Day Legend'**
  String get statsBadgeLegendName;

  /// No description provided for @statsBadgeLegendDesc.
  ///
  /// In en, this message translates to:
  /// **'Place a block 30 days in a row'**
  String get statsBadgeLegendDesc;

  /// No description provided for @statsBadgePerfectDayName.
  ///
  /// In en, this message translates to:
  /// **'Perfect Day'**
  String get statsBadgePerfectDayName;

  /// No description provided for @statsBadgePerfectDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete every habit due in one day'**
  String get statsBadgePerfectDayDesc;

  /// No description provided for @statsBadgePerfectWeekName.
  ///
  /// In en, this message translates to:
  /// **'Perfect Week'**
  String get statsBadgePerfectWeekName;

  /// No description provided for @statsBadgePerfectWeekDesc.
  ///
  /// In en, this message translates to:
  /// **'Perfect days 7 times in a row'**
  String get statsBadgePerfectWeekDesc;

  /// No description provided for @statsBadgeLevel5Name.
  ///
  /// In en, this message translates to:
  /// **'Level 5'**
  String get statsBadgeLevel5Name;

  /// No description provided for @statsBadgeLevel5Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 5'**
  String get statsBadgeLevel5Desc;

  /// No description provided for @statsBadgeLevel10Name.
  ///
  /// In en, this message translates to:
  /// **'Level 10'**
  String get statsBadgeLevel10Name;

  /// No description provided for @statsBadgeLevel10Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach level 10'**
  String get statsBadgeLevel10Desc;

  /// No description provided for @statsProgressBlocks.
  ///
  /// In en, this message translates to:
  /// **'BLOCKS {current} / {goal}'**
  String statsProgressBlocks(int current, int goal);

  /// No description provided for @statsProgressStreak.
  ///
  /// In en, this message translates to:
  /// **'BEST {current} / {goal} DAYS'**
  String statsProgressStreak(int current, int goal);

  /// No description provided for @statsProgressPerfectRun.
  ///
  /// In en, this message translates to:
  /// **'BEST {current} / {goal} PERFECT DAYS'**
  String statsProgressPerfectRun(int current, int goal);

  /// No description provided for @statsProgressBestDay.
  ///
  /// In en, this message translates to:
  /// **'BEST DAY {done} / {due} HABITS'**
  String statsProgressBestDay(int done, int due);

  /// No description provided for @statsProgressNoHabits.
  ///
  /// In en, this message translates to:
  /// **'NO HABITS DUE YET'**
  String get statsProgressNoHabits;

  /// No description provided for @statsProgressLevel.
  ///
  /// In en, this message translates to:
  /// **'LEVEL {current} / {goal}'**
  String statsProgressLevel(int current, int goal);

  /// No description provided for @editorNewHabit.
  ///
  /// In en, this message translates to:
  /// **'NEW HABIT'**
  String get editorNewHabit;

  /// No description provided for @editorEditHabit.
  ///
  /// In en, this message translates to:
  /// **'EDIT HABIT'**
  String get editorEditHabit;

  /// No description provided for @editorClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get editorClose;

  /// No description provided for @editorIdentityTag.
  ///
  /// In en, this message translates to:
  /// **'01 // IDENTITY'**
  String get editorIdentityTag;

  /// No description provided for @editorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'HABIT TITLE'**
  String get editorTitleLabel;

  /// No description provided for @editorMaxChars.
  ///
  /// In en, this message translates to:
  /// **'MAX {count} CHR'**
  String editorMaxChars(int count);

  /// No description provided for @editorTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Read 20 Pages'**
  String get editorTitleHint;

  /// No description provided for @editorTemplatesLabel.
  ///
  /// In en, this message translates to:
  /// **'TEMPLATES · TAP TO FILL'**
  String get editorTemplatesLabel;

  /// No description provided for @tasksSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left on a habit to delete it'**
  String get tasksSwipeHint;

  /// No description provided for @editorIconsMore.
  ///
  /// In en, this message translates to:
  /// **'More icons'**
  String get editorIconsMore;

  /// No description provided for @editorIconsLess.
  ///
  /// In en, this message translates to:
  /// **'Fewer icons'**
  String get editorIconsLess;

  /// No description provided for @detailNotFound.
  ///
  /// In en, this message translates to:
  /// **'This habit no longer exists.'**
  String get detailNotFound;

  /// No description provided for @detailRecentDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'LAST 7 DAYS'**
  String get detailRecentDaysTitle;

  /// No description provided for @detailRecentDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day you forgot to log'**
  String get detailRecentDaysHint;

  /// No description provided for @detailUnmarkBonusTitle.
  ///
  /// In en, this message translates to:
  /// **'REMOVE THIS DAY?'**
  String get detailUnmarkBonusTitle;

  /// No description provided for @detailUnmarkBonusBody.
  ///
  /// In en, this message translates to:
  /// **'This day was checked in on time and earned bonus XP. If you remove it, that bonus is lost for good, even if you mark the day again.'**
  String get detailUnmarkBonusBody;

  /// No description provided for @detailUnmarkBonusConfirm.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get detailUnmarkBonusConfirm;

  /// No description provided for @detailBackfillFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update that day. Try again.'**
  String get detailBackfillFailed;

  /// No description provided for @editorClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear title'**
  String get editorClearTitle;

  /// No description provided for @editorIconMatrix.
  ///
  /// In en, this message translates to:
  /// **'SELECT ICON MATRIX'**
  String get editorIconMatrix;

  /// No description provided for @editorMetaphorTag.
  ///
  /// In en, this message translates to:
  /// **'02 // METAPHOR'**
  String get editorMetaphorTag;

  /// No description provided for @editorColorTitle.
  ///
  /// In en, this message translates to:
  /// **'PIXEL BLOCK COLOR'**
  String get editorColorTitle;

  /// No description provided for @editorColorHint.
  ///
  /// In en, this message translates to:
  /// **'Sets the color of this habit\'s blocks on the live matrix.'**
  String get editorColorHint;

  /// No description provided for @editorColorSemantics.
  ///
  /// In en, this message translates to:
  /// **'Color {hex}'**
  String editorColorSemantics(String hex);

  /// No description provided for @editorCadenceTag.
  ///
  /// In en, this message translates to:
  /// **'03 // CADENCE'**
  String get editorCadenceTag;

  /// No description provided for @editorCadenceTitle.
  ///
  /// In en, this message translates to:
  /// **'CADENCE & GOAL'**
  String get editorCadenceTitle;

  /// No description provided for @editorLoop.
  ///
  /// In en, this message translates to:
  /// **'LOOP_{cadence}'**
  String editorLoop(String cadence);

  /// No description provided for @editorDailyQuota.
  ///
  /// In en, this message translates to:
  /// **'DAILY QUOTA'**
  String get editorDailyQuota;

  /// No description provided for @editorQuotaDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease quota'**
  String get editorQuotaDecrease;

  /// No description provided for @editorQuotaIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase quota'**
  String get editorQuotaIncrease;

  /// No description provided for @editorChipPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get editorChipPages;

  /// No description provided for @editorChipMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get editorChipMinutes;

  /// No description provided for @editorChipTimes.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get editorChipTimes;

  /// No description provided for @editorChipGlasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get editorChipGlasses;

  /// No description provided for @editorChipCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get editorChipCheck;

  /// No description provided for @editorAlertsTag.
  ///
  /// In en, this message translates to:
  /// **'04 // ALERTS'**
  String get editorAlertsTag;

  /// No description provided for @editorNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get editorNotifications;

  /// No description provided for @editorDailyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Daily Prompt'**
  String get editorDailyPrompt;

  /// No description provided for @editorPromptOn.
  ///
  /// In en, this message translates to:
  /// **'Reminds you on every day this habit is due'**
  String get editorPromptOn;

  /// No description provided for @editorNoReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get editorNoReminder;

  /// No description provided for @editorErrTitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a habit title'**
  String get editorErrTitleEmpty;

  /// No description provided for @editorErrTitleLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be 1-{max} characters'**
  String editorErrTitleLength(int max);

  /// No description provided for @editorErrNoDays.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get editorErrNoDays;

  /// No description provided for @editorErrQuota.
  ///
  /// In en, this message translates to:
  /// **'Quota must be at least 1'**
  String get editorErrQuota;

  /// No description provided for @editorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save habit: {error}'**
  String editorSaveFailed(String error);

  /// No description provided for @editorCreate.
  ///
  /// In en, this message translates to:
  /// **'CREATE HABIT'**
  String get editorCreate;

  /// No description provided for @editorSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get editorSaveChanges;

  /// No description provided for @editorCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Drops into the live matrix when you hit today\'s quota'**
  String get editorCreateHint;

  /// No description provided for @editorEditHint.
  ///
  /// In en, this message translates to:
  /// **'Changes apply immediately'**
  String get editorEditHint;

  /// No description provided for @configTitle.
  ///
  /// In en, this message translates to:
  /// **'CONFIG'**
  String get configTitle;

  /// No description provided for @configNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get configNotifications;

  /// No description provided for @configChecking.
  ///
  /// In en, this message translates to:
  /// **'CHECKING...'**
  String get configChecking;

  /// No description provided for @configAllow.
  ///
  /// In en, this message translates to:
  /// **'ALLOW'**
  String get configAllow;

  /// No description provided for @configScheduledCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 HABIT} other{{count} HABITS}}'**
  String configScheduledCount(int count);

  /// No description provided for @configNoReminders.
  ///
  /// In en, this message translates to:
  /// **'No habit has a reminder yet. Turn on \"Daily Prompt\" when creating or editing a habit.'**
  String get configNoReminders;

  /// No description provided for @configBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Enable them in system settings.'**
  String get configBlocked;

  /// No description provided for @configLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE / NGÔN NGỮ'**
  String get configLanguage;

  /// No description provided for @configLangSystem.
  ///
  /// In en, this message translates to:
  /// **'System / Hệ thống'**
  String get configLangSystem;

  /// No description provided for @reminderBodyChecklist.
  ///
  /// In en, this message translates to:
  /// **'{name} — mark it done today'**
  String reminderBodyChecklist(String name);

  /// No description provided for @reminderBodyQuota.
  ///
  /// In en, this message translates to:
  /// **'{name} — {target} {unit} today'**
  String reminderBodyQuota(String name, int target, String unit);

  /// No description provided for @reminderBodyQuotaNoUnit.
  ///
  /// In en, this message translates to:
  /// **'{name} — {target} today'**
  String reminderBodyQuotaNoUnit(String name, int target);

  /// No description provided for @gridHudYear.
  ///
  /// In en, this message translates to:
  /// **'YEAR {year}'**
  String gridHudYear(int year);

  /// No description provided for @gridHudStreak.
  ///
  /// In en, this message translates to:
  /// **'{days}D STREAK'**
  String gridHudStreak(int days);

  /// No description provided for @gridHudFreezes.
  ///
  /// In en, this message translates to:
  /// **'{n} FREEZE'**
  String gridHudFreezes(int n);

  /// No description provided for @streakFreezeUsed.
  ///
  /// In en, this message translates to:
  /// **'Streak freeze used on {day}. Streak saved!'**
  String streakFreezeUsed(String day);

  /// No description provided for @streakFreezeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Earn 1 per 7-day streak, hold up to 2'**
  String get streakFreezeTooltip;

  /// No description provided for @gridHudLevel.
  ///
  /// In en, this message translates to:
  /// **'LVL {level}'**
  String gridHudLevel(int level);

  /// No description provided for @gridHudXp.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String gridHudXp(int xp);

  /// No description provided for @gridMatrixTitle.
  ///
  /// In en, this message translates to:
  /// **'MATRIX GRID • 10x{rows}'**
  String gridMatrixTitle(int rows);

  /// No description provided for @gridMatrixCleared.
  ///
  /// In en, this message translates to:
  /// **'{percent}% CLEARED'**
  String gridMatrixCleared(int percent);

  /// No description provided for @gridMatrixBase.
  ///
  /// In en, this message translates to:
  /// **'ROW {row} (BASE)'**
  String gridMatrixBase(int row);

  /// No description provided for @gridMatrixCap.
  ///
  /// In en, this message translates to:
  /// **'{percent}% CAP'**
  String gridMatrixCap(int percent);

  /// No description provided for @gridMatrixError.
  ///
  /// In en, this message translates to:
  /// **'Matrix error: {error}'**
  String gridMatrixError(String error);

  /// No description provided for @gridDayNow.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get gridDayNow;

  /// No description provided for @gridDayYesterday.
  ///
  /// In en, this message translates to:
  /// **'YST'**
  String get gridDayYesterday;

  /// No description provided for @gridDayAgo.
  ///
  /// In en, this message translates to:
  /// **'-{days}D'**
  String gridDayAgo(int days);

  /// No description provided for @gridRowsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ROW COMPLETED TODAY} other{{count} ROWS COMPLETED TODAY}}'**
  String gridRowsCompleted(int count);

  /// No description provided for @gridRowsMultiplier.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP MULTIPLIER'**
  String gridRowsMultiplier(int xp);

  /// No description provided for @gridHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE HABITS'**
  String get gridHabitsTitle;

  /// No description provided for @gridHabitsInProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} IN PROGRESS'**
  String gridHabitsInProgress(int count);

  /// No description provided for @gridHabitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Tap + to start your quest.'**
  String get gridHabitsEmpty;

  /// No description provided for @gridHabitsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load habits: {error}'**
  String gridHabitsLoadError(String error);

  /// No description provided for @gridHabitRestDay.
  ///
  /// In en, this message translates to:
  /// **'REST DAY'**
  String get gridHabitRestDay;

  /// No description provided for @gridBadgeFocus.
  ///
  /// In en, this message translates to:
  /// **'FOCUS {time}'**
  String gridBadgeFocus(String time);

  /// No description provided for @gridBadgeHours.
  ///
  /// In en, this message translates to:
  /// **'{done} / {target} HRS'**
  String gridBadgeHours(String done, String target);

  /// No description provided for @gridBadgeAmount.
  ///
  /// In en, this message translates to:
  /// **'{done} / {target} {unit}'**
  String gridBadgeAmount(int done, int target, String unit);

  /// No description provided for @gridUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update {name}: {error}'**
  String gridUpdateFailed(String name, String error);

  /// No description provided for @gridXpGain.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String gridXpGain(int xp);

  /// No description provided for @unitGlasses.
  ///
  /// In en, this message translates to:
  /// **'GL'**
  String get unitGlasses;

  /// No description provided for @unitPages.
  ///
  /// In en, this message translates to:
  /// **'PG'**
  String get unitPages;

  /// No description provided for @unitTimes.
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get unitTimes;

  /// No description provided for @unitReps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get unitReps;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get unitMinutes;

  /// Seven space-separated short weekday labels, Monday first.
  ///
  /// In en, this message translates to:
  /// **'M T W T F S S'**
  String get weekdayShortLabels;

  /// No description provided for @cadenceDaily.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get cadenceDaily;

  /// No description provided for @cadenceWeekdays.
  ///
  /// In en, this message translates to:
  /// **'WEEKDAYS'**
  String get cadenceWeekdays;

  /// No description provided for @cadenceCustom.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get cadenceCustom;

  /// No description provided for @tasksHeader.
  ///
  /// In en, this message translates to:
  /// **'QUEST LOG // {count, plural, =1{1 HABIT} other{{count} HABITS}}'**
  String tasksHeader(int count);

  /// No description provided for @tasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Tap + to create one.'**
  String get tasksEmpty;

  /// No description provided for @tasksGoalCheck.
  ///
  /// In en, this message translates to:
  /// **'CHECK'**
  String get tasksGoalCheck;

  /// No description provided for @tasksDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tasksDeleteTooltip;

  /// No description provided for @tasksDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'DELETE HABIT?'**
  String get tasksDeleteTitle;

  /// No description provided for @tasksDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and all its blocks and XP will be removed.'**
  String tasksDeleteBody(String name);

  /// No description provided for @tasksDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String tasksDeleteFailed(String error);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get commonCancel;

  /// No description provided for @commonNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get commonNew;

  /// No description provided for @unlockToastBadges.
  ///
  /// In en, this message translates to:
  /// **'🏅 {count, plural, =1{New badge unlocked!} other{{count} new badges unlocked!}} See Stats.'**
  String unlockToastBadges(int count);

  /// No description provided for @unlockToastThemes.
  ///
  /// In en, this message translates to:
  /// **'🎨 {count, plural, =1{New brick theme unlocked!} other{{count} new brick themes unlocked!}} See Config → Locker.'**
  String unlockToastThemes(int count);

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get commonSave;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String commonError(String message);

  /// No description provided for @navMatrix.
  ///
  /// In en, this message translates to:
  /// **'Matrix'**
  String get navMatrix;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navConfig.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get navConfig;

  /// No description provided for @titleGridView.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get titleGridView;

  /// No description provided for @titleTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get titleTasks;

  /// No description provided for @titleStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get titleStats;

  /// No description provided for @titleConfig.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get titleConfig;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get onboardingStart;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Build habits, pixel by pixel'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Add the habits you want to keep and check them in every day.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingMatrixTitle.
  ///
  /// In en, this message translates to:
  /// **'Every check-in drops a brick'**
  String get onboardingMatrixTitle;

  /// No description provided for @onboardingMatrixBody.
  ///
  /// In en, this message translates to:
  /// **'Fill a full row to clear it and earn bonus XP.'**
  String get onboardingMatrixBody;

  /// No description provided for @onboardingRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Level up, unlock rewards'**
  String get onboardingRewardsTitle;

  /// No description provided for @onboardingRewardsBody.
  ///
  /// In en, this message translates to:
  /// **'Earn badges and unlock brick skins and sound packs in the Locker.'**
  String get onboardingRewardsBody;

  /// No description provided for @onboardingRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a day'**
  String get onboardingRemindersTitle;

  /// No description provided for @onboardingRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders so the app can nudge you at the right time.'**
  String get onboardingRemindersBody;

  /// No description provided for @onboardingEnableReminders.
  ///
  /// In en, this message translates to:
  /// **'ENABLE REMINDERS'**
  String get onboardingEnableReminders;

  /// No description provided for @onboardingRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'Reminders enabled'**
  String get onboardingRemindersOn;

  /// No description provided for @onboardingRemindersDenied.
  ///
  /// In en, this message translates to:
  /// **'You can turn them on later in Config'**
  String get onboardingRemindersDenied;

  /// No description provided for @configFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback & support'**
  String get configFeedbackTitle;

  /// No description provided for @configFeedbackBody.
  ///
  /// In en, this message translates to:
  /// **'Found a bug or have an idea? Tell us!'**
  String get configFeedbackBody;

  /// No description provided for @configFeedbackSend.
  ///
  /// In en, this message translates to:
  /// **'SEND FEEDBACK'**
  String get configFeedbackSend;

  /// No description provided for @configReplayIntro.
  ///
  /// In en, this message translates to:
  /// **'REPLAY INTRO'**
  String get configReplayIntro;

  /// No description provided for @configAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String configAppVersion(String version, String build);

  /// No description provided for @feedbackNoMailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Write to {email}'**
  String feedbackNoMailApp(String email);

  /// No description provided for @feedbackCopy.
  ///
  /// In en, this message translates to:
  /// **'COPY'**
  String get feedbackCopy;

  /// No description provided for @feedbackEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackEmailSubject;

  /// No description provided for @feedbackEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the bug or idea here:'**
  String get feedbackEmailHint;

  /// No description provided for @shareMatrixTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share my matrix'**
  String get shareMatrixTooltip;

  /// No description provided for @shareMatrixTitle.
  ///
  /// In en, this message translates to:
  /// **'MY HABIT MATRIX'**
  String get shareMatrixTitle;

  /// No description provided for @shareMatrixSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{percent}% cleared · {date}'**
  String shareMatrixSubtitle(int percent, String date);

  /// No description provided for @shareMatrixTagline.
  ///
  /// In en, this message translates to:
  /// **'Build habits one pixel brick at a time · Free on Google Play'**
  String get shareMatrixTagline;

  /// No description provided for @shareMatrixText.
  ///
  /// In en, this message translates to:
  /// **'Building my habits one pixel brick at a time 🧱 Try Habit Tracker - Pixel: {link}'**
  String shareMatrixText(String link);

  /// No description provided for @shareMatrixError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the image. Please try again.'**
  String get shareMatrixError;

  /// No description provided for @configUsageStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage stats'**
  String get configUsageStatsTitle;

  /// No description provided for @configUsageStatsBody.
  ///
  /// In en, this message translates to:
  /// **'Helps us see which features work. Habit names and anything you type are never sent.'**
  String get configUsageStatsBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
