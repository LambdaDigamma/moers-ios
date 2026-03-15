package com.lambdadigamma.moersfestival

import android.app.Application
import com.google.firebase.messaging.FirebaseMessaging
import com.lambdadigamma.moersfestival.notifications.MessagingService
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber
import timber.log.Timber.DebugTree

@HiltAndroidApp
class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        if (BuildConfig.DEBUG) {
            Timber.plant(DebugTree())
        }

        FirebaseMessaging.getInstance().token.
                addOnCompleteListener { task ->
                    if (!task.isSuccessful) {
                        Timber.w(task.exception, "Fetching FCM token failed")
                        return@addOnCompleteListener
                    }

                    val token = task.result
                    Timber.d("FCM token: $token")

                }
    }
}
