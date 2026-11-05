// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit Tracker - Pixel';

  @override
  String get editorModeTimes => 'SPECIFIC TIMES';

  @override
  String get editorModeRepeat => 'REPEAT';

  @override
  String get editorEvery => 'EVERY';

  @override
  String get editorFrom => 'FROM';

  @override
  String get editorTo => 'TO';

  @override
  String editorEveryMinutes(int count) {
    return '${count}m';
  }

  @override
  String editorRepeatSummary(int count, String first, String last) {
    return '≈ $count prompts a day ($first → $last)';
  }

  @override
  String get editorErrWindow => 'End time must be after start time';

  @override
  String configEveryRow(String interval, String from, String to) {
    return 'every $interval · $from–$to';
  }

  @override
  String configSummary(int count, String when) {
    return 'Scheduled $count prompts, next at $when';
  }

  @override
  String get configSummaryNone => 'No prompts scheduled';

  @override
  String get editorAddTime => '+ ADD TIME';

  @override
  String editorRemoveTime(String time) {
    return 'Remove $time';
  }

  @override
  String get lockerTitle => 'BRICK THEMES';

  @override
  String get lockerVaultTag => 'VAULT';

  @override
  String get lockerActiveSkin => 'ACTIVE SKIN';

  @override
  String lockerCollection(int count) {
    return 'THEME COLLECTION ($count TIERS)';
  }

  @override
  String lockerTierLine(int tier, String rarity) {
    return 'TIER $tier • $rarity';
  }

  @override
  String get lockerRarityCommon => 'COMMON';

  @override
  String get lockerRarityRare => 'RARE';

  @override
  String get lockerRarityEpic => 'EPIC';

  @override
  String get lockerRarityLegendary => 'LEGENDARY';

  @override
  String get lockerRarityMythic => 'MYTHIC';

  @override
  String get lockerRarityCosmic => 'COSMIC';

  @override
  String get lockerUnlockedMark => 'UNLOCKED';

  @override
  String get lockerThemeGameBoy => 'Game Boy DMG-01';

  @override
  String get lockerThemeNeonGlow => 'Arcade Neon Glow';

  @override
  String get lockerThemeCyberpunk => 'Cyber Glitch & CRT';

  @override
  String get lockerThemeGemstone => 'Pixel Gemstones';

  @override
  String get lockerThemePureGold => 'Gold Relic & Obsidian';

  @override
  String get lockerThemeNebula => 'Starlight Nebula';

  @override
  String get lockerEquip => 'EQUIP';

  @override
  String get lockerActive => 'ACTIVE';

  @override
  String lockerStreakProgress(int current, int goal) {
    return '$current/$goal D';
  }

  @override
  String lockerLevelChip(int level) {
    return 'LVL $level';
  }

  @override
  String get lockerPro => 'PRO';

  @override
  String lockerReqStreak(int days) {
    return 'Requires $days-Day Streak';
  }

  @override
  String lockerReqLevel(int level) {
    return 'Requires Hero LVL $level';
  }

  @override
  String lockerReqLevelOrStreak(int level, int days) {
    return 'Requires Hero LVL $level or $days-Day Streak';
  }

  @override
  String get lockerComingSoon => 'COMING SOON';

  @override
  String lockerEntrySubtitle(int unlocked, int total) {
    return '$unlocked/$total UNLOCKED · SKINS & SOUND PACKS';
  }

  @override
  String get lockerNewTheme => 'NEW THEME!';

  @override
  String get lockerEquipNow => 'EQUIP NOW';

  @override
  String get lockerLater => 'LATER';

  @override
  String get soundCardTitle => 'SOUND / ÂM THANH';

  @override
  String get soundEnabled => 'Sound effects';

  @override
  String get soundVolume => 'Volume';

  @override
  String soundPackLabel(String name) {
    return 'Sound pack: $name';
  }

  @override
  String get soundPreview => '▶ PREVIEW';

  @override
  String get soundPackChiptune => '4-Bit Chiptune Bleep';

  @override
  String get soundPackSynthPop => '8-Bit Synth Pop & Coin SFX';

  @override
  String get soundPackLaserDrop => 'Laser Drop SFX';

  @override
  String get soundPackCrystalChime => 'Crystal Bell Chime';

  @override
  String get soundPackCoinCascade => 'Coin Cascade SFX';

  @override
  String get soundPackCosmicWarp => 'Cosmic Warp Ambient';

  @override
  String get configDemoTitle => 'DEMO // LOVE MATRIX';

  @override
  String get configDemoBody =>
      'Fills the matrix with 10 days of sample habits whose bricks spell LOVE — handy for screenshots and presentations.';

  @override
  String get configDemoButton => 'BUILD LOVE MATRIX';

  @override
  String get configDemoConfirmTitle => 'REPLACE DATA WITH DEMO?';

  @override
  String get configDemoConfirmBody =>
      'All habits, bricks and XP on this device are replaced by 12 sample habits. This can\'t be undone.';

  @override
  String get configDemoConfirm => 'REPLACE';

  @override
  String get configDemoSignedIn =>
      'Sign out to use the demo, so it isn\'t synced to your account.';

  @override
  String get configDemoDone => 'Done! Open the Matrix tab to watch LOVE build.';

  @override
  String configDemoFailed(String error) {
    return 'Could not build the demo: $error';
  }

  @override
  String get accountErrUnavailable =>
      'The sign-in service isn\'t available right now. Please try again later.';

  @override
  String get accountLoginTag => 'AUTH_INIT.EXE';

  @override
  String get accountLoginTitle => 'SIGN IN';

  @override
  String get accountProfileTag => 'PLAYER_PROFILE.SYS';

  @override
  String get accountProfileTitle => 'PROFILE';

  @override
  String get accountEmailLabel => 'EMAIL';

  @override
  String get accountSendCode => 'SEND CODE';

  @override
  String get accountGuestLinkNote =>
      'Habits you track as a guest stay on this device. They are linked to your account the first time you sign in, so nothing is lost.';

  @override
  String accountCodeSent(String email) {
    return 'We sent a 6-digit code to $email. It can take a minute to arrive.';
  }

  @override
  String get accountCodeLabel => 'VERIFICATION CODE';

  @override
  String get accountPaste => 'PASTE';

  @override
  String get accountVerify => 'VERIFY';

  @override
  String accountResendIn(int seconds) {
    return 'RESEND IN ${seconds}S';
  }

  @override
  String get accountResend => 'RESEND CODE';

  @override
  String get accountChangeEmail => 'CHANGE EMAIL';

  @override
  String get accountErrInvalidEmail => 'Enter a valid email address.';

  @override
  String get accountErrTooManyRequests =>
      'Too many requests. Please wait before asking for another code.';

  @override
  String get accountErrInvalidCode => 'Wrong code. Check it and try again.';

  @override
  String accountErrInvalidCodeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wrong code. $count attempts left.',
      one: 'Wrong code. 1 attempt left.',
    );
    return '$_temp0';
  }

  @override
  String get accountErrExpiredCode =>
      'This code has expired. Request a new one.';

  @override
  String get accountErrTooManyAttempts =>
      'Too many wrong attempts. Request a new code.';

  @override
  String get accountErrNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get accountErrUnknown => 'Something went wrong. Please try again.';

  @override
  String get accountUnavailableTitle => 'CLOUD UNAVAILABLE';

  @override
  String get accountUnavailableBody =>
      'Cloud accounts could not start on this device. Your habits still work and stay saved locally. Restart the app to try again.';

  @override
  String get accountActionFailed => 'Something went wrong. Please try again.';

  @override
  String get accountNameLabel => 'DISPLAY NAME';

  @override
  String get accountNameHint => 'Your name';

  @override
  String get accountBirthYearLabel => 'BIRTH YEAR';

  @override
  String get accountBirthYearHint => 'e.g. 1995';

  @override
  String get accountGenderLabel => 'GENDER';

  @override
  String get accountGenderMale => 'MALE';

  @override
  String get accountGenderFemale => 'FEMALE';

  @override
  String get accountGenderOther => 'OTHER';

  @override
  String get accountGenderUnspecified => 'NOT SAID';

  @override
  String get accountVerified => 'VERIFIED';

  @override
  String get accountAddressLabel => 'ADDRESS';

  @override
  String get accountAddressHint => 'Street, city, country';

  @override
  String accountMaxChars(int count) {
    return 'MAX $count CHR';
  }

  @override
  String accountErrTooLong(int max) {
    return 'Too long (max $max characters).';
  }

  @override
  String accountErrBirthYear(int min, int max) {
    return 'Enter a year between $min and $max.';
  }

  @override
  String get accountSave => 'SAVE PROFILE';

  @override
  String get accountSaved => 'Saved. It will sync when you are online.';

  @override
  String get accountBadgesTitle => 'PIXEL BADGES';

  @override
  String get accountBadgesEmpty =>
      'No badges unlocked yet. Keep completing habits to earn your first one.';

  @override
  String accountBadgeUnlockedOn(String date) {
    return 'UNLOCKED $date';
  }

  @override
  String get accountSyncTitle => 'CLOUD SYNC';

  @override
  String get accountSyncIdle => 'SYNCED';

  @override
  String get accountSyncSyncing => 'SYNCING...';

  @override
  String get accountSyncOffline => 'OFFLINE';

  @override
  String get accountSyncError => 'SYNC ERROR';

  @override
  String get accountSyncDisabled => 'SYNC OFF';

  @override
  String accountSyncLast(String time) {
    return 'LAST SYNC $time';
  }

  @override
  String get accountSyncNever => 'NOT SYNCED YET';

  @override
  String accountSyncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count CHANGES PENDING',
      one: '1 CHANGE PENDING',
    );
    return '$_temp0';
  }

  @override
  String get accountSyncNow => 'SYNC NOW';

  @override
  String get accountSignOut => 'SIGN OUT';

  @override
  String get accountSignOutTitle => 'SIGN OUT?';

  @override
  String get accountSignOutBody =>
      'When online, your data is uploaded to your account first, then removed from this device. Sign in again to restore it.';

  @override
  String accountSignOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count changes haven\'t been uploaded (offline?). Sign out anyway and lose them?',
      one:
          '1 change hasn\'t been uploaded (offline?). Sign out anyway and lose it?',
    );
    return '$_temp0';
  }

  @override
  String get accountKeepSignedIn => 'STAY SIGNED IN';

  @override
  String get accountSignOutAnyway => 'SIGN OUT ANYWAY';

  @override
  String get accountDelete => 'DELETE ACCOUNT';

  @override
  String get accountDeleteTitle => 'DELETE ACCOUNT?';

  @override
  String get accountDeleteBody =>
      'Your account, profile, habits, bricks and XP are permanently deleted from the cloud and this device. This cannot be undone.';

  @override
  String get accountDeleteConfirm => 'DELETE FOREVER';

  @override
  String get accountDeleteOffline =>
      'Connect to the internet to delete your account.';

  @override
  String get accountCancel => 'CANCEL';

  @override
  String get statsTierCommon => 'COMMON';

  @override
  String get statsTierRare => 'RARE';

  @override
  String get statsTierEpic => 'EPIC';

  @override
  String get statsTierLegendary => 'LEGENDARY';

  @override
  String get statsBadgeNewTitle => 'NEW BADGE!';

  @override
  String get statsBadgeNewDismiss => 'AWESOME';

  @override
  String statsMonthYear(String monthName, int month, int year) {
    return '$monthName $year';
  }

  @override
  String get statsTitle => 'HABIT ANALYTICS';

  @override
  String get statsLoadError => 'Could not load analytics';

  @override
  String get statsRangeWeek => 'Week';

  @override
  String get statsRangeMonth => 'Month';

  @override
  String get statsRangeYear => 'Year';

  @override
  String get statsRangeAll => 'All Time';

  @override
  String get statsCaptionWeek => 'LAST 7 DAYS';

  @override
  String get statsCaptionMonth => 'LAST 30 DAYS';

  @override
  String get statsCaptionYear => 'LAST 365 DAYS';

  @override
  String get statsCaptionAll => 'ALL TIME';

  @override
  String get statsWindowWeek => '7D WINDOW';

  @override
  String get statsWindowMonth => '30D WINDOW';

  @override
  String get statsWindowYear => '365D WINDOW';

  @override
  String get statsWindowAll => 'ALL TIME';

  @override
  String statsSyncLine(String time) {
    return 'SYNCED: TODAY $time';
  }

  @override
  String get statsTileCurrentStreak => 'CURR STREAK';

  @override
  String get statsTileBestStreak => 'BEST STREAK';

  @override
  String get statsTileRate => 'RATE';

  @override
  String get statsTileBlocks => 'BLOCKS';

  @override
  String get statsUnitDays => 'DAYS';

  @override
  String get statsUnitStack => 'STACK';

  @override
  String get statsCaptionStreakAlive => 'Any block keeps it alive';

  @override
  String get statsCaptionRecord => 'ALL-TIME RECORD';

  @override
  String statsCaptionHabitDays(int done, int due) {
    return '$done / $due habit-days';
  }

  @override
  String statsCaptionNothingDue(String range) {
    return 'Nothing due · $range';
  }

  @override
  String statsCaptionPerfectClears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perfect clears',
      one: '1 perfect clear',
    );
    return '$_temp0';
  }

  @override
  String statsDeltaPoints(String value) {
    return '$value PTS';
  }

  @override
  String statsHeatmapTitle(String month) {
    return 'ACTIVITY MATRIX // $month';
  }

  @override
  String statsHeatmapEfficiency(int percent) {
    return '$percent% EFFICIENCY';
  }

  @override
  String get statsLegendLess => 'LESS';

  @override
  String get statsLegendMore => 'MORE';

  @override
  String statsPerfectClear(int days) {
    return 'PERFECT CLEAR: ${days}D';
  }

  @override
  String get statsPrevMonth => 'Previous month';

  @override
  String get statsNextMonth => 'Next month';

  @override
  String statsCellNoneDue(String date) {
    return '$date, none due';
  }

  @override
  String statsCellDone(String date, int done, int due) {
    return '$date, $done of $due done';
  }

  @override
  String get statsBreakdownTitle => 'HABIT CONSISTENCY BREAKDOWN';

  @override
  String get statsBreakdownEmpty =>
      'No habits yet. Create one with the + button.';

  @override
  String statsDaysTargetMet(int met, int due) {
    return '$met / $due Days Target Met';
  }

  @override
  String statsStreak(int days) {
    return 'Streak: ${days}D';
  }

  @override
  String statsStatDone(int count) {
    return '$count DONE';
  }

  @override
  String statsStatLogged(String duration) {
    return '≥ $duration LOGGED';
  }

  @override
  String statsDurationHM(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String statsDurationM(int minutes) {
    return '${minutes}m';
  }

  @override
  String statsBadgesTitle(int unlocked, int total) {
    return 'PIXEL BADGES ($unlocked/$total)';
  }

  @override
  String get statsViewAll => 'VIEW ALL';

  @override
  String get statsBadgesNoXp => 'Badges are trophies only and award no XP.';

  @override
  String get statsBadgeUnlocked => 'UNLOCKED';

  @override
  String get statsBadgeLocked => 'LOCKED';

  @override
  String statsBadgeSemantics(String title, String state, String description) {
    return '$title, $state. $description';
  }

  @override
  String get statsBadgeFirstBlockName => 'First Block';

  @override
  String get statsBadgeFirstBlockDesc => 'Place your first block';

  @override
  String get statsBadgeBrickLayerName => 'Brick Layer';

  @override
  String get statsBadgeBrickLayerDesc => 'Place 25 blocks';

  @override
  String get statsBadgeBrickMasterName => 'Brick Master';

  @override
  String get statsBadgeBrickMasterDesc => 'Place 100 blocks';

  @override
  String get statsBadgeWarriorName => '7-Day Warrior';

  @override
  String get statsBadgeWarriorDesc => 'Place a block 7 days in a row';

  @override
  String get statsBadgeLineClearerName => 'Line Clearer';

  @override
  String get statsBadgeLineClearerDesc => 'Place a block 10 days in a row';

  @override
  String get statsBadgeLegendName => '30-Day Legend';

  @override
  String get statsBadgeLegendDesc => 'Place a block 30 days in a row';

  @override
  String get statsBadgePerfectDayName => 'Perfect Day';

  @override
  String get statsBadgePerfectDayDesc => 'Complete every habit due in one day';

  @override
  String get statsBadgePerfectWeekName => 'Perfect Week';

  @override
  String get statsBadgePerfectWeekDesc => 'Perfect days 7 times in a row';

  @override
  String get statsBadgeLevel5Name => 'Level 5';

  @override
  String get statsBadgeLevel5Desc => 'Reach level 5';

  @override
  String get statsBadgeLevel10Name => 'Level 10';

  @override
  String get statsBadgeLevel10Desc => 'Reach level 10';

  @override
  String statsProgressBlocks(int current, int goal) {
    return 'BLOCKS $current / $goal';
  }

  @override
  String statsProgressStreak(int current, int goal) {
    return 'BEST $current / $goal DAYS';
  }

  @override
  String statsProgressPerfectRun(int current, int goal) {
    return 'BEST $current / $goal PERFECT DAYS';
  }

  @override
  String statsProgressBestDay(int done, int due) {
    return 'BEST DAY $done / $due HABITS';
  }

  @override
  String get statsProgressNoHabits => 'NO HABITS DUE YET';

  @override
  String statsProgressLevel(int current, int goal) {
    return 'LEVEL $current / $goal';
  }

  @override
  String get editorNewHabit => 'NEW HABIT';

  @override
  String get editorEditHabit => 'EDIT HABIT';

  @override
  String get editorClose => 'Close';

  @override
  String get editorIdentityTag => '01 // IDENTITY';

  @override
  String get editorTitleLabel => 'HABIT TITLE';

  @override
  String editorMaxChars(int count) {
    return 'MAX $count CHR';
  }

  @override
  String get editorTitleHint => 'Read 20 Pages';

  @override
  String get editorTemplatesLabel => 'TEMPLATES · TAP TO FILL';

  @override
  String get tasksSwipeHint => 'Swipe left on a habit to delete it';

  @override
  String get editorIconsMore => 'More icons';

  @override
  String get editorIconsLess => 'Fewer icons';

  @override
  String get detailNotFound => 'This habit no longer exists.';

  @override
  String get editorClearTitle => 'Clear title';

  @override
  String get editorIconMatrix => 'SELECT ICON MATRIX';

  @override
  String get editorMetaphorTag => '02 // METAPHOR';

  @override
  String get editorColorTitle => 'PIXEL BLOCK COLOR';

  @override
  String get editorColorHint =>
      'Sets the color of this habit\'s blocks on the live matrix.';

  @override
  String editorColorSemantics(String hex) {
    return 'Color $hex';
  }

  @override
  String get editorCadenceTag => '03 // CADENCE';

  @override
  String get editorCadenceTitle => 'CADENCE & GOAL';

  @override
  String editorLoop(String cadence) {
    return 'LOOP_$cadence';
  }

  @override
  String get editorDailyQuota => 'DAILY QUOTA';

  @override
  String get editorQuotaDecrease => 'Decrease quota';

  @override
  String get editorQuotaIncrease => 'Increase quota';

  @override
  String get editorChipPages => 'Pages';

  @override
  String get editorChipMinutes => 'Minutes';

  @override
  String get editorChipTimes => 'Times';

  @override
  String get editorChipGlasses => 'Glasses';

  @override
  String get editorChipCheck => 'Check';

  @override
  String get editorAlertsTag => '04 // ALERTS';

  @override
  String get editorNotifications => 'NOTIFICATIONS';

  @override
  String get editorDailyPrompt => 'Daily Prompt';

  @override
  String get editorPromptOn => 'Reminds you on every day this habit is due';

  @override
  String get editorNoReminder => 'No reminder';

  @override
  String get editorErrTitleEmpty => 'Enter a habit title';

  @override
  String editorErrTitleLength(int max) {
    return 'Title must be 1-$max characters';
  }

  @override
  String get editorErrNoDays => 'Pick at least one day';

  @override
  String get editorErrQuota => 'Quota must be at least 1';

  @override
  String editorSaveFailed(String error) {
    return 'Could not save habit: $error';
  }

  @override
  String get editorCreate => 'CREATE HABIT';

  @override
  String get editorSaveChanges => 'SAVE CHANGES';

  @override
  String get editorCreateHint =>
      'Drops into the live matrix when you hit today\'s quota';

  @override
  String get editorEditHint => 'Changes apply immediately';

  @override
  String get configTitle => 'CONFIG';

  @override
  String get configNotifications => 'NOTIFICATIONS';

  @override
  String get configChecking => 'CHECKING...';

  @override
  String get configAllow => 'ALLOW';

  @override
  String configScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count HABITS',
      one: '1 HABIT',
    );
    return '$_temp0';
  }

  @override
  String get configNoReminders =>
      'No habit has a reminder yet. Turn on \"Daily Prompt\" when creating or editing a habit.';

  @override
  String get configBlocked =>
      'Notifications are blocked. Enable them in system settings.';

  @override
  String get configLanguage => 'LANGUAGE / NGÔN NGỮ';

  @override
  String get configLangSystem => 'System / Hệ thống';

  @override
  String reminderBodyChecklist(String name) {
    return '$name — mark it done today';
  }

  @override
  String reminderBodyQuota(String name, int target, String unit) {
    return '$name — $target $unit today';
  }

  @override
  String reminderBodyQuotaNoUnit(String name, int target) {
    return '$name — $target today';
  }

  @override
  String gridHudYear(int year) {
    return 'YEAR $year';
  }

  @override
  String gridHudStreak(int days) {
    return '${days}D STREAK';
  }

  @override
  String gridHudLevel(int level) {
    return 'LVL $level';
  }

  @override
  String gridHudXp(int xp) {
    return '$xp XP';
  }

  @override
  String gridMatrixTitle(int rows) {
    return 'MATRIX GRID • 10x$rows';
  }

  @override
  String gridMatrixCleared(int percent) {
    return '$percent% CLEARED';
  }

  @override
  String gridMatrixBase(int row) {
    return 'ROW $row (BASE)';
  }

  @override
  String gridMatrixCap(int percent) {
    return '$percent% CAP';
  }

  @override
  String gridMatrixError(String error) {
    return 'Matrix error: $error';
  }

  @override
  String get gridDayNow => 'NOW';

  @override
  String get gridDayYesterday => 'YST';

  @override
  String gridDayAgo(int days) {
    return '-${days}D';
  }

  @override
  String gridRowsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ROWS COMPLETED TODAY',
      one: '1 ROW COMPLETED TODAY',
    );
    return '$_temp0';
  }

  @override
  String gridRowsMultiplier(int xp) {
    return '+$xp XP MULTIPLIER';
  }

  @override
  String get gridHabitsTitle => 'ACTIVE HABITS';

  @override
  String gridHabitsInProgress(int count) {
    return '$count IN PROGRESS';
  }

  @override
  String get gridHabitsEmpty => 'No habits yet. Tap + to start your quest.';

  @override
  String gridHabitsLoadError(String error) {
    return 'Could not load habits: $error';
  }

  @override
  String get gridHabitRestDay => 'REST DAY';

  @override
  String gridBadgeFocus(String time) {
    return 'FOCUS $time';
  }

  @override
  String gridBadgeHours(String done, String target) {
    return '$done / $target HRS';
  }

  @override
  String gridBadgeAmount(int done, int target, String unit) {
    return '$done / $target $unit';
  }

  @override
  String gridUpdateFailed(String name, String error) {
    return 'Could not update $name: $error';
  }

  @override
  String gridXpGain(int xp) {
    return '+$xp XP';
  }

  @override
  String get unitGlasses => 'GL';

  @override
  String get unitPages => 'PG';

  @override
  String get unitTimes => 'X';

  @override
  String get unitReps => 'REPS';

  @override
  String get unitMinutes => 'MIN';

  @override
  String get weekdayShortLabels => 'M T W T F S S';

  @override
  String get cadenceDaily => 'DAILY';

  @override
  String get cadenceWeekdays => 'WEEKDAYS';

  @override
  String get cadenceCustom => 'CUSTOM';

  @override
  String tasksHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count HABITS',
      one: '1 HABIT',
    );
    return 'QUEST LOG // $_temp0';
  }

  @override
  String get tasksEmpty => 'No habits yet. Tap + to create one.';

  @override
  String get tasksGoalCheck => 'CHECK';

  @override
  String get tasksDeleteTooltip => 'Delete';

  @override
  String get tasksDeleteTitle => 'DELETE HABIT?';

  @override
  String tasksDeleteBody(String name) {
    return '\"$name\" and all its blocks and XP will be removed.';
  }

  @override
  String tasksDeleteFailed(String error) {
    return 'Could not delete: $error';
  }

  @override
  String get commonCancel => 'CANCEL';

  @override
  String get commonNew => 'NEW';

  @override
  String unlockToastBadges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new badges unlocked!',
      one: 'New badge unlocked!',
    );
    return '🏅 $_temp0 See Stats.';
  }

  @override
  String unlockToastThemes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new brick themes unlocked!',
      one: 'New brick theme unlocked!',
    );
    return '🎨 $_temp0 See Config → Locker.';
  }

  @override
  String get commonDelete => 'DELETE';

  @override
  String get commonRetry => 'RETRY';

  @override
  String get commonSave => 'SAVE';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }

  @override
  String get navMatrix => 'Matrix';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navStats => 'Stats';

  @override
  String get navConfig => 'Config';

  @override
  String get titleGridView => 'Habit';

  @override
  String get titleTasks => 'Tasks';

  @override
  String get titleStats => 'Stats';

  @override
  String get titleConfig => 'Config';

  @override
  String get onboardingSkip => 'SKIP';

  @override
  String get onboardingNext => 'NEXT';

  @override
  String get onboardingStart => 'START';

  @override
  String get onboardingWelcomeTitle => 'Build habits, pixel by pixel';

  @override
  String get onboardingWelcomeBody =>
      'Add the habits you want to keep and check them in every day.';

  @override
  String get onboardingMatrixTitle => 'Every check-in drops a brick';

  @override
  String get onboardingMatrixBody =>
      'Fill a full row to clear it and earn bonus XP.';

  @override
  String get onboardingRewardsTitle => 'Level up, unlock rewards';

  @override
  String get onboardingRewardsBody =>
      'Earn badges and unlock brick skins and sound packs in the Locker.';

  @override
  String get onboardingRemindersTitle => 'Never miss a day';

  @override
  String get onboardingRemindersBody =>
      'Turn on reminders so the app can nudge you at the right time.';

  @override
  String get onboardingEnableReminders => 'ENABLE REMINDERS';

  @override
  String get onboardingRemindersOn => 'Reminders enabled';

  @override
  String get onboardingRemindersDenied =>
      'You can turn them on later in Config';

  @override
  String get configFeedbackTitle => 'Feedback & support';

  @override
  String get configFeedbackBody => 'Found a bug or have an idea? Tell us!';

  @override
  String get configFeedbackSend => 'SEND FEEDBACK';

  @override
  String get configReplayIntro => 'REPLAY INTRO';

  @override
  String configAppVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String feedbackNoMailApp(String email) {
    return 'No email app found. Write to $email';
  }

  @override
  String get feedbackCopy => 'COPY';

  @override
  String get feedbackEmailSubject => 'Feedback';

  @override
  String get feedbackEmailHint => 'Describe the bug or idea here:';
}
