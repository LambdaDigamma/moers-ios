package com.lambdadigamma.events

import com.lambdadigamma.events.models.Event
import com.lambdadigamma.events.models.EventDateFilter
import com.lambdadigamma.events.models.EventFilter
import com.lambdadigamma.events.models.EventListBuilder
import com.lambdadigamma.events.models.EventSectionKind
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDateTime
import java.time.ZoneId

class EventListBuilderTest {

    private val zone = ZoneId.of("Europe/Berlin")

    // Wednesday, 11 November 2026, 12:00
    private val now = LocalDateTime.of(2026, 11, 11, 12, 0).atZone(zone).toInstant()
    private val builder = EventListBuilder(now, zone)

    private fun at(day: Int, hour: Int, minute: Int = 0): Long =
        LocalDateTime.of(2026, 11, day, hour, minute).atZone(zone).toInstant().toEpochMilli()

    private fun event(id: Int, start: Long?, end: Long? = null, name: String = "Event $id", showsTime: Boolean = true) =
        Event(id = id, name = name, startDate = start, endDate = end, showsTime = showsTime)

    @Test
    fun `groups upcoming events into today, tomorrow, upcoming and later`() {
        val events = listOf(
            event(1, at(11, 18)),
            event(2, at(12, 10)),
            event(3, at(15, 10)),
            event(4, at(30, 10)),
        )

        val sections = builder.sections(events, EventFilter())

        assertEquals(
            listOf(EventSectionKind.TODAY, EventSectionKind.TOMORROW, EventSectionKind.UPCOMING, EventSectionKind.LATER),
            sections.map { it.kind },
        )
        assertEquals(listOf(listOf(1), listOf(2), listOf(3), listOf(4)), sections.map { s -> s.events.map { it.id } })
    }

    @Test
    fun `hides finished events and lists running multi day events as today`() {
        val finished = event(1, at(10, 10), at(10, 12))
        val running = event(2, at(1, 10), at(30, 18))

        val sections = builder.sections(listOf(finished, running), EventFilter())

        assertEquals(listOf(EventSectionKind.TODAY), sections.map { it.kind })
        assertEquals(listOf(2), sections.single().events.map { it.id })
    }

    @Test
    fun `keeps events without end for two hours after their start`() {
        assertTrue(builder.isUpcoming(event(1, at(11, 10, 30))))
        assertFalse(builder.isUpcoming(event(2, at(11, 9, 30))))
    }

    @Test
    fun `all day events stay listed until the end of their day`() {
        assertTrue(builder.isUpcoming(event(1, at(11, 0), showsTime = false)))
    }

    @Test
    fun `weekend filter matches saturday and sunday`() {
        val events = listOf(event(1, at(13, 20)), event(2, at(14, 10)), event(3, at(15, 10)), event(4, at(16, 10)))

        val ids = builder.sections(events, EventFilter(date = EventDateFilter.WEEKEND)).flatMap { s -> s.events.map { it.id } }

        assertEquals(listOf(2, 3), ids)
    }

    @Test
    fun `search ignores case, accents and sharp s`() {
        val events = listOf(
            event(1, at(12, 10), name = "Führung durch das Grafschafter Museum"),
            event(2, at(12, 11), name = "Stadtfest Moers"),
        )

        val ids = builder.sections(events, EventFilter(query = "fuhrung")).flatMap { s -> s.events.map { it.id } }

        assertEquals(listOf(1), ids)
    }

    @Test
    fun `favorites filter keeps only favorite events`() {
        val events = listOf(event(1, at(12, 10)), event(2, at(12, 11)), event(3, at(13, 11)))
        val favoritesBuilder = EventListBuilder(now, zone, favoriteIds = setOf(1, 3))

        val ids = favoritesBuilder.sections(events, EventFilter(favoritesOnly = true)).flatMap { s -> s.events.map { it.id } }

        assertEquals(listOf(1, 3), ids)
    }

    @Test
    fun `live means started and not yet ended`() {
        assertTrue(builder.isLive(event(1, at(11, 11), at(11, 13))))
        assertFalse(builder.isLive(event(2, at(11, 13), at(11, 14))))
    }
}
