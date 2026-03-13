package com.lambdadigamma.core.notifications

import androidx.annotation.StringRes

data class NotificationChannelInformation(
    val id: String,
    @StringRes val name: Int,
    @StringRes val description: Int,
    val importance: NotificationChannelImportance
)