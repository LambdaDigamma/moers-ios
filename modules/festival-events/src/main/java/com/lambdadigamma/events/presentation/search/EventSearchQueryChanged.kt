package com.lambdadigamma.events.presentation.search

data class EventSearchQueryChanged(
    val query: String,
) : EventSearchIntent
