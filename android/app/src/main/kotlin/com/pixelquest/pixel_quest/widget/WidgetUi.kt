package com.pixelquest.pixel_quest.widget

import android.content.Context
import android.net.Uri
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp
import androidx.glance.action.Action
import androidx.glance.text.FontFamily
import androidx.glance.text.FontWeight
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.pixelquest.pixel_quest.MainActivity
import es.antonborri.home_widget.actionStartActivity

private const val OPEN_URI = "pixelquest://open?homeWidget"

/** Monospace text style used across the widget (mirrors the iOS `Neo.mono`). */
fun mono(color: Color, size: TextUnit, bold: Boolean = false) = TextStyle(
    color = ColorProvider(color),
    fontSize = size,
    fontWeight = if (bold) FontWeight.Bold else FontWeight.Normal,
    fontFamily = FontFamily.Monospace,
)

fun mono(color: Color, sizeSp: Int, bold: Boolean = false) = mono(color, sizeSp.sp, bold)

/** Tap action that opens the app (explicit intent, handled by the Dart deep link handler). */
fun openAppAction(context: Context): Action =
    actionStartActivity<MainActivity>(context, Uri.parse(OPEN_URI))

/**
 * Tap action that checks a habit in via `pixelquest://checkin?habit=<id>&day=<today>`.
 * The day guards against a persisted launch intent replaying on another day.
 */
fun checkInAction(context: Context, habitId: String, day: String): Action =
    actionStartActivity<MainActivity>(
        context,
        Uri.Builder().scheme("pixelquest").authority("checkin")
            .appendQueryParameter("habit", habitId).appendQueryParameter("day", day).build(),
    )
