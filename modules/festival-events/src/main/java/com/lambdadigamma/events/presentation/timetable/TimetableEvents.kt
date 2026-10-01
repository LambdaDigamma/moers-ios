package com.lambdadigamma.events.presentation.timetable

import java.util.Date

sealed class TimetableEvents {
    data class ShowEvent(val id: Int) : TimetableEvents()

    data class ShowRefreshError(
        val throwable: Throwable,
        val lastSuccessfulRefresh: Date?,
    ) : TimetableEvents()
}
