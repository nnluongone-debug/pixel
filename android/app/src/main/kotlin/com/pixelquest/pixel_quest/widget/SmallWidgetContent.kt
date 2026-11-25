package com.pixelquest.pixel_quest.widget

import android.graphics.Bitmap
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
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.Text

private const val GRID = 5

/** 2x2: header, 5x5 micro matrix, done/total and streak. Tapping anywhere opens the app. */
@Composable
fun SmallWidgetContent(snapshot: WidgetSnapshot, skin: WidgetSkin, strings: WidgetStrings) {
    val context = LocalContext.current
    val size = LocalSize.current
    val density = context.resources.displayMetrics.density
    // Square grid in the space left after padding and the header/footer rows.
    val gridDp = minOf(size.width.value - 28f, size.height.value - 28f - 34f).coerceAtLeast(20f)
    val bitmap: Bitmap = BlockGridBitmap.render(
        columns = snapshot.tower.takeLast(GRID).map { it.colors.take(GRID) },
        rows = GRID,
        widthPx = (gridDp * density).toInt(),
        heightPx = (gridDp * density).toInt(),
        skin = skin,
        spacingPx = 3f * density,
        radiusPx = 3f * density,
        showEmpty = true,
    )
    Column(
        modifier = GlanceModifier.fillMaxSize().background(skin.background).cornerRadius(20.dp)
            .padding(14.dp).clickable(openAppAction(context)),
    ) {
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text("PixelQuest", style = mono(skin.text, 9, bold = true))
            Spacer(GlanceModifier.defaultWeight())
            Text(strings.today, style = mono(skin.accent, 7, bold = true))
        }
        Spacer(GlanceModifier.height(4.dp))
        Row(modifier = GlanceModifier.fillMaxWidth().defaultWeight(), horizontalAlignment = Alignment.CenterHorizontally) {
            Image(ImageProvider(bitmap), contentDescription = null, modifier = GlanceModifier.size(gridDp.dp))
        }
        Spacer(GlanceModifier.height(4.dp))
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(strings.done(snapshot.todayDone, snapshot.todayTotal), style = mono(skin.muted, 8, bold = true))
            Spacer(GlanceModifier.defaultWeight())
            Text(strings.streakShort(snapshot.streak), style = mono(skin.accent2, 8, bold = true))
        }
    }
}
