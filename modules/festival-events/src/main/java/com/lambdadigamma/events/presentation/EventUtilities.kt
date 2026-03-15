package com.lambdadigamma.events.presentation

import android.icu.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object EventUtilities {

    private const val defaultTimeInterval = 30 * 60 * 1000L

    fun dateRange(startDate: Date?, endDate: Date?): ClosedRange<Date>? {
        startDate?.let { startDate ->
            val endDate = endDate ?: Date(startDate.time + defaultTimeInterval)
            if (endDate < startDate) {
                return startDate..Date(startDate.time + defaultTimeInterval)
            }
            return startDate..endDate
        }

        return null
    }

    fun formatRange(range: ClosedRange<Date>, locale: Locale): String {
        val dateFormatter = SimpleDateFormat("HH:mm", locale)
        val start = dateFormatter.format(range.start)
        val end = dateFormatter.format(range.endInclusive)
        return "$start - $end"
    }

}