package com.lambdadigamma.events.presentation.detail

sealed class EventDetailIntent {
    object GetData : EventDetailIntent()
    object RefreshEvent : EventDetailIntent()

    object ToggleFavorite : EventDetailIntent()

    object GoBack : EventDetailIntent()
}
