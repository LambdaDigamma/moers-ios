package com.lambdadigamma.events.presentation.favorites

sealed class FavoriteEventsIntent {
    object GetEvents : FavoriteEventsIntent()

    data class SelectedSection(val section: Int) : FavoriteEventsIntent()

    data class EventClicked(val id: Int) : FavoriteEventsIntent()
}
