package com.lambdadigamma.events.domain.festivalday

import java.util.Calendar
import java.util.Date

object FestivalDay {

    fun effectiveDayStart(
        startDate: Date,
        calendar: Calendar = Calendar.getInstance(),
    ): Date {
        val adjustedDate = calendar.clone() as Calendar
        adjustedDate.time = startDate
        adjustedDate.add(Calendar.HOUR_OF_DAY, -FESTIVAL_DAY_BOUNDARY_HOUR)

        return startOfDay(adjustedDate.time, calendar).time
    }

    fun rangeForEffectiveDay(
        effectiveDay: Date,
        calendar: Calendar = Calendar.getInstance(),
    ): Pair<Date, Date> {
        val start = startOfDay(effectiveDay, calendar)
        start.add(Calendar.HOUR_OF_DAY, FESTIVAL_DAY_BOUNDARY_HOUR)

        val end = start.clone() as Calendar
        end.add(Calendar.DAY_OF_YEAR, 1)

        return start.time to end.time
    }

    fun <T> sectionsFor(
        items: List<T>,
        calendar: Calendar = Calendar.getInstance(),
        startDateSelector: (T) -> Date?,
    ): List<FestivalDayItems<T>> {
        val datedItemsByEffectiveDay = mutableMapOf<Long, MutableList<T>>()
        val effectiveDaysByTime = mutableMapOf<Long, Date>()
        val undatedItems = mutableListOf<T>()

        items.forEach { item ->
            val startDate = startDateSelector(item)
            if (startDate == null) {
                undatedItems += item
                return@forEach
            }

            val effectiveDay = effectiveDayStart(startDate, calendar)
            effectiveDaysByTime[effectiveDay.time] = effectiveDay
            datedItemsByEffectiveDay
                .getOrPut(effectiveDay.time) { mutableListOf() }
                .add(item)
        }

        val datedSections = datedItemsByEffectiveDay
            .entries
            .sortedBy { (effectiveDayTime, _) -> effectiveDayTime }
            .map { (effectiveDayTime, sectionItems) ->
                val effectiveDay = requireNotNull(effectiveDaysByTime[effectiveDayTime])
                FestivalDayItems(
                    effectiveDay = effectiveDay,
                    range = rangeForEffectiveDay(effectiveDay, calendar),
                    items = sectionItems.toList(),
                )
            }

        if (undatedItems.isEmpty()) {
            return datedSections
        }

        return datedSections + FestivalDayItems(
            effectiveDay = null,
            range = null,
            items = undatedItems.toList(),
            isUndated = true,
        )
    }

    private fun startOfDay(
        date: Date,
        calendar: Calendar,
    ): Calendar {
        val startOfDay = calendar.clone() as Calendar
        startOfDay.time = date
        startOfDay.set(Calendar.HOUR_OF_DAY, 0)
        startOfDay.set(Calendar.MINUTE, 0)
        startOfDay.set(Calendar.SECOND, 0)
        startOfDay.set(Calendar.MILLISECOND, 0)
        return startOfDay
    }
}
