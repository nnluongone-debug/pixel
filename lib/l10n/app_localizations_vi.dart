// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Habit Tracker - Pixel';

  @override
  String get editorModeTimes => 'GIỜ CỤ THỂ';

  @override
  String get editorModeRepeat => 'LẶP LẠI';

  @override
  String get editorEvery => 'MỖI';

  @override
  String get editorFrom => 'TỪ';

  @override
  String get editorTo => 'ĐẾN';

  @override
  String editorEveryMinutes(int count) {
    return '${count}p';
  }

  @override
  String editorRepeatSummary(int count, String first, String last) {
    return '≈ $count lời nhắc mỗi ngày ($first → $last)';
  }

  @override
  String get editorErrWindow => 'Giờ kết thúc phải sau giờ bắt đầu';

  @override
  String configEveryRow(String interval, String from, String to) {
    return 'mỗi $interval · $from–$to';
  }

  @override
  String configSummary(int count, String when) {
    return 'Đã lên lịch $count lời nhắc, tiếp theo lúc $when';
  }

  @override
  String get configSummaryNone => 'Chưa có lời nhắc nào được lên lịch';

  @override
  String get editorAddTime => '+ THÊM GIỜ';

  @override
  String editorRemoveTime(String time) {
    return 'Xóa $time';
  }

  @override
  String get lockerTitle => 'BỘ GẠCH';

  @override
  String get lockerVaultTag => 'KHO';

  @override
  String get lockerActiveSkin => 'GIAO DIỆN ĐANG DÙNG';

  @override
  String lockerCollection(int count) {
    return 'BỘ SƯU TẬP ($count CẤP)';
  }

  @override
  String lockerTierLine(int tier, String rarity) {
    return 'CẤP $tier • $rarity';
  }

  @override
  String get lockerRarityCommon => 'PHỔ THÔNG';

  @override
  String get lockerRarityRare => 'HIẾM';

  @override
  String get lockerRarityEpic => 'SỬ THI';

  @override
  String get lockerRarityLegendary => 'HUYỀN THOẠI';

  @override
  String get lockerRarityMythic => 'THẦN THOẠI';

  @override
  String get lockerRarityCosmic => 'VŨ TRỤ';

  @override
  String get lockerUnlockedMark => 'ĐÃ MỞ';

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
  String get lockerEquip => 'DÙNG';

  @override
  String get lockerActive => 'ĐANG DÙNG';

  @override
  String lockerStreakProgress(int current, int goal) {
    return '$current/$goal N';
  }

  @override
  String lockerLevelChip(int level) {
    return 'LV $level';
  }

  @override
  String get lockerPro => 'PRO';

  @override
  String lockerReqStreak(int days) {
    return 'Cần chuỗi $days ngày';
  }

  @override
  String lockerReqLevel(int level) {
    return 'Cần cấp anh hùng $level';
  }

  @override
  String lockerReqLevelOrStreak(int level, int days) {
    return 'Cần cấp $level hoặc chuỗi $days ngày';
  }

  @override
  String get lockerComingSoon => 'SẮP RA MẮT';

  @override
  String lockerEntrySubtitle(int unlocked, int total) {
    return 'ĐÃ MỞ $unlocked/$total · GIAO DIỆN & ÂM THANH';
  }

  @override
  String get lockerNewTheme => 'GIAO DIỆN MỚI!';

  @override
  String get lockerEquipNow => 'DÙNG NGAY';

  @override
  String get lockerLater => 'ĐỂ SAU';

  @override
  String get soundCardTitle => 'SOUND / ÂM THANH';

  @override
  String get soundEnabled => 'Hiệu ứng âm thanh';

  @override
  String get soundVolume => 'Âm lượng';

  @override
  String soundPackLabel(String name) {
    return 'Bộ âm thanh: $name';
  }

  @override
  String get soundPreview => '▶ NGHE THỬ';

  @override
  String get soundPackChiptune => 'Chiptune 4-bit';

  @override
  String get soundPackSynthPop => 'Synth Pop 8-bit & Xu';

  @override
  String get soundPackLaserDrop => 'Laser rơi';

  @override
  String get soundPackCrystalChime => 'Chuông pha lê';

  @override
  String get soundPackCoinCascade => 'Thác xu vàng';

  @override
  String get soundPackCosmicWarp => 'Không gian vũ trụ';

  @override
  String get configDemoTitle => 'DEMO // MA TRẬN LOVE';

  @override
  String get configDemoBody =>
      'Tạo 10 ngày dữ liệu mẫu, các viên gạch xếp thành chữ LOVE — tiện để chụp màn hình và thuyết trình.';

  @override
  String get configDemoButton => 'TẠO MA TRẬN LOVE';

  @override
  String get configDemoConfirmTitle => 'THAY DỮ LIỆU BẰNG DEMO?';

  @override
  String get configDemoConfirmBody =>
      'Toàn bộ thói quen, gạch và XP trên máy này sẽ được thay bằng 12 thói quen mẫu. Không thể hoàn tác.';

  @override
  String get configDemoConfirm => 'THAY THẾ';

  @override
  String get configDemoSignedIn =>
      'Hãy đăng xuất để dùng demo, tránh dữ liệu mẫu bị đồng bộ vào tài khoản.';

  @override
  String get configDemoDone =>
      'Xong! Mở tab Ma trận để xem chữ LOVE hình thành.';

  @override
  String configDemoFailed(String error) {
    return 'Không tạo được demo: $error';
  }

  @override
  String get accountErrUnavailable =>
      'Dịch vụ đăng nhập hiện chưa sẵn sàng. Vui lòng thử lại sau.';

  @override
  String get accountLoginTag => 'AUTH_INIT.EXE';

  @override
  String get accountLoginTitle => 'ĐĂNG NHẬP';

  @override
  String get accountProfileTag => 'PLAYER_PROFILE.SYS';

  @override
  String get accountProfileTitle => 'HỒ SƠ';

  @override
  String get accountEmailLabel => 'EMAIL';

  @override
  String get accountSendCode => 'GỬI MÃ';

  @override
  String get accountGuestLinkNote =>
      'Thói quen bạn theo dõi khi chưa đăng nhập vẫn nằm trên thiết bị này. Chúng sẽ được liên kết với tài khoản ở lần đăng nhập đầu tiên, không mất gì cả.';

  @override
  String accountCodeSent(String email) {
    return 'Chúng tôi đã gửi mã 6 chữ số tới $email. Mã có thể đến sau vài chục giây.';
  }

  @override
  String get accountCodeLabel => 'MÃ XÁC THỰC';

  @override
  String get accountPaste => 'DÁN';

  @override
  String get accountVerify => 'XÁC THỰC';

  @override
  String accountResendIn(int seconds) {
    return 'GỬI LẠI SAU ${seconds}S';
  }

  @override
  String get accountResend => 'GỬI LẠI MÃ';

  @override
  String get accountChangeEmail => 'ĐỔI EMAIL';

  @override
  String get accountErrInvalidEmail => 'Hãy nhập địa chỉ email hợp lệ.';

  @override
  String get accountErrTooManyRequests =>
      'Bạn yêu cầu quá nhiều lần. Hãy chờ một lúc rồi xin mã mới.';

  @override
  String get accountErrInvalidCode => 'Mã sai. Hãy kiểm tra và thử lại.';

  @override
  String accountErrInvalidCodeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mã sai. Còn $count lần thử.',
    );
    return '$_temp0';
  }

  @override
  String get accountErrExpiredCode => 'Mã đã hết hạn. Hãy xin mã mới.';

  @override
  String get accountErrTooManyAttempts =>
      'Bạn nhập sai quá nhiều lần. Hãy xin mã mới.';

  @override
  String get accountErrNetwork =>
      'Không có kết nối. Hãy kiểm tra mạng và thử lại.';

  @override
  String get accountErrUnknown => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get accountUnavailableTitle => 'ĐÁM MÂY KHÔNG KHẢ DỤNG';

  @override
  String get accountUnavailableBody =>
      'Không thể khởi động tài khoản đám mây trên thiết bị này. Thói quen của bạn vẫn hoạt động và được lưu trên máy. Hãy khởi động lại ứng dụng để thử lại.';

  @override
  String get accountActionFailed => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get accountNameLabel => 'TÊN HIỂN THỊ';

  @override
  String get accountNameHint => 'Tên của bạn';

  @override
  String get accountBirthYearLabel => 'NĂM SINH';

  @override
  String get accountBirthYearHint => 'VD: 1995';

  @override
  String get accountGenderLabel => 'GIỚI TÍNH';

  @override
  String get accountGenderMale => 'NAM';

  @override
  String get accountGenderFemale => 'NỮ';

  @override
  String get accountGenderOther => 'KHÁC';

  @override
  String get accountGenderUnspecified => 'KHÔNG NÊU';

  @override
  String get accountVerified => 'ĐÃ XÁC MINH';

  @override
  String get accountAddressLabel => 'ĐỊA CHỈ';

  @override
  String get accountAddressHint => 'Đường, thành phố, quốc gia';

  @override
  String accountMaxChars(int count) {
    return 'TỐI ĐA $count KÝ TỰ';
  }

  @override
  String accountErrTooLong(int max) {
    return 'Quá dài (tối đa $max ký tự).';
  }

  @override
  String accountErrBirthYear(int min, int max) {
    return 'Hãy nhập năm từ $min đến $max.';
  }

  @override
  String get accountSave => 'LƯU HỒ SƠ';

  @override
  String get accountSaved => 'Đã lưu. Sẽ đồng bộ khi có mạng.';

  @override
  String get accountBadgesTitle => 'HUY HIỆU PIXEL';

  @override
  String get accountBadgesEmpty =>
      'Chưa mở khóa huy hiệu nào. Hãy hoàn thành thói quen để nhận huy hiệu đầu tiên.';

  @override
  String accountBadgeUnlockedOn(String date) {
    return 'MỞ KHÓA $date';
  }

  @override
  String get accountSyncTitle => 'ĐỒNG BỘ ĐÁM MÂY';

  @override
  String get accountSyncIdle => 'ĐÃ ĐỒNG BỘ';

  @override
  String get accountSyncSyncing => 'ĐANG ĐỒNG BỘ...';

  @override
  String get accountSyncOffline => 'NGOẠI TUYẾN';

  @override
  String get accountSyncError => 'LỖI ĐỒNG BỘ';

  @override
  String get accountSyncDisabled => 'TẮT ĐỒNG BỘ';

  @override
  String accountSyncLast(String time) {
    return 'LẦN CUỐI $time';
  }

  @override
  String get accountSyncNever => 'CHƯA ĐỒNG BỘ';

  @override
  String accountSyncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count THAY ĐỔI CHỜ ĐỒNG BỘ',
    );
    return '$_temp0';
  }

  @override
  String get accountSyncNow => 'ĐỒNG BỘ NGAY';

  @override
  String get accountSignOut => 'ĐĂNG XUẤT';

  @override
  String get accountSignOutTitle => 'ĐĂNG XUẤT?';

  @override
  String get accountSignOutBody =>
      'Khi có mạng, dữ liệu được tải lên tài khoản trước rồi xóa khỏi thiết bị này. Đăng nhập lại để khôi phục.';

  @override
  String accountSignOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count thay đổi chưa được tải lên (đang ngoại tuyến?). Vẫn đăng xuất và mất chúng?',
    );
    return '$_temp0';
  }

  @override
  String get accountKeepSignedIn => 'Ở LẠI';

  @override
  String get accountSignOutAnyway => 'VẪN ĐĂNG XUẤT';

  @override
  String get accountDelete => 'XÓA TÀI KHOẢN';

  @override
  String get accountDeleteTitle => 'XÓA TÀI KHOẢN?';

  @override
  String get accountDeleteBody =>
      'Tài khoản, hồ sơ, thói quen, gạch và XP sẽ bị xóa vĩnh viễn khỏi máy chủ và thiết bị này. Không thể hoàn tác.';

  @override
  String get accountDeleteConfirm => 'XÓA VĨNH VIỄN';

  @override
  String get accountDeleteOffline => 'Cần kết nối internet để xóa tài khoản.';

  @override
  String get accountCancel => 'HỦY';

  @override
  String get statsTierCommon => 'THƯỜNG';

  @override
  String get statsTierRare => 'HIẾM';

  @override
  String get statsTierEpic => 'SỬ THI';

  @override
  String get statsTierLegendary => 'HUYỀN THOẠI';

  @override
  String get statsBadgeNewTitle => 'HUY HIỆU MỚI!';

  @override
  String get statsBadgeNewDismiss => 'TUYỆT VỜI';

  @override
  String statsMonthYear(String monthName, int month, int year) {
    return 'THÁNG $month $year';
  }

  @override
  String get statsTitle => 'PHÂN TÍCH THÓI QUEN';

  @override
  String get statsLoadError => 'Không tải được phân tích';

  @override
  String get statsRangeWeek => 'Tuần';

  @override
  String get statsRangeMonth => 'Tháng';

  @override
  String get statsRangeYear => 'Năm';

  @override
  String get statsRangeAll => 'Tất cả';

  @override
  String get statsCaptionWeek => '7 NGÀY QUA';

  @override
  String get statsCaptionMonth => '30 NGÀY QUA';

  @override
  String get statsCaptionYear => '365 NGÀY QUA';

  @override
  String get statsCaptionAll => 'TOÀN THỜI GIAN';

  @override
  String get statsWindowWeek => 'KHUNG 7 NGÀY';

  @override
  String get statsWindowMonth => 'KHUNG 30 NGÀY';

  @override
  String get statsWindowYear => 'KHUNG 365 NGÀY';

  @override
  String get statsWindowAll => 'TOÀN THỜI GIAN';

  @override
  String statsSyncLine(String time) {
    return 'ĐỒNG BỘ: HÔM NAY $time';
  }

  @override
  String get statsTileCurrentStreak => 'CHUỖI HIỆN TẠI';

  @override
  String get statsTileBestStreak => 'CHUỖI DÀI NHẤT';

  @override
  String get statsTileRate => 'TỶ LỆ';

  @override
  String get statsTileBlocks => 'KHỐI';

  @override
  String get statsUnitDays => 'NGÀY';

  @override
  String get statsUnitStack => 'CHỒNG';

  @override
  String get statsCaptionStreakAlive => 'Mỗi khối đều giữ chuỗi';

  @override
  String get statsCaptionRecord => 'KỶ LỤC';

  @override
  String statsCaptionHabitDays(int done, int due) {
    return '$done / $due lượt thói quen';
  }

  @override
  String statsCaptionNothingDue(String range) {
    return 'Chưa có việc · $range';
  }

  @override
  String statsCaptionPerfectClears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày hoàn hảo',
    );
    return '$_temp0';
  }

  @override
  String statsDeltaPoints(String value) {
    return '$value ĐIỂM';
  }

  @override
  String statsHeatmapTitle(String month) {
    return 'MA TRẬN HOẠT ĐỘNG // $month';
  }

  @override
  String statsHeatmapEfficiency(int percent) {
    return 'HIỆU SUẤT $percent%';
  }

  @override
  String get statsLegendLess => 'ÍT';

  @override
  String get statsLegendMore => 'NHIỀU';

  @override
  String statsPerfectClear(int days) {
    return 'HOÀN HẢO: $days NGÀY';
  }

  @override
  String get statsPrevMonth => 'Tháng trước';

  @override
  String get statsNextMonth => 'Tháng sau';

  @override
  String statsCellNoneDue(String date) {
    return '$date, không có việc';
  }

  @override
  String statsCellDone(String date, int done, int due) {
    return '$date, hoàn thành $done/$due';
  }

  @override
  String get statsBreakdownTitle => 'CHI TIẾT ĐỘ ĐỀU ĐẶN';

  @override
  String get statsBreakdownEmpty => 'Chưa có thói quen. Tạo bằng nút +.';

  @override
  String statsDaysTargetMet(int met, int due) {
    return '$met / $due ngày đạt mục tiêu';
  }

  @override
  String statsStreak(int days) {
    return 'Chuỗi: $days ngày';
  }

  @override
  String statsStatDone(int count) {
    return '$count LẦN ĐẠT';
  }

  @override
  String statsStatLogged(String duration) {
    return '≥ $duration ĐÃ GHI';
  }

  @override
  String statsDurationHM(int hours, int minutes) {
    return '${hours}g ${minutes}p';
  }

  @override
  String statsDurationM(int minutes) {
    return '${minutes}p';
  }

  @override
  String statsBadgesTitle(int unlocked, int total) {
    return 'HUY HIỆU PIXEL ($unlocked/$total)';
  }

  @override
  String get statsViewAll => 'XEM TẤT CẢ';

  @override
  String get statsBadgesNoXp => 'Huy hiệu chỉ là danh hiệu, không tặng XP.';

  @override
  String get statsBadgeUnlocked => 'ĐÃ MỞ';

  @override
  String get statsBadgeLocked => 'ĐANG KHÓA';

  @override
  String statsBadgeSemantics(String title, String state, String description) {
    return '$title, $state. $description';
  }

  @override
  String get statsBadgeFirstBlockName => 'Khối đầu tiên';

  @override
  String get statsBadgeFirstBlockDesc => 'Đặt khối đầu tiên của bạn';

  @override
  String get statsBadgeBrickLayerName => 'Thợ xây gạch';

  @override
  String get statsBadgeBrickLayerDesc => 'Đặt 25 khối';

  @override
  String get statsBadgeBrickMasterName => 'Bậc thầy gạch';

  @override
  String get statsBadgeBrickMasterDesc => 'Đặt 100 khối';

  @override
  String get statsBadgeWarriorName => 'Chiến binh 7 ngày';

  @override
  String get statsBadgeWarriorDesc => 'Đặt khối 7 ngày liên tiếp';

  @override
  String get statsBadgeLineClearerName => 'Dọn hàng';

  @override
  String get statsBadgeLineClearerDesc => 'Đặt khối 10 ngày liên tiếp';

  @override
  String get statsBadgeLegendName => 'Huyền thoại 30 ngày';

  @override
  String get statsBadgeLegendDesc => 'Đặt khối 30 ngày liên tiếp';

  @override
  String get statsBadgePerfectDayName => 'Ngày hoàn hảo';

  @override
  String get statsBadgePerfectDayDesc =>
      'Hoàn thành mọi thói quen đến hạn trong một ngày';

  @override
  String get statsBadgePerfectWeekName => 'Tuần hoàn hảo';

  @override
  String get statsBadgePerfectWeekDesc => '7 ngày hoàn hảo liên tiếp';

  @override
  String get statsBadgeLevel5Name => 'Cấp 5';

  @override
  String get statsBadgeLevel5Desc => 'Đạt cấp 5';

  @override
  String get statsBadgeLevel10Name => 'Cấp 10';

  @override
  String get statsBadgeLevel10Desc => 'Đạt cấp 10';

  @override
  String statsProgressBlocks(int current, int goal) {
    return 'KHỐI $current / $goal';
  }

  @override
  String statsProgressStreak(int current, int goal) {
    return 'TỐT NHẤT $current / $goal NGÀY';
  }

  @override
  String statsProgressPerfectRun(int current, int goal) {
    return 'TỐT NHẤT $current / $goal NGÀY HOÀN HẢO';
  }

  @override
  String statsProgressBestDay(int done, int due) {
    return 'NGÀY TỐT NHẤT $done / $due THÓI QUEN';
  }

  @override
  String get statsProgressNoHabits => 'CHƯA CÓ VIỆC ĐẾN HẠN';

  @override
  String statsProgressLevel(int current, int goal) {
    return 'CẤP $current / $goal';
  }

  @override
  String get editorNewHabit => 'THÓI QUEN MỚI';

  @override
  String get editorEditHabit => 'SỬA THÓI QUEN';

  @override
  String get editorClose => 'Đóng';

  @override
  String get editorIdentityTag => '01 // DANH TÍNH';

  @override
  String get editorTitleLabel => 'TÊN THÓI QUEN';

  @override
  String editorMaxChars(int count) {
    return 'TỐI ĐA $count KÝ TỰ';
  }

  @override
  String get editorTitleHint => 'Đọc 20 trang sách';

  @override
  String get editorTemplatesLabel => 'GỢI Ý MẪU · CHẠM ĐỂ ĐIỀN SẴN';

  @override
  String get tasksSwipeHint => 'Vuốt sang trái để xóa thói quen';

  @override
  String get editorIconsMore => 'Thêm biểu tượng';

  @override
  String get editorIconsLess => 'Thu gọn biểu tượng';

  @override
  String get detailNotFound => 'Thói quen này không còn tồn tại.';

  @override
  String get editorClearTitle => 'Xóa tên';

  @override
  String get editorIconMatrix => 'CHỌN BIỂU TƯỢNG';

  @override
  String get editorMetaphorTag => '02 // ẨN DỤ';

  @override
  String get editorColorTitle => 'MÀU KHỐI PIXEL';

  @override
  String get editorColorHint => 'Đặt màu khối của thói quen này trên ma trận.';

  @override
  String editorColorSemantics(String hex) {
    return 'Màu $hex';
  }

  @override
  String get editorCadenceTag => '03 // LỊCH';

  @override
  String get editorCadenceTitle => 'LỊCH & MỤC TIÊU';

  @override
  String editorLoop(String cadence) {
    return 'LOOP_$cadence';
  }

  @override
  String get editorDailyQuota => 'CHỈ TIÊU NGÀY';

  @override
  String get editorQuotaDecrease => 'Giảm chỉ tiêu';

  @override
  String get editorQuotaIncrease => 'Tăng chỉ tiêu';

  @override
  String get editorChipPages => 'Trang';

  @override
  String get editorChipMinutes => 'Phút';

  @override
  String get editorChipTimes => 'Lần';

  @override
  String get editorChipGlasses => 'Ly';

  @override
  String get editorChipCheck => 'Đánh dấu';

  @override
  String get editorAlertsTag => '04 // NHẮC';

  @override
  String get editorNotifications => 'THÔNG BÁO';

  @override
  String get editorDailyPrompt => 'Nhắc hằng ngày';

  @override
  String get editorPromptOn => 'Nhắc vào mọi ngày thói quen này đến hạn';

  @override
  String get editorNoReminder => 'Không nhắc';

  @override
  String get editorErrTitleEmpty => 'Nhập tên thói quen';

  @override
  String editorErrTitleLength(int max) {
    return 'Tên phải dài 1-$max ký tự';
  }

  @override
  String get editorErrNoDays => 'Chọn ít nhất một ngày';

  @override
  String get editorErrQuota => 'Chỉ tiêu tối thiểu là 1';

  @override
  String editorSaveFailed(String error) {
    return 'Không thể lưu thói quen: $error';
  }

  @override
  String get editorCreate => 'TẠO THÓI QUEN';

  @override
  String get editorSaveChanges => 'LƯU THAY ĐỔI';

  @override
  String get editorCreateHint => 'Rơi vào ma trận khi bạn đạt chỉ tiêu hôm nay';

  @override
  String get editorEditHint => 'Thay đổi có hiệu lực ngay';

  @override
  String get configTitle => 'CẤU HÌNH';

  @override
  String get configNotifications => 'THÔNG BÁO';

  @override
  String get configChecking => 'ĐANG KIỂM TRA...';

  @override
  String get configAllow => 'CHO PHÉP';

  @override
  String configScheduledCount(int count) {
    return '$count THÓI QUEN';
  }

  @override
  String get configNoReminders =>
      'Chưa có thói quen nào được nhắc. Bật \"Nhắc hằng ngày\" khi tạo hoặc sửa thói quen.';

  @override
  String get configBlocked =>
      'Thông báo đang bị chặn. Hãy bật trong cài đặt hệ thống.';

  @override
  String get configLanguage => 'LANGUAGE / NGÔN NGỮ';

  @override
  String get configLangSystem => 'System / Hệ thống';

  @override
  String reminderBodyChecklist(String name) {
    return '$name — hãy đánh dấu hoàn thành hôm nay';
  }

  @override
  String reminderBodyQuota(String name, int target, String unit) {
    return '$name — $target $unit hôm nay';
  }

  @override
  String reminderBodyQuotaNoUnit(String name, int target) {
    return '$name — $target hôm nay';
  }

  @override
  String gridHudYear(int year) {
    return 'NĂM $year';
  }

  @override
  String gridHudStreak(int days) {
    return 'CHUỖI ${days}N';
  }

  @override
  String gridHudLevel(int level) {
    return 'CẤP $level';
  }

  @override
  String gridHudXp(int xp) {
    return '$xp XP';
  }

  @override
  String gridMatrixTitle(int rows) {
    return 'LƯỚI MA TRẬN • 10x$rows';
  }

  @override
  String gridMatrixCleared(int percent) {
    return '$percent% ĐÃ LẤP';
  }

  @override
  String gridMatrixBase(int row) {
    return 'HÀNG $row (ĐÁY)';
  }

  @override
  String gridMatrixCap(int percent) {
    return '$percent% TỐI ĐA';
  }

  @override
  String gridMatrixError(String error) {
    return 'Lỗi ma trận: $error';
  }

  @override
  String get gridDayNow => 'NAY';

  @override
  String get gridDayYesterday => 'HQ';

  @override
  String gridDayAgo(int days) {
    return '-${days}N';
  }

  @override
  String gridRowsCompleted(int count) {
    return '$count HÀNG XONG HÔM NAY';
  }

  @override
  String gridRowsMultiplier(int xp) {
    return 'THƯỞNG +$xp XP';
  }

  @override
  String get gridHabitsTitle => 'THÓI QUEN HIỆN TẠI';

  @override
  String gridHabitsInProgress(int count) {
    return '$count ĐANG LÀM';
  }

  @override
  String get gridHabitsEmpty =>
      'Chưa có thói quen. Nhấn + để bắt đầu hành trình.';

  @override
  String gridHabitsLoadError(String error) {
    return 'Không tải được thói quen: $error';
  }

  @override
  String get gridHabitRestDay => 'NGÀY NGHỈ';

  @override
  String gridBadgeFocus(String time) {
    return 'TẬP TRUNG $time';
  }

  @override
  String gridBadgeHours(String done, String target) {
    return '$done / $target GIỜ';
  }

  @override
  String gridBadgeAmount(int done, int target, String unit) {
    return '$done / $target $unit';
  }

  @override
  String gridUpdateFailed(String name, String error) {
    return 'Không cập nhật được $name: $error';
  }

  @override
  String gridXpGain(int xp) {
    return '+$xp XP';
  }

  @override
  String get unitGlasses => 'LY';

  @override
  String get unitPages => 'TR';

  @override
  String get unitTimes => 'LẦN';

  @override
  String get unitReps => 'LẦN';

  @override
  String get unitMinutes => 'PHÚT';

  @override
  String get weekdayShortLabels => 'T2 T3 T4 T5 T6 T7 CN';

  @override
  String get cadenceDaily => 'HẰNG NGÀY';

  @override
  String get cadenceWeekdays => 'NGÀY THƯỜNG';

  @override
  String get cadenceCustom => 'TÙY CHỌN';

  @override
  String tasksHeader(int count) {
    return 'NHẬT KÝ NHIỆM VỤ // $count THÓI QUEN';
  }

  @override
  String get tasksEmpty => 'Chưa có thói quen nào. Nhấn + để tạo mới.';

  @override
  String get tasksGoalCheck => 'HOÀN THÀNH';

  @override
  String get tasksDeleteTooltip => 'Xóa';

  @override
  String get tasksDeleteTitle => 'XÓA THÓI QUEN?';

  @override
  String tasksDeleteBody(String name) {
    return '\"$name\" cùng toàn bộ gạch và XP của nó sẽ bị xóa.';
  }

  @override
  String tasksDeleteFailed(String error) {
    return 'Không thể xóa: $error';
  }

  @override
  String get commonCancel => 'HỦY';

  @override
  String get commonNew => 'MỚI';

  @override
  String unlockToastBadges(int count) {
    return '🏅 Bạn vừa mở $count huy hiệu mới! Xem ở Thống kê.';
  }

  @override
  String unlockToastThemes(int count) {
    return '🎨 Bạn vừa mở $count giao diện gạch mới! Xem ở Cấu hình → Kho.';
  }

  @override
  String get commonDelete => 'XÓA';

  @override
  String get commonRetry => 'THỬ LẠI';

  @override
  String get commonSave => 'LƯU';

  @override
  String commonError(String message) {
    return 'Lỗi: $message';
  }

  @override
  String get navMatrix => 'Ma trận';

  @override
  String get navTasks => 'Nhiệm vụ';

  @override
  String get navStats => 'Thống kê';

  @override
  String get navConfig => 'Cài đặt';

  @override
  String get titleGridView => 'Thói quen';

  @override
  String get titleTasks => 'Nhiệm vụ';

  @override
  String get titleStats => 'Thống kê';

  @override
  String get titleConfig => 'Cài đặt';

  @override
  String get onboardingSkip => 'BỎ QUA';

  @override
  String get onboardingNext => 'TIẾP';

  @override
  String get onboardingStart => 'BẮT ĐẦU';

  @override
  String get onboardingWelcomeTitle => 'Xây thói quen, từng pixel một';

  @override
  String get onboardingWelcomeBody =>
      'Thêm thói quen bạn muốn duy trì và check-in mỗi ngày.';

  @override
  String get onboardingMatrixTitle => 'Mỗi lần check-in thả một viên gạch';

  @override
  String get onboardingMatrixBody =>
      'Lấp đầy một hàng để xoá hàng và nhận thêm XP.';

  @override
  String get onboardingRewardsTitle => 'Lên cấp, mở khoá phần thưởng';

  @override
  String get onboardingRewardsBody =>
      'Nhận huy hiệu, mở khoá skin gạch và gói âm thanh trong Locker.';

  @override
  String get onboardingRemindersTitle => 'Không bỏ lỡ ngày nào';

  @override
  String get onboardingRemindersBody =>
      'Bật nhắc nhở để ứng dụng nhắc bạn đúng giờ.';

  @override
  String get onboardingEnableReminders => 'BẬT NHẮC NHỞ';

  @override
  String get onboardingRemindersOn => 'Đã bật nhắc nhở';

  @override
  String get onboardingRemindersDenied => 'Bạn có thể bật sau trong Cài đặt';

  @override
  String get configFeedbackTitle => 'Góp ý & hỗ trợ';

  @override
  String get configFeedbackBody =>
      'Gặp lỗi hoặc có ý tưởng? Hãy cho chúng tôi biết!';

  @override
  String get configFeedbackSend => 'GỬI GÓP Ý';

  @override
  String get configReplayIntro => 'XEM LẠI HƯỚNG DẪN';

  @override
  String configAppVersion(String version, String build) {
    return 'Phiên bản $version ($build)';
  }

  @override
  String feedbackNoMailApp(String email) {
    return 'Không tìm thấy ứng dụng email. Hãy gửi tới $email';
  }

  @override
  String get feedbackCopy => 'SAO CHÉP';

  @override
  String get feedbackEmailSubject => 'Góp ý';

  @override
  String get feedbackEmailHint => 'Mô tả lỗi hoặc ý tưởng tại đây:';
}
