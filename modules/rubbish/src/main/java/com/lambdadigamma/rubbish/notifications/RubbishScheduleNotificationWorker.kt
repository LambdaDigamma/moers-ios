package com.lambdadigamma.rubbish.notifications

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.work.Data
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.RubbishWasteType
import com.lambdadigamma.rubbish.labelRes

/**
 * Posts the reminder for the waste types that are collected on the next day.
 */
class RubbishScheduleNotificationWorker(
    context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    override fun doWork(): Result {
        val types = inputData.getStringArray(WORKER_DATA_RUBBISH_TYPES_KEY).orEmpty()
            .mapNotNull { RubbishWasteType.fromString(it) }
        if (types.isEmpty()) return Result.failure()
        if (!canPostNotifications(applicationContext)) return Result.success()

        val names = types.joinToString(", ") { applicationContext.getString(it.labelRes()) }
        val openApp = applicationContext.packageManager
            .getLaunchIntentForPackage(applicationContext.packageName)
            ?.let { intent ->
                PendingIntent.getActivity(
                    applicationContext,
                    0,
                    intent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                )
            }

        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_baseline_recycling_24)
            .setContentTitle(applicationContext.getString(R.string.rubbish_notification_title))
            .setContentText(applicationContext.getString(R.string.notification_rubbish_content, names))
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setContentIntent(openApp)
            .setAutoCancel(true)
            .build()

        try {
            NotificationManagerCompat.from(applicationContext).notify(NOTIFICATION_ID, notification)
        } catch (_: SecurityException) {
            // The permission was revoked after the check.
        }
        return Result.success()
    }

    companion object {

        fun inputData(types: List<RubbishWasteType>): Data = Data.Builder()
            .putStringArray(WORKER_DATA_RUBBISH_TYPES_KEY, types.map { it.value }.toTypedArray())
            .build()

        fun canPostNotifications(context: Context): Boolean =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED

        const val TAG = "rubbish_schedule_notification"
        const val CHANNEL_ID = "rubbish-schedule"
        private const val NOTIFICATION_ID = 4_721
        private const val WORKER_DATA_RUBBISH_TYPES_KEY = "rubbishTypes"

    }

}
