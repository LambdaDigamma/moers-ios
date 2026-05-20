package com.lambdadigamma.events.presentation.search

data class EventSearchFailed(
    val throwable: Throwable,
) : EventSearchPartialState
