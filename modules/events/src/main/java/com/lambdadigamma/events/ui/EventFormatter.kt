package com.lambdadigamma.events.ui

import android.text.format.DateFormat
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalConfiguration
import androidx.core.os.ConfigurationCompat
import com.lambdadigamma.events.models.Event
import java.time.Instant
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

/** Locale aware date and time texts for events. */
class EventFormatter(locale: Locale, private val zone: ZoneId = ZoneId.systemDefault()) {

    private val dayFormatter = formatter(locale, "EEEMMMd")
    private val longDayFormatter = formatter(locale, "EEEEMMMMdyyyy")
    private val timeFormatter = formatter(locale, "jm")
    private val weekdayFormatter = formatter(locale, "EEE")
    private val monthFormatter = formatter(locale, "MMM")

    /** For example "Wed, Nov 11 · 10:00 – 11:30" or "Nov 1 – Nov 30". */
    fun shortDate(event: Event): String = format(event, dayFormatter)

    /** For example "Wednesday, November 11, 2026 · 10:00 – 11:30". */
    fun longDate(event: Event): String = format(event, longDayFormatter)

    fun weekday(event: Event): String = event.start()?.format(weekdayFormatter).orEmpty()

    fun dayOfMonth(event: Event): String = event.start()?.dayOfMonth?.toString().orEmpty()

    fun month(event: Event): String = event.start()?.format(monthFormatter).orEmpty()

    private fun format(event: Event, dayFormat: DateTimeFormatter): String {
        val start = event.start() ?: return ""
        val end = event.end()
        val startDay = start.format(dayFormat)
        return when {
            end != null && end.toLocalDate() != start.toLocalDate() ->
                "$startDay – ${end.format(dayFormat)}"
            !event.showsTime -> startDay
            end != null -> "$startDay · ${start.format(timeFormatter)} – ${end.format(timeFormatter)}"
            else -> "$startDay · ${start.format(timeFormatter)}"
        }
    }

    private fun Event.start(): ZonedDateTime? = startDate?.let { Instant.ofEpochMilli(it).atZone(zone) }

    private fun Event.end(): ZonedDateTime? = endDate?.let { Instant.ofEpochMilli(it).atZone(zone) }

    private fun formatter(locale: Locale, skeleton: String): DateTimeFormatter =
        DateTimeFormatter.ofPattern(DateFormat.getBestDateTimePattern(locale, skeleton), locale)
}

@Composable
fun rememberEventFormatter(): EventFormatter {
    val configuration = LocalConfiguration.current
    val locale = ConfigurationCompat.getLocales(configuration)[0] ?: Locale.getDefault()
    return remember(locale) { EventFormatter(locale) }
}
