package com.lambdadigamma.events.presentation.search

data class EventSearchFetched(
    val sections: List<EventSearchSection>,
) : EventSearchPartialState
