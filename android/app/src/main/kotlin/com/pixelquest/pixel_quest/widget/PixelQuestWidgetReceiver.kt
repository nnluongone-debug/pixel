package com.pixelquest.pixel_quest.widget

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/** Launcher entry point; the Dart side refers to it by its fully qualified name. */
class PixelQuestWidgetReceiver : HomeWidgetGlanceWidgetReceiver<PixelQuestGlanceWidget>() {
    override val glanceAppWidget = PixelQuestGlanceWidget()
}
