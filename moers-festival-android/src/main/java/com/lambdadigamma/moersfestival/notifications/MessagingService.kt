package com.lambdadigamma.moersfestival.notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.TaskStackBuilder
import androidx.core.net.toUri
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.lambdadigamma.moersfestival.MainActivity
import com.lambdadigamma.moersfestival.R
import timber.log.Timber

class MessagingService: FirebaseMessagingService() {

    private val TAG = "FcmService"
    private val channelId: String = "default_channel"

    override fun onCreate() {
        super.onCreate()
        createNotificationsChannels()

    }

    private fun initNotification(
        channel: String,
        title: String?,
        body: String?
    ): NotificationCompat.Builder {
        return NotificationCompat.Builder(this, channel)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_RECOMMENDATION)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setSound(Settings.System.DEFAULT_NOTIFICATION_URI)
            .setSmallIcon(R.mipmap.ic_launcher)
    }

    private fun createNotification(remoteMessage: RemoteMessage) {

        val receivedNotification = remoteMessage.notification ?: return

        val id = 0 + (Math.random() * 2147483647).toInt()

        val title = receivedNotification.title
        val body = receivedNotification.body
        val url = receivedNotification.link
        val actionName = receivedNotification.clickAction

        Timber.i("Received notification: $title, $body, ${url.toString()}, $actionName")

    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        Timber.tag(TAG).d("Received message from: %s", remoteMessage.from)

        Timber.i("Message received: $remoteMessage")
        Timber.i(remoteMessage.data.toString())

        val link = remoteMessage.data["deep_link"]?.toUri()

        remoteMessage.notification?.let { notification ->
            if (notification.title != null && notification.body != null) {
                sendTestNotification(
                    title = notification.title!!,
                    body = notification.body!!,
                    link = link
                )
            }
        }


    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)

        Timber.i("New token: $token")
        Timber.tag(TAG).d("Refreshed token: %s", token)

        val previousToken = applicationContext
            .getSharedPreferences("_", MODE_PRIVATE)
            .getString("fb", "empty")

        // We check if we have a current token in the store.
        if (previousToken !== token) {
            // Installing a new token in the storage

            getSharedPreferences("_", MODE_PRIVATE)
                .edit()
                .putString("fb", token)
                .apply()

        }

    }

    // MARK: - Helper -

    private fun createNotificationsChannels() {
        Timber.tag(TAG).d("Creating a notification channel for the app.")

        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name: CharSequence = getString(R.string.default_notification_channel_name)
            val description = getString(R.string.default_notification_channel_description)
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(
                channelId,
                name,
                importance
            )
            channel.description = description
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            val notificationManager = getSystemService(
                NotificationManager::class.java
            )
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(
        title: String,
        body: String,
        contentIntent: PendingIntent
    ): NotificationCompat.Builder {

        return NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_stat_ic_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            // Set the intent that fires when the user taps the notification.
            .setContentIntent(contentIntent)
            .setAutoCancel(true)

    }

    private fun sendTestNotification(
        title: String,
        body: String,
        link: Uri?
    ) {

        val id = 0 + (Math.random() * 2147483647).toInt()
        val intent = getIntent(link = link)

        val pending: PendingIntent? = TaskStackBuilder.create(this).run {
            addNextIntentWithParentStack(intent)
            getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        if (pending == null) {
            Timber.e("Pending intent is null.")
            return
        }

//        val intent = Intent(this, LauncherActivity::class.java).apply {
//            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
//        }
//        val pendingIntent: PendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
//
//        TaskStackBuilder.create(this).run {
//            addNextIntent()
//        }

//        val taskDetailIntent = Intent(
//            Intent.ACTION_VIEW,
//            "https://example.com/task_id=${task.id}".toUri()
//        )
//
//        val pending: PendingIntent = TaskStackBuilder.create(context).run {
//            addNextIntentWithParentStack(taskDetailIntent)
//            getPendingIntent(REQUEST_CODE, PendingIntent.FLAG_UPDATE_CURRENT)
//        }

        val builder = buildNotification(
            title = title,
            body = body,
            contentIntent = pending,
        )

        with(NotificationManagerCompat.from(this)) {
            if (ActivityCompat.checkSelfPermission(
                    this@MessagingService,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                // TODO: Consider calling
                // ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                // public fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>,
                //                                        grantResults: IntArray)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.

                return@with
            }
            // notificationId is a unique int for each notification that you must define.
            notify(id, builder.build())
        }
    }

    private fun getIntent(link: Uri?): Intent {

        if (link == null) {
            return Intent(this, MainActivity::class.java)
        }

        return Intent(
            Intent.ACTION_VIEW,
            link
        )

    }

}