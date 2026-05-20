package com.lambdadigamma.events.presentation.search

import com.lambdadigamma.events.domain.festivalday.FestivalDay
import com.lambdadigamma.events.presentation.EventDisplayable
import java.util.Calendar

object EventSearchSectionBuilder {

    fun build(
        events: List<EventDisplayable>,
        calendar: Calendar = Calendar.getInstance(),
    ): List<EventSearchSection> {
        return FestivalDay
            .sectionsFor(events, calendar, EventDisplayable::startDate)
            .map { section ->
                EventSearchSection(
                    range = section.range,
                    events = section.items,
                    isUndated = section.isUndated,
                )
            }
    }
}
