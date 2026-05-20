package com.lambdadigamma.events.presentation.search

import com.lambdadigamma.events.presentation.EventDisplayable
import org.junit.jupiter.api.Test
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class EventSearchSectionBuilderTest {

    @Test
    fun `should group early morning event into previous festival day`() {
        val calendar = testCalendar()
        val lateNight = eventDisplayable(
            id = 1,
            startDate = date(year = 2030, month = Calendar.MAY, day = 17, hour = 23, minute = 30),
        )
        val earlyMorning = eventDisplayable(
            id = 2,
            startDate = date(year = 2030, month = Calendar.MAY, day = 18, hour = 5, minute = 59),
        )
        val boundary = eventDisplayable(
            id = 3,
            startDate = date(year = 2030, month = Calendar.MAY, day = 18, hour = 6),
        )

        val sections = EventSearchSectionBuilder.build(
            events = listOf(lateNight, earlyMorning, boundary),
            calendar = calendar,
        )

        assertEquals(
            listOf(
                date(year = 2030, month = Calendar.MAY, day = 17),
                date(year = 2030, month = Calendar.MAY, day = 18),
            ),
            sections.map { section -> section.range!!.first }.map { startDate ->
                calendar.apply { time = startDate }
                calendar.add(Calendar.HOUR_OF_DAY, -6)
                startOfDay(calendar.time)
            },
        )
        assertEquals(listOf(listOf(1, 2), listOf(3)), sections.map { section -> section.events.map(EventDisplayable::id) })
    }

    @Test
    fun `should append undated events as final section`() {
        val calendar = testCalendar()
        val undatedFirst = eventDisplayable(id = 1, startDate = null)
        val secondDay = eventDisplayable(
            id = 2,
            startDate = date(year = 2030, month = Calendar.MAY, day = 18, hour = 12),
        )
        val undatedSecond = eventDisplayable(id = 3, startDate = null)
        val firstDay = eventDisplayable(
            id = 4,
            startDate = date(year = 2030, month = Calendar.MAY, day = 17, hour = 12),
        )

        val sections = EventSearchSectionBuilder.build(
            events = listOf(undatedFirst, secondDay, undatedSecond, firstDay),
            calendar = calendar,
        )

        assertEquals(listOf(listOf(4), listOf(2), listOf(1, 3)), sections.map { section -> section.events.map(EventDisplayable::id) })
        assertFalse(sections[0].isUndated)
        assertFalse(sections[1].isUndated)
        assertTrue(sections[2].isUndated)
        assertEquals(null, sections[2].range)
    }

    @Test
    fun `should preserve incoming row order within a day`() {
        val calendar = testCalendar()
        val first = eventDisplayable(
            id = 1,
            startDate = date(year = 2030, month = Calendar.MAY, day = 18, hour = 5, minute = 30),
        )
        val second = eventDisplayable(
            id = 2,
            startDate = date(year = 2030, month = Calendar.MAY, day = 17, hour = 23),
        )
        val third = eventDisplayable(
            id = 3,
            startDate = date(year = 2030, month = Calendar.MAY, day = 17, hour = 12),
        )

        val sections = EventSearchSectionBuilder.build(
            events = listOf(first, second, third),
            calendar = calendar,
        )

        assertEquals(1, sections.size)
        assertEquals(listOf(1, 2, 3), sections.single().events.map(EventDisplayable::id))
    }

    private fun eventDisplayable(
        id: Int,
        startDate: Date?,
    ): EventDisplayable {
        return EventDisplayable(
            id = id,
            name = "Event $id",
            startDate = startDate,
            endDate = null,
            place = null,
            isOpenEnd = false,
        )
    }

    private fun date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
    ): Date {
        val calendar = testCalendar()
        calendar.set(year, month, day, hour, minute, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        return calendar.time
    }

    private fun startOfDay(date: Date): Date {
        val calendar = testCalendar()
        calendar.time = date
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        return calendar.time
    }

    private fun testCalendar(): Calendar {
        return Calendar.getInstance(TimeZone.getTimeZone("UTC"), Locale.US)
    }
}
