package com.lambdadigamma.events.models

import java.text.Normalizer
import java.time.DayOfWeek
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.TemporalAdjusters
import java.util.Locale

enum class EventDateFilter { ALL, TODAY, TOMORROW, WEEKEND, NEXT_7_DAYS }

enum class EventSectionKind { TODAY, TOMORROW, UPCOMING, LATER }

data class EventFilter(
    val date: EventDateFilter = EventDateFilter.ALL,
    val onlineOnly: Boolean = false,
    val query: String = "",
) {
    val isActive: Boolean
        get() = date != EventDateFilter.ALL || onlineOnly || query.isNotBlank()
}

data class EventSection(val kind: EventSectionKind, val events: List<Event>)

/** Filters, groups and orders events relative to the current time. */
class EventListBuilder(
    private val now: Instant,
    private val zone: ZoneId,
) {

    private val today: LocalDate = now.atZone(zone).toLocalDate()

    fun sections(events: List<Event>, filter: EventFilter): List<EventSection> {
        return events
            .filter { isUpcoming(it) && matches(it, filter) }
            .sortedWith(compareBy(nullsLast()) { it.startDate })
            .groupBy { sectionKind(it) }
            .toSortedMap()
            .map { (kind, sectionEvents) -> EventSection(kind, sectionEvents) }
    }

    /** Upcoming events with an image in the next two weeks, for the spotlight carousel. */
    fun spotlight(events: List<Event>, limit: Int = 8): List<Event> {
        val horizon = today.plusDays(SPOTLIGHT_DAYS)
        return events
            .filter { event ->
                event.imageUrl != null && !event.isCancelled && isUpcoming(event) &&
                    effectiveDay(event)?.let { it < horizon } == true
            }
            .sortedBy { it.startDate }
            .take(limit)
    }

    /** True while the event has not ended yet. */
    fun isUpcoming(event: Event): Boolean {
        val end = effectiveEnd(event) ?: return true
        return end >= now.toEpochMilli()
    }

    /** True while the event is taking place. */
    fun isLive(event: Event): Boolean {
        val start = event.startDate ?: return false
        if (!event.showsTime) return false
        val end = effectiveEnd(event) ?: return false
        return now.toEpochMilli() in start..end
    }

    fun matches(event: Event, filter: EventFilter): Boolean {
        if (filter.onlineOnly && !event.isOnline) return false
        if (!matchesDate(event, filter.date)) return false
        return matchesQuery(event, filter.query)
    }

    private fun matchesDate(event: Event, filter: EventDateFilter): Boolean {
        val range = when (filter) {
            EventDateFilter.ALL -> return true
            EventDateFilter.TODAY -> today to today.plusDays(1)
            EventDateFilter.TOMORROW -> today.plusDays(1) to today.plusDays(2)
            EventDateFilter.NEXT_7_DAYS -> today to today.plusDays(7)
            EventDateFilter.WEEKEND -> {
                val saturday = if (today.dayOfWeek == DayOfWeek.SUNDAY) {
                    today.minusDays(1)
                } else {
                    today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SATURDAY))
                }
                maxOf(today, saturday) to saturday.plusDays(2)
            }
        }
        val start = event.startDate ?: return false
        val rangeStart = range.first.atStartOfDay(zone).toInstant().toEpochMilli()
        val rangeEnd = range.second.atStartOfDay(zone).toInstant().toEpochMilli()
        val end = effectiveEnd(event) ?: start
        return start < rangeEnd && end >= rangeStart
    }

    private fun matchesQuery(event: Event, query: String): Boolean {
        val terms = normalize(query).split(' ').filter { it.isNotBlank() }
        if (terms.isEmpty()) return true
        val haystack = normalize(
            listOfNotNull(
                event.name,
                event.locationName,
                event.organizerName,
                event.category,
                event.street,
            ).joinToString(" ")
        )
        return terms.all { haystack.contains(it) }
    }

    private fun sectionKind(event: Event): EventSectionKind {
        val day = effectiveDay(event) ?: return EventSectionKind.LATER
        return when {
            day <= today -> EventSectionKind.TODAY
            day == today.plusDays(1) -> EventSectionKind.TOMORROW
            day < today.plusDays(UPCOMING_DAYS) -> EventSectionKind.UPCOMING
            else -> EventSectionKind.LATER
        }
    }

    /** The day an upcoming event is listed under. Running events count as today. */
    private fun effectiveDay(event: Event): LocalDate? {
        val start = event.startDate ?: return null
        val startDay = Instant.ofEpochMilli(start).atZone(zone).toLocalDate()
        return maxOf(startDay, today)
    }

    private fun effectiveEnd(event: Event): Long? {
        event.endDate?.let { return it }
        val start = event.startDate ?: return null
        return if (event.showsTime) {
            start + UNKNOWN_DURATION_MILLIS
        } else {
            Instant.ofEpochMilli(start).atZone(zone).toLocalDate()
                .plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli() - 1
        }
    }

    private fun normalize(value: String): String =
        Normalizer.normalize(value.lowercase(Locale.GERMAN), Normalizer.Form.NFD)
            .replace(DIACRITICS, "")
            .replace("ß", "ss")

    companion object {
        private const val SPOTLIGHT_DAYS = 14L
        private const val UPCOMING_DAYS = 7L
        /** Events without an end stay listed for this long after they start. */
        private const val UNKNOWN_DURATION_MILLIS = 2 * 60 * 60 * 1000L
        private val DIACRITICS = "\\p{Mn}+".toRegex()
    }
}
