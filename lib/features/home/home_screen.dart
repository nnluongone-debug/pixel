import 'package:flutter/material.dart';

import '../habits/widgets/habit_list_view.dart';
import 'widgets/matrix_canvas_card.dart';
import 'widgets/status_hud_card.dart';

/// Matrix tab body: status HUD, the rolling pixel matrix and the habit list.
/// The shell supplies the top bar and floating nav, hence the bottom padding.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: const [
        StatusHudCard(),
        SizedBox(height: 8),
        MatrixCanvasCard(),
        SizedBox(height: 16),
        HabitListView(),
      ],
    );
  }
}
