package com.example.widget_image

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import java.io.File
import android.content.Intent
import android.content.ComponentName

class MotivationalWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.motivation_widget)
            
            val baseDir = context.filesDir.parentFile
            val file = if (baseDir != null) {
                File(baseDir, "app_flutter/widget_images/motivation_$id.jpg")
            } else {
                File(context.filesDir, "widget_images/motivation_$id.jpg")
            }

            if (file.exists()) {
                // IMAGE EXISTS: Show Image, Hide Text
                val bitmap = decodeSampledBitmapFromFile(file.absolutePath, 512, 512)
                views.setImageViewBitmap(R.id.imageView, bitmap)
                views.setViewVisibility(R.id.imageView, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.emptyTextView, android.view.View.GONE)
            } else {
                // NO IMAGE: Hide Image, Show Placeholder Text
                views.setViewVisibility(R.id.imageView, android.view.View.GONE)
                views.setViewVisibility(R.id.emptyTextView, android.view.View.VISIBLE)
            }

            manager.updateAppWidget(id, views)
        }
    }


    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        val baseDir = context.filesDir.parentFile
        for (id in appWidgetIds) {
            // MATCH THE PATH USED IN ONUPDATE
            val file = if (baseDir != null) {
                File(baseDir, "app_flutter/widget_images/motivation_$id.jpg")
            } else {
                File(context.filesDir, "widget_images/motivation_$id.jpg")
            }
            
            if (file.exists()) file.delete()
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        // This ensures that when your MethodChannel triggers an update, 
        // the widget actually runs the onUpdate logic immediately.
        if (AppWidgetManager.ACTION_APPWIDGET_UPDATE == intent.action) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, MotivationalWidget::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    // New helper function to prevent memory crashes
    private fun decodeSampledBitmapFromFile(path: String, reqWidth: Int, reqHeight: Int): Bitmap? {
        return BitmapFactory.Options().run {
            // First decode with inJustDecodeBounds=true to check dimensions
            inJustDecodeBounds = true
            BitmapFactory.decodeFile(path, this)

            // Calculate inSampleSize (Power of 2 is best)
            inSampleSize = calculateInSampleSize(this, reqWidth, reqHeight)

            // Decode bitmap with inSampleSize set
            inJustDecodeBounds = false
            BitmapFactory.decodeFile(path, this)
        }
    }

    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val (height: Int, width: Int) = options.run { outHeight to outWidth }
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2
            while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }
}