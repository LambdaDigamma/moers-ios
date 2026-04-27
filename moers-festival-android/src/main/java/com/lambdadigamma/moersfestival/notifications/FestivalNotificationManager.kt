package com.lambdadigamma.moersfestival.notifications

import android.Manifest.permission.POST_NOTIFICATIONS
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessaging
import com.lambdadigamma.moers.utils.notifications.NotificationHelper
import com.lambdadigamma.moersfestival.R
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.suspendCancellableCoroutine
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume

@Singleton
class FestivalNotificationManager @Inject constructor(
    @param:ApplicationContext private val context: Context,
) {

    fun ensureDefaultNotificationChannel() {
        NotificationHelper.createNotificationChannel(
            channelId = context.getString(R.string.default_notification_channel_id),
            context = context,
            importance = NotificationManager.IMPORTANCE_DEFAULT,
            showBadge = false,
            name = context.getString(R.string.notification_channel_default_name),
            description = context.getString(R.string.notification_channel_default_description),
        )
    }

    fun hasNotificationPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            ContextCompat.checkSelfPermission(context, POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    suspend fun subscribeToGeneralTopic(): Result<Unit> {
        ensureDefaultNotificationChannel()

        return suspendCancellableCoroutine { continuation ->
            FirebaseMessaging.getInstance()
                .subscribeToTopic(GENERAL_TOPIC)
                .addOnCompleteListener { task ->
                    if (!continuation.isActive) {
                        return@addOnCompleteListener
                    }

                    val result = if (task.isSuccessful) {
                        Timber.i("Subscribed to FCM topic %s", GENERAL_TOPIC)
                        Result.success(Unit)
                    } else {
                        Result.failure(task.exception ?: IllegalStateException("Unable to subscribe to FCM topic."))
                    }

                    continuation.resume(result)
                }
        }
    }

    fun openSystemNotificationSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
            }
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", context.packageName, null)
            }
        }

        context.startActivity(
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
    }

    private companion object {
        const val GENERAL_TOPIC = "all"
    }
}
