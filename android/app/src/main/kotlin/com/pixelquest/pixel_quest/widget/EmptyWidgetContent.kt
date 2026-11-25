package com.pixelquest.pixel_quest.widget

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.LocalContext
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle

/** Shown before the first sync (open the app) or when the user has no habits. */
@Composable
fun EmptyWidgetContent(skin: WidgetSkin, strings: WidgetStrings, hasSnapshot: Boolean) {
    val context = LocalContext.current
    Column(
        modifier = GlanceModifier.fillMaxSize().background(skin.background).cornerRadius(20.dp)
            .padding(14.dp).clickable(openAppAction(context)),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            if (hasSnapshot) strings.noHabitsTitle else strings.openAppTitle,
            style = mono(skin.text, 11, bold = true).copy(textAlign = TextAlign.Center),
        )
        Text(
            if (hasSnapshot) strings.noHabitsHint else strings.openAppHint,
            style = mono(skin.muted, 8).copy(textAlign = TextAlign.Center),
        )
    }
}
