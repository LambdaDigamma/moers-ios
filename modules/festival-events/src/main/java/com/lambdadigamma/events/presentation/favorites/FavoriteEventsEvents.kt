package com.lambdadigamma.events.presentation.favorites

sealed class FavoriteEventsEvents {
    data class ShowEvent(val id: Int) : FavoriteEventsEvents()
}
