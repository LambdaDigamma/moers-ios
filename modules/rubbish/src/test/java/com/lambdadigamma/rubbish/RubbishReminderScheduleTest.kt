package com.lambdadigamma.rubbish

import com.lambdadigamma.rubbish.RubbishScheduleViewModel.Companion.toDays
import org.junit.Assert.assertEquals
import org.junit.Test
import java.time.Duration
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId

class RubbishReminderScheduleTest {

    private val zone = ZoneId.of("Europe/Berlin")
    private val now = LocalDateTime.of(2026, 11, 11, 12, 0).atZone(zone)

    private val items = listOf(
        RubbishCollectionItem(date = "2026-11-11", type = RubbishWasteType.RESIDUAL),
        RubbishCollectionItem(date = "2026-11-12", type = RubbishWasteType.PLASTIC),
        RubbishCollectionItem(date = "2026-11-25", type = RubbishWasteType.RESIDUAL),
        RubbishCollectionItem(date = "2026-11-25", type = RubbishWasteType.PAPER),
        RubbishCollectionItem(date = "not a date", type = RubbishWasteType.PAPER),
    )

    @Test
    fun `schedules one reminder per day on the evening before`() {
        val reminders = RubbishRepository.reminderSchedule(items, LocalTime.of(20, 0), now)

        assertEquals(listOf(LocalDate.of(2026, 11, 12), LocalDate.of(2026, 11, 25)), reminders.map { it.pickupDay })
        assertEquals(Duration.ofHours(8), reminders.first().delay)
        assertEquals(listOf(RubbishWasteType.RESIDUAL, RubbishWasteType.PAPER), reminders.last().types)
    }

    @Test
    fun `skips reminders whose time has passed`() {
        val reminders = RubbishRepository.reminderSchedule(items, LocalTime.of(8, 0), now)

        assertEquals(listOf(LocalDate.of(2026, 11, 25)), reminders.map { it.pickupDay })
    }

    @Test
    fun `groups pickups by day`() {
        val days = items.toDays()

        assertEquals(3, days.size)
        assertEquals(listOf(RubbishWasteType.RESIDUAL, RubbishWasteType.PAPER), days.last().types)
    }
}
