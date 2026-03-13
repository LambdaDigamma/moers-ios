package com.lambdadigamma.moers

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import com.lambdadigamma.core.notifications.NotificationChannelImportance
import com.lambdadigamma.core.notifications.NotificationChannelInformation
import com.lambdadigamma.core.notifications.toAndroidImportance
import com.lambdadigamma.rubbish.notifications.RubbishScheduleNotificationWorker
import dagger.hilt.android.HiltAndroidApp
import com.lambdadigamma.rubbish.R.string as rubbishResources

@HiltAndroidApp
class Application : Application() {

    companion object {

        lateinit var instance: com.lambdadigamma.moers.Application
            private set

        const val sharedPreferencesName = "MMAPI"

    }

    override fun onCreate() {
        super.onCreate()

        instance = this

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            registerNotificationChannels(
                listOf(
                    NotificationChannelInformation(
                        id = RubbishScheduleNotificationWorker.CHANNEL_ID,
                        name = rubbishResources.notification_channel_rubbish_title,
                        description = rubbishResources.notification_channel_rubbish_description,
                        importance = NotificationChannelImportance.HIGH,
                    )
                )
            )
        }

    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun registerNotificationChannels(channels: List<NotificationChannelInformation>) {

        val notificationManager: NotificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        channels.forEach { channel ->

            val name = getString(channel.name)
            val descriptionText = getString(channel.description)
            val importance = channel.importance.toAndroidImportance()

            val notificationChannel = NotificationChannel(channel.id, name, importance).apply {
                description = descriptionText
            }

            notificationManager.createNotificationChannel(notificationChannel)
        }

    }

}
