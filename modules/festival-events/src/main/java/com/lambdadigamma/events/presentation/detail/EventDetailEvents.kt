package com.lambdadigamma.events.presentation.detail

sealed class EventDetailEvents {
    data class ShowEvent(val id: Int) : EventDetailEvents()

    data class ToggleEvent(val id: Int) : EventDetailEvents()
}
