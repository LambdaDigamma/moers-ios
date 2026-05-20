package com.lambdadigamma.events.data.mapper

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.data.remote.model.Place
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

class EventSearchIndexMapperTest {

    @Test
    fun `should build normalized search index from event artist and venue`() {
        val event = Event(
            id = 42,
            name = "Straße Trio",
            description = "Not part of v1 search",
            artists = listOf("Æon", "Noël"),
            category = "Not part of v1 search",
            collection = "Not part of v1 search",
            place = Place(
                id = 7L,
                lat = 51.44,
                lng = 6.62,
                name = "Bühne Øst",
                streetName = null,
                streetNumber = null,
                streetAddition = null,
                postalCode = null,
                postalTown = null,
                countryCode = null,
                tags = "",
                url = null,
                phone = null,
                pageID = null,
                validatedAt = null,
                createdAt = null,
                updatedAt = null,
                deletedAt = null,
            ),
        )

        val index = event.toSearchIndexCached()

        assertEquals(42, index.eventId)
        assertEquals("strasse trio", index.normalizedName)
        assertEquals("aeon noel", index.normalizedArtists)
        assertEquals("buhne ost", index.normalizedPlaceName)
    }
}
