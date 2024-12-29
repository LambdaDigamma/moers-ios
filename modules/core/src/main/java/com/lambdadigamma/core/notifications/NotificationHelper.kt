package com.lambdadigamma.moers.utils.notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

object NotificationHelper {

    fun createNotificationChannel(
        context: Context,
        importance: Int,
        showBadge: Boolean,
        name: String,
        description: String
    ) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channelId = "${context.packageName}-$name"
            val channel = NotificationChannel(channelId, name, importance)
            channel.description = description
            channel.setShowBadge(showBadge)

            val notificationManager = context.getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)

        }

    }

    /**
     * Creates Notification based on the provided [RubbishWasteType] and notifies the [NotificationManager]
     */
//    fun createNotificationRubbishReminder(context: Context, rubbishWasteType: RubbishWasteType) {
//
//        val notificationId = notificationId(rubbishWasteType)
//        val notificationBuilder = buildNotificationRubbishReminder(context, rubbishWasteType)
//        val notificationManager = NotificationManagerCompat.from(context)
//        notificationManager.notify(notificationId, notificationBuilder.build())
//
//    }

//    private fun buildNotificationRubbishReminder(context: Context, rubbishWasteType: RubbishWasteType): NotificationCompat.Builder {
//
//        val channelId = "${context.packageName}-${context.getString(R.string.notification_channel_rubbish_title)}"
//
//        return NotificationCompat.Builder(context, channelId).apply {
//
//            setSmallIcon(drawableForRubbishWasteType(rubbishWasteType))
//            setContentTitle("Abfuhrkalender")
//            setAutoCancel(false)
//            setContentText(String.format(context.getString(R.string.notification_rubbish_content), localizedRubbishWasteType(rubbishWasteType)))
//            setGroup(context.getString(R.string.notification_channel_rubbish_title))
//
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//                context.getDrawable(drawableForRubbishWasteType(rubbishWasteType)
//                )?.let { drawable ->
//                    setLargeIcon(DrawableToBitmap.drawableToBitmap(drawable))
//                }
//            }
//
//            val intent = Intent(context, TabActivity::class.java).apply {
//                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
//            }
//
//            val pendingIntent = PendingIntent.getActivity(context, 0, intent , 0)
//            setContentIntent(pendingIntent)
//
//        }
//
//    }

//    private fun notificationId(rubbishWasteType: RubbishWasteType) : Int {
//        return System.currentTimeMillis().toInt().and(rubbishWasteType.value.hashCode())
//    }

}
