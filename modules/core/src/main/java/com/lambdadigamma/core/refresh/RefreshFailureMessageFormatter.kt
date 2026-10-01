package com.lambdadigamma.core.refresh

import android.content.Context
import java.text.DateFormat
import java.util.Date
import java.util.Locale

object RefreshFailureMessageFormatter {

    fun format(
        context: Context,
        throwable: Throwable,
        lastSuccessfulRefresh: Date? = null,
    ): String {
        val reason = RefreshFailureClassifier.classify(throwable)

        if (lastSuccessfulRefresh == null) {
            return context.getString(reason.messageResId)
        }

        val formattedLastRefresh = DateFormat
            .getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT, Locale.getDefault())
            .format(lastSuccessfulRefresh)

        return context.getString(reason.messageWithLastUpdateResId, formattedLastRefresh)
    }
}
