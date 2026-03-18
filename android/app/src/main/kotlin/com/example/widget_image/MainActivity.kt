package com.example.widget_image

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "motivation_widget/update"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getActiveWidgetIds" -> {
                        val manager = AppWidgetManager.getInstance(this)
                        val component = ComponentName(this, MotivationalWidget::class.java)
                        val ids = manager.getAppWidgetIds(component)
                        result.success(ids.toList()) 
                    }
                    "updateWidget" -> {
                        updateWidget() // <--- You MUST call this here
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
    

    // Inside MainActivity.kt
    private fun updateWidget() {
        val intent = Intent(this, MotivationalWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val ids = AppWidgetManager.getInstance(applicationContext)
                .getAppWidgetIds(ComponentName(applicationContext, MotivationalWidget::class.java))
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        sendBroadcast(intent)
    }
}