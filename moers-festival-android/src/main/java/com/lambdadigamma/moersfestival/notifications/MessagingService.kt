package com.lambdadigamma.moersfestival.notifications

import android.Manifest
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.TaskStackBuilder
import androidx.core.net.toUri
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.map.domain.usecase.RefreshFestivalMapUseCase
import com.lambdadigamma.moersfestival.MainActivity
import com.lambdadigamma.moersfestival.R
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.runBlocking
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class MessagingService : FirebaseMessagingService() {

    @Inject
    lateinit var notificationManager: FestivalNotificationManager

    @Inject
    lateinit var refreshEventsUseCase: RefreshEventsUseCase

    @Inject
    lateinit var refreshFestivalMapUseCase: RefreshFestivalMapUseCase

    private val tag = "FcmService"
    private val channelId: String = "default_channel"

    override fun onCreate() {
        super.onCreate()
        notificationManager.ensureDefaultNotificationChannel()
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        Timber.tag(tag).d("Received message from: %s", remoteMessage.from)
        Timber.i("Message received: %s", remoteMessage)
        Timber.i("Message data: %s", remoteMessage.data)

        runBlocking {
            handleRefreshContent(remoteMessage.data["refresh_content"])
        }

        val payload = remoteMessage.toNotificationPayload() ?: return

        sendNotification(
            title = payload.title,
            body = payload.body,
            link = payload.link,
        )
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)

        Timber.i("New token: %s", token)
        Timber.tag(tag).d("Refreshed token: %s", token)

        val previousToken = applicationContext
            .getSharedPreferences("_", MODE_PRIVATE)
            .getString("fb", "empty")

        if (previousToken != token) {
            getSharedPreferences("_", MODE_PRIVATE)
                .edit()
                .putString("fb", token)
                .apply()
        }
    }

    private suspend fun handleRefreshContent(refreshContent: String?) {
        when (refreshContent) {
            "events" -> {
                refreshEventsUseCase()
                    .onFailure { throwable ->
                        Timber.w(throwable, "Failed to refresh events after push notification.")
                    }
            }
            "maps" -> {
                refreshFestivalMapUseCase(true)
                    .onFailure { throwable ->
                        Timber.w(throwable, "Failed to refresh map data after push notification.")
                    }
            }
            else -> Unit
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
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .setSound(Settings.System.DEFAULT_NOTIFICATION_URI)
    }

    private fun sendNotification(
        title: String,
        body: String,
        link: Uri?
    ) {

        val id = (Math.random() * 2147483647).toInt()
        val intent = getIntent(link = link)

        val pending: PendingIntent? = TaskStackBuilder.create(this).run {
            addNextIntentWithParentStack(intent)
            getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        if (pending == null) {
            Timber.e("Pending intent is null.")
            return
        }

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
                return@with
            }

            notify(id, builder.build())
        }
    }

    private fun getIntent(link: Uri?): Intent {
        if (link == null) {
            return Intent(this, MainActivity::class.java)
        }

        return Intent(Intent.ACTION_VIEW, link).apply {
            if (link.scheme == "moersfestival") {
                `package` = packageName
            }
        }
    }

    private fun RemoteMessage.toNotificationPayload(): FestivalNotificationPayload? {
        val title = notification?.title ?: data["title"]
        val body = notification?.body ?: data["body"] ?: data["text"]
        val link = data["deep_link"]?.takeIf { it.isNotBlank() }?.toUri() ?: notification?.link

        if (title.isNullOrBlank() || body.isNullOrBlank()) {
            return null
        }

        return FestivalNotificationPayload(
            title = title,
            body = body,
            link = link,
        )
    }

    private data class FestivalNotificationPayload(
        val title: String,
        val body: String,
        val link: Uri?,
    )
}
