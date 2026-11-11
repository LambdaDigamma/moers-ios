package com.lambdadigamma.rubbish.notifications

import android.Manifest
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.platform.LocalContext

/**
 * Returns a function that turns on rubbish reminders. On Android 13 and newer it asks for the
 * notification permission first and calls [onDenied] when it is not granted.
 */
@Composable
fun rememberEnableReminders(onEnable: () -> Unit, onDenied: () -> Unit): () -> Unit {
    val context = LocalContext.current
    val currentOnEnable by rememberUpdatedState(onEnable)
    val currentOnDenied by rememberUpdatedState(onDenied)
    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        if (granted) currentOnEnable() else currentOnDenied()
    }
    return {
        if (RubbishScheduleNotificationWorker.canPostNotifications(context)) {
            currentOnEnable()
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            launcher.launch(Manifest.permission.POST_NOTIFICATIONS)
        }
    }
}
