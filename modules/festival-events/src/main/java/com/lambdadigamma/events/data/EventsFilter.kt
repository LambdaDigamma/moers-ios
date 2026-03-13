package com.lambdadigamma.events.data

import com.lambdadigamma.core.futureDate
import com.lambdadigamma.events.data.remote.model.Event
import java.util.Calendar
import java.util.Calendar.HOUR_OF_DAY
import java.util.Calendar.MILLISECOND
import java.util.Calendar.MINUTE
import java.util.Calendar.SECOND
import java.util.Date

const val eventActiveMinuteThreshold = 30

fun List<Event>.filterEvents(): List<Event> {

    val current = Date()

    return this
        .sortedBy { it.startDate ?: futureDate() }
        .filter { event ->

            val start = event.startDate
            val end = event.endDate

            if (start != null && end != null) {
                if (start >= current && end >= current) {
                    return@filter true
                } else return@filter current >= start && current <= end
            }
            if (start != null) {

                val calendar = Calendar.getInstance()
                calendar.time = start
                calendar.add(
                    Calendar.MINUTE,
                    eventActiveMinuteThreshold
                )

                return@filter calendar.time >= current

            } else {
                return@filter true
            }

        }

}

fun calculateDateRange(
    date: Date,
    offset: Long,
    calendar: Calendar = Calendar.getInstance()
): Pair<Date, Date> {
    val startOfDay = calendar.clone() as Calendar
    startOfDay.time = date
    startOfDay.set(HOUR_OF_DAY, 0)
    startOfDay.set(MINUTE, 0)
    startOfDay.set(SECOND, 0)
    startOfDay.set(MILLISECOND, 0)

    val startDate = calendar.clone() as Calendar
    startDate.time = startOfDay.time
    startDate.add(SECOND, offset.toInt())

    val endDate = calendar.clone() as Calendar
    endDate.time = startOfDay.time
    endDate.add(SECOND, offset.toInt() + 86400)

    return Pair(startDate.time, endDate.time)
}