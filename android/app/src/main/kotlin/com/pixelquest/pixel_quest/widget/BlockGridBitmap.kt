package com.pixelquest.pixel_quest.widget

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import androidx.compose.ui.graphics.toArgb

/**
 * Draws stacked block columns (bottom-up) into a bitmap. Glance caps container
 * children at 10, so grids are rendered as one image instead of nested rows.
 */
object BlockGridBitmap {
    /** Keeps the RemoteViews bitmap payload small (the binder limit is ~1 MB). */
    private const val MAX_PX = 400

    fun render(
        columns: List<List<String>>,
        rows: Int,
        widthPx: Int,
        heightPx: Int,
        skin: WidgetSkin,
        spacingPx: Float,
        radiusPx: Float,
        showEmpty: Boolean,
    ): Bitmap {
        val scale = minOf(1f, MAX_PX.toFloat() / maxOf(widthPx, heightPx, 1))
        val w = maxOf(1, (widthPx * scale).toInt())
        val h = maxOf(1, (heightPx * scale).toInt())
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val cols = maxOf(columns.size, 1)
        val gap = spacingPx * scale
        val cell = minOf((w - gap * (cols - 1)) / cols, (h - gap * (rows - 1)) / rows)
        if (cell <= 0f) return bitmap

        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val gridW = cell * cols + gap * (cols - 1)
        val left = (w - gridW) / 2f
        val bottom = h.toFloat()
        val radius = radiusPx * scale
        columns.forEachIndexed { c, colors ->
            for (r in 0 until rows) {
                val color = when {
                    r < colors.size -> skin.habitColor(colors[r])
                    showEmpty -> skin.emptyCell
                    else -> continue
                }
                paint.color = color.toArgb()
                val x = left + c * (cell + gap)
                val y = bottom - (r + 1) * cell - r * gap
                canvas.drawRoundRect(RectF(x, y, x + cell, y + cell), radius, radius, paint)
            }
        }
        return bitmap
    }
}
