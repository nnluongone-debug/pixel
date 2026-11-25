package com.pixelquest.pixel_quest

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android redelivers the original launch intent when the task is reopened
        // from Recents. Drop its deep link so a widget check-in cannot replay.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) {
            intent = Intent(intent).apply { data = null }
        }
        super.onCreate(savedInstanceState)
    }
}
