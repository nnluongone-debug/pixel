import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/services/home_widget_sync_service.dart';

void main() {
  test('midnight refresh is 5s after the next local midnight', () {
    expect(
      HomeWidgetSyncService.midnightRefreshAfter(
        DateTime(2026, 11, 25, 23, 59),
      ),
      DateTime(2026, 11, 26, 0, 0, 5),
    );
  });

  test('midnight refresh rolls over month and year ends', () {
    expect(
      HomeWidgetSyncService.midnightRefreshAfter(DateTime(2026, 12, 31, 8)),
      DateTime(2027, 1, 1, 0, 0, 5),
    );
  });

  test('receiver name is the fully qualified Kotlin class', () {
    expect(
      HomeWidgetConfig.androidReceiver,
      'com.pixelquest.pixel_quest.widget.PixelQuestWidgetReceiver',
    );
  });
}
