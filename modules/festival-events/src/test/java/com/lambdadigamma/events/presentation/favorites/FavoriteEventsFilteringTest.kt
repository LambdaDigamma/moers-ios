package com.lambdadigamma.events.presentation.favorites

import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import org.junit.jupiter.api.Test
import java.util.Date
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class FavoriteEventsFilteringTest {

    @Test
    fun `should sanitize unavailable filter ids and expose sorted venues`() {
        val filteredData = favoriteEventsData().filteredBy(
            FavoriteEventsFilter(venueIds = listOf(99L, 2L, 2L))
        )

        assertEquals(listOf(2L), filteredData.filter.venueIds)
        assertEquals(listOf("Alpha Stage", "Beta Hall"), filteredData.availableVenues.map(FavoriteVenueFilterOption::name))
        assertEquals(listOf(2), filteredData.sections.single().events.map(EventDisplayable::id))
        assertTrue(filteredData.hasAnyFavorites)
    }

    @Test
    fun `should keep all events when filter is empty`() {
        val filteredData = favoriteEventsData().filteredBy(FavoriteEventsFilter())

        assertTrue(filteredData.filter.isEmpty)
        assertEquals(listOf(1, 2), filteredData.sections.single().events.map(EventDisplayable::id))
        assertEquals(2, filteredData.availableVenues.size)
    }

    @Test
    fun `should remove empty sections after applying venue filter`() {
        val favorites = FavoriteEventsData(
            sections = listOf(
                FavoriteEventsSection(events = listOf(eventDisplayable(id = 1, venueId = 1L, venueName = "Alpha Stage"))),
                FavoriteEventsSection(events = listOf(eventDisplayable(id = 2, venueId = 2L, venueName = "Beta Hall"))),
            ),
        )

        val filteredData = favorites.filteredBy(FavoriteEventsFilter(venueIds = listOf(2L)))

        assertEquals(1, filteredData.sections.size)
        assertEquals(listOf(2), filteredData.sections.single().events.map(EventDisplayable::id))
        assertFalse(filteredData.filter.isEmpty)
    }

    private fun favoriteEventsData(): FavoriteEventsData {
        return FavoriteEventsData(
            sections = listOf(
                FavoriteEventsSection(
                    events = listOf(
                        eventDisplayable(id = 1, venueId = 1L, venueName = "Alpha Stage"),
                        eventDisplayable(id = 2, venueId = 2L, venueName = "Beta Hall"),
                    ),
                ),
            ),
        )
    }

    private fun eventDisplayable(
        id: Int,
        venueId: Long,
        venueName: String,
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
            isFavorite = true,
            isOpenEnd = false,
        )
    }
}
