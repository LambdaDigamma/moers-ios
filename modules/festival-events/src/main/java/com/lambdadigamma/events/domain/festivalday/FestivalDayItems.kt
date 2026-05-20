package com.lambdadigamma.events.domain.festivalday

import java.util.Date

data class FestivalDayItems<T>(
    val effectiveDay: Date?,
    val range: Pair<Date, Date>?,
    val items: List<T>,
    val isUndated: Boolean = false,
)
