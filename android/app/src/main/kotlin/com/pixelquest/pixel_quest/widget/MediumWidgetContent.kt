package com.pixelquest.pixel_quest.widget

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

private const val MAX_ROWS = 3

/** 4x2: 7-day skyline and flow % on the left, up to 3 tappable due habits on the right. */
@Composable
fun MediumWidgetContent(snapshot: WidgetSnapshot, skin: WidgetSkin, strings: WidgetStrings) {
    val context = LocalContext.current
    val size = LocalSize.current
    val density = context.resources.displayMetrics.density
    val halfDp = (size.width.value - 28f - 13f) / 2f
    val gridH = (size.height.value - 28f - 70f).coerceAtLeast(20f)
    val bitmap = BlockGridBitmap.render(
        columns = snapshot.skyline.map { it.colors.take(6) },
        rows = 6,
        widthPx = (halfDp * density).toInt(),
        heightPx = (gridH * density).toInt(),
        skin = skin,
        spacingPx = 2f * density,
        radiusPx = 1.5f * density,
        showEmpty = false,
    )
    Row(
        modifier = GlanceModifier.fillMaxSize().background(skin.background).cornerRadius(20.dp).padding(14.dp),
    ) {
        Column(modifier = GlanceModifier.defaultWeight().fillMaxHeight().clickable(openAppAction(context))) {
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                Text(strings.skyline, style = mono(skin.muted, 8))
                Spacer(GlanceModifier.defaultWeight())
                Text(strings.plusBlocks(snapshot.weekBlocks), style = mono(skin.accent, 8, bold = true))
            }
            Row(verticalAlignment = Alignment.Bottom) {
                Text("${snapshot.flowPercent}%", style = mono(skin.text, 22, bold = true))
                Spacer(GlanceModifier.width(4.dp))
                Text(strings.flow, style = mono(skin.accent, 9))
            }
            Image(ImageProvider(bitmap), contentDescription = null, modifier = GlanceModifier.size(halfDp.dp, gridH.dp))
            Text(strings.activeStreak(snapshot.streak), style = mono(skin.muted, 8, bold = true), maxLines = 1)
        }
        Box(modifier = GlanceModifier.width(1.dp).fillMaxHeight().background(skin.muted.copy(alpha = 0.3f))) {}
        Spacer(GlanceModifier.width(12.dp))
        FastStack(snapshot, skin, strings, modifier = GlanceModifier.defaultWeight().fillMaxHeight())
    }
}

@Composable
private fun FastStack(snapshot: WidgetSnapshot, skin: WidgetSkin, strings: WidgetStrings, modifier: GlanceModifier) {
    val context = LocalContext.current
    // Not-done habits first, like the iOS widget.
    val due = snapshot.dueHabits.sortedBy { it.done }.take(MAX_ROWS)
    Column(modifier = modifier) {
        Text(strings.tapToStack, style = mono(skin.muted, 8))
        due.forEach { h ->
            val color = skin.habitColor(h.colorHex)
            Spacer(GlanceModifier.height(4.dp))
            Row(
                modifier = GlanceModifier.fillMaxWidth().background(color.copy(alpha = 0.14f)).cornerRadius(8.dp)
                    .padding(horizontal = 7.dp, vertical = 4.dp).clickable(
                        // Timers need the in-app timer, so they just open the app.
                        if (h.type == "timer") openAppAction(context) else checkInAction(context, h.id, snapshot.today),
                    ),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(modifier = GlanceModifier.defaultWeight()) {
                    Text(h.name, style = mono(skin.text, 9, bold = true), maxLines = 1)
                    Text("${h.progress}/${h.target}${if (h.unit.isEmpty()) "" else " ${h.unit}"}", style = mono(color, 7), maxLines = 1)
                }
                Text(if (h.done) "✓" else "+", style = mono(if (h.done) color else skin.muted, 14, bold = true))
            }
        }
        Spacer(GlanceModifier.defaultWeight())
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            Text(strings.goal(snapshot.todayDone, snapshot.todayTotal), style = mono(skin.muted, 7, bold = true))
            Spacer(GlanceModifier.defaultWeight())
            Text(strings.remaining(maxOf(snapshot.todayTotal - snapshot.todayDone, 0)), style = mono(skin.muted, 7, bold = true))
        }
    }
}
