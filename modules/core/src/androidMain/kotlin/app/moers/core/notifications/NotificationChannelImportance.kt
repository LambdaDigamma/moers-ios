package app.moers.core.notifications

import android.app.NotificationManager
import android.os.Build
import androidx.annotation.RequiresApi

enum class NotificationChannelImportance(val value: Int) {
    DEFAULT(value = 3),
    HIGH(value = 4),
    LOW(value = 2),
    MAX(value = 5),
    MIN(value = 1),
    NONE(value = 0),
}

@RequiresApi(Build.VERSION_CODES.N)
fun NotificationChannelImportance.toAndroidImportance(): Int {
    return when (this) {
        NotificationChannelImportance.DEFAULT -> NotificationManager.IMPORTANCE_DEFAULT
        NotificationChannelImportance.HIGH -> NotificationManager.IMPORTANCE_HIGH
        NotificationChannelImportance.LOW -> NotificationManager.IMPORTANCE_LOW
        NotificationChannelImportance.MAX -> NotificationManager.IMPORTANCE_MAX
        NotificationChannelImportance.MIN -> NotificationManager.IMPORTANCE_MIN
        NotificationChannelImportance.NONE -> NotificationManager.IMPORTANCE_NONE
    }
}