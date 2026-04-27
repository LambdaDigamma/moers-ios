package com.lambdadigamma.events.presentation.favorites

sealed class FavoriteEventsIntent {
    object GetEvents : FavoriteEventsIntent()

    data class EventClicked(val id: Int) : FavoriteEventsIntent()

    data object ShowFilters : FavoriteEventsIntent()

    data object HideFilters : FavoriteEventsIntent()

    data class ToggleVenueFilter(val venueId: Long) : FavoriteEventsIntent()

    data object ClearFilter : FavoriteEventsIntent()
}
