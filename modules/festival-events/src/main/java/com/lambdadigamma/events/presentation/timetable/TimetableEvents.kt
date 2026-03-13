package com.lambdadigamma.events.presentation.timetable

sealed class TimetableEvents {
    data class ShowEvent(val id: Int) : TimetableEvents()
}
