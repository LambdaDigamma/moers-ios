package com.lambdadigamma.events.presentation.timetable

sealed class TimetableIntent {
    object GetEvents : TimetableIntent()
    object RefreshEvents : TimetableIntent()

    data class SelectedSection(val section: Int) : TimetableIntent()

    data class EventClicked(val id: Int) : TimetableIntent()

    data object ShowFilters : TimetableIntent()

    data object HideFilters : TimetableIntent()

    data object ClearFilter : TimetableIntent()

    data object ToggleFavoriteFilter : TimetableIntent()

    data class ToggleVenueFilter(val venueId: Long) : TimetableIntent()

    data object SelectAllVenues : TimetableIntent()

    data object DeselectAllVenues : TimetableIntent()
}
