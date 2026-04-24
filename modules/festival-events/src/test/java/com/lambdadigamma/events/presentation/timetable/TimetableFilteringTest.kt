package com.lambdadigamma.events.presentation.timetable

import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import com.lambdadigamma.events.presentation.filter.EventFilter
import com.lambdadigamma.events.presentation.filter.EventVenueFilterOption
import org.junit.jupiter.api.Test
import java.util.Date
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class TimetableFilteringTest {

    @Test
    fun `should filter by favorites and venues`() {
        val filteredData = timetableData().filteredBy(
            EventFilter(venueIds = listOf(2L), showOnlyFavorites = true),
        )

        assertEquals(listOf(2), filteredData.sections.single().events.map(EventDisplayable::id))
        assertEquals(listOf(2L), filteredData.filter.venueIds)
        assertTrue(filteredData.filter.showOnlyFavorites)
        assertTrue(filteredData.hasAnyEvents)
    }

    @Test
    fun `should sanitize unavailable venues and expose sorted venue options`() {
        val filteredData = timetableData().filteredBy(
            EventFilter(venueIds = listOf(99L, 1L, 1L)),
        )

        assertEquals(listOf(1L), filteredData.filter.venueIds)
        assertEquals(
            listOf("Alpha Stage", "Beta Hall"),
            filteredData.availableVenues.map(EventVenueFilterOption::name),
        )
        assertEquals(listOf(1), filteredData.sections.single().events.map(EventDisplayable::id))
    }

    @Test
    fun `should report active empty state when filters remove all events`() {
        val filteredData = timetableData().filteredBy(
            EventFilter(venueIds = listOf(1L), showOnlyFavorites = true),
        )

        assertTrue(filteredData.sections.isEmpty())
        assertTrue(filteredData.hasAnyEvents)
        assertFalse(filteredData.filter.isEmpty)
    }

    private fun timetableData(): TimetableData {
        return TimetableData(
            currentIndex = 0,
            sections = listOf(
                TimetableSection(
                    events = listOf(
                        eventDisplayable(
                            id = 1,
                            venueId = 1L,
                            venueName = "Alpha Stage",
                            isFavorite = false,
                        ),
                        eventDisplayable(
                            id = 2,
                            venueId = 2L,
                            venueName = "Beta Hall",
                            isFavorite = true,
                        ),
                    ),
                ),
            ),
        )
    }

    private fun eventDisplayable(
        id: Int,
        venueId: Long,
        venueName: String,
        isFavorite: Boolean,
    ): EventDisplayable {
        return EventDisplayable(
            id = id,
            name = "Event $id",
            startDate = Date(id * 1_000L),
            endDate = Date(id * 2_000L),
            place = PlaceDisplayable(
                id = venueId,
                name = venueName,
                point = Point(latitude = 51.44, longitude = 6.62),
                addressLine1 = "Street $id",
                addressLine2 = "47441 Moers",
            ),
            isFavorite = isFavorite,
            isOpenEnd = false,
        )
    }
}
