package com.lambdadigamma.events.presentation.timetable

sealed class TimetableIntent {
    object GetEvents : TimetableIntent()
    object RefreshEvents : TimetableIntent()

    data class SelectedSection(val section: Int) : TimetableIntent()

    data class EventClicked(val id: Int) : TimetableIntent()
}
