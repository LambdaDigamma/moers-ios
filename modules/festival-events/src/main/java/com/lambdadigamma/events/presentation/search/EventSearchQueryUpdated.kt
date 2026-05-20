package com.lambdadigamma.events.presentation.search

data class EventSearchQueryUpdated(
    val query: String,
) : EventSearchPartialState
