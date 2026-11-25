package com.pixelquest.pixel_quest.widget

import androidx.compose.ui.graphics.Color

/** Flat palette per equipped skin (id = Dart `CosmeticId.name`); unknown ids use neon. */
data class WidgetSkin(
    val background: Color,
    val text: Color,
    val muted: Color,
    val emptyCell: Color,
    val accent: Color,
    val accent2: Color,
    val gameBoy: Boolean = false,
) {
    /** Habit color as this skin shows it (Game Boy quantizes to its four greens). */
    fun habitColor(hex: String): Color {
        val c = parseColor(hex)
        if (!gameBoy) return c
        val l = luminance(c)
        return when {
            l < 0.37 -> hex("0F380F")
            l < 0.45 -> hex("306230")
            l < 0.56 -> hex("8BAC0F")
            else -> hex("9BBC0F")
        }
    }

    companion object {
        private fun hex(h: String) = Color(0xFF000000L or h.toLong(16))
        private fun alpha(h: String, a: Float) = hex(h).copy(alpha = a)

        private val neon = WidgetSkin(hex("0F1015"), hex("E8EAF0"), hex("8B90A0"), hex("1D1F27"), hex("2DE38E"), hex("F9CA24"))

        fun of(id: String?): WidgetSkin = when (id) {
            "gameBoy" -> WidgetSkin(hex("9BBC0F"), hex("0F380F"), hex("306230"), alpha("306230", 0.22f), hex("0F380F"), hex("0F380F"), true)
            "cyberpunk" -> WidgetSkin(hex("120920"), hex("F3E9FF"), hex("9C8FB8"), hex("1B1430"), hex("00F0FF"), hex("FF2BD6"))
            "gemstone" -> WidgetSkin(hex("121830"), hex("EAF0FF"), hex("8C97BD"), hex("1B2442"), hex("7FD8FF"), hex("FFB4E6"))
            "pureGold" -> WidgetSkin(hex("100C08"), hex("FFF1C2"), hex("B39B5E"), alpha("E6B422", 0.2f), hex("F5C84B"), hex("F5C84B"))
            "nebula" -> WidgetSkin(hex("100A38"), hex("ECE6FF"), hex("9A8FD0"), hex("1A1240"), hex("B9A6FF"), hex("FFD6F5"))
            else -> neon
        }

        /** Accepts "RRGGBB", "#RRGGBB", "AARRGGBB"; malformed values fall back to mint. */
        fun parseColor(value: String): Color {
            val h = value.trim().removePrefix("#")
            val rgb = if (h.length == 6 || h.length == 8) h.takeLast(6).toLongOrNull(16) else null
            return Color(0xFF000000L or (rgb ?: 0x2DE38EL))
        }

        /** WCAG relative luminance, matching Flutter's computeLuminance. */
        fun luminance(c: Color): Double {
            fun lin(v: Float): Double = if (v <= 0.03928f) v / 12.92 else Math.pow((v + 0.055) / 1.055, 2.4)
            return 0.2126 * lin(c.red) + 0.7152 * lin(c.green) + 0.0722 * lin(c.blue)
        }
    }
}
