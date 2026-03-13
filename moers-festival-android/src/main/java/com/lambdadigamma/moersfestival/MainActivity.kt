package com.lambdadigamma.moersfestival

import android.Manifest.permission.POST_NOTIFICATIONS
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.core.content.ContextCompat
import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.core.navigation.NavigationManager
import com.lambdadigamma.moers.utils.notifications.NotificationHelper
import com.lambdadigamma.moersfestival.notifications.MessagingService
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber
import javax.inject.Inject

@OptIn(ExperimentalMaterial3Api::class)
@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var navigationFactories: @JvmSuppressWildcards Set<NavigationFactory>

    @Inject
    lateinit var navigationManager: NavigationManager

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            App(
                navigationManager = navigationManager,
                navigationFactories = navigationFactories,
                finishActivity = { finish() },
                askNotificationPermission = { askNotificationPermission() }
            )
        }

    }

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { isGranted: Boolean ->
        if (isGranted) {
            Timber.i("Notifications: Notification permission granted")
            // FCM SDK (and your app) can post notifications.
        } else {
            Timber.i("Notifications: Notification permission is not granted")
            // TODO: Inform user that that your app will not show notifications.
        }
    }

    private fun askNotificationPermission() {

        // This is only necessary for API level >= 33 (TIRAMISU)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
            ) {
                Timber.i("Notifications: Notification permission is already granted.")
                // FCM SDK (and your app) can post notifications.
            } else if (shouldShowRequestPermissionRationale(POST_NOTIFICATIONS)) {
                Timber.i("Notifications: Notification permission is already granted.")
                // TODO: display an educational UI explaining to the user the features that will be enabled
                //       by them granting the POST_NOTIFICATION permission. This UI should provide the user
                //       "OK" and "No thanks" buttons. If the user selects "OK," directly request the permission.
                //       If the user selects "No thanks," allow the user to continue without notifications.
            } else {
                // Directly ask for the permission
                Timber.i("Notifications: Directly asking for notification permission.")
                requestPermissionLauncher.launch(POST_NOTIFICATIONS)
            }
        } else {

            Timber.i("Notifications: API level < 33, no need to ask for permission.")

        }

        NotificationHelper.createNotificationChannel(
            this.getString(R.string.default_notification_channel_id),
            this,
            4,
            false,
            getString(R.string.notification_channel_default_name),
            getString(R.string.notification_channel_default_description)
        )

    }
}