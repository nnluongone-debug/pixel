package com.pixelquest.pixel_quest.widget

import android.content.Context
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceTheme
import androidx.glance.LocalSize
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.state.GlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import java.time.LocalDate

/** Reads the app's JSON snapshot from the shared prefs and picks a layout by size. */
class PixelQuestGlanceWidget : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*> = HomeWidgetGlanceStateDefinition()
    override val sizeMode = SizeMode.Responsive(setOf(SMALL, MEDIUM))

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val prefs = currentState<HomeWidgetGlanceState>().preferences
            val raw = WidgetSnapshot.parse(prefs.getString(WidgetSnapshot.PREF_KEY, null))
            // Evaluated at render time so a stale snapshot shows the current day.
            val snapshot = raw?.rolledTo(LocalDate.now().toString())
            val skin = WidgetSkin.of(snapshot?.skin)
            val strings = WidgetStrings(snapshot?.lang)
            GlanceTheme {
                when {
                    snapshot == null -> EmptyWidgetContent(skin, strings, hasSnapshot = false)
                    snapshot.habits.isEmpty() -> EmptyWidgetContent(skin, strings, hasSnapshot = true)
                    LocalSize.current.width >= MEDIUM.width -> MediumWidgetContent(snapshot, skin, strings)
                    else -> SmallWidgetContent(snapshot, skin, strings)
                }
            }
        }
    }

    private companion object {
        val SMALL = DpSize(110.dp, 110.dp)
        val MEDIUM = DpSize(250.dp, 110.dp)
    }
}
