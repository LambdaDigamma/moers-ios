package com.lambdadigamma.events

import com.google.gson.Gson
import com.lambdadigamma.events.models.EventPageResponse
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.OffsetDateTime

class EventDtoTest {

    private val json = """
        {
          "data": [
            {
              "id": 999,
              "name": "Offene PC-Sprechstunde",
              "startDate": "2026-11-11T10:00:00+00:00",
              "endDate": "2026-11-11T11:30:00+00:00",
              "description": "Fragen über Fragen.",
              "category": "Information und Weiterbildung",
              "attendanceMode": "offline",
              "isOnline": false,
              "locationName": "Wilhelm-Schroeder-Straße 10, 47441 Moers",
              "street": "Wilhelm-Schroeder-Straße 10",
              "postcode": "47441",
              "city": "Moers",
              "latitude": 51.453199,
              "longitude": 6.63157,
              "organisationName": "Volkshochschule Moers",
              "headerImageUrl": null,
              "showsTimeComponent": true,
              "cancelledAt": null
            },
            { "id": 1000, "name": "  " },
            { "id": 1001, "name": "Online-Vortrag", "isOnline": true, "cancelledAt": "2026-11-01T10:00:00+00:00" }
          ],
          "meta": { "current_page": 1, "last_page": 3, "total": 79 }
        }
    """.trimIndent()

    @Test
    fun `maps the camel case API format`() {
        val page = Gson().fromJson(json, EventPageResponse::class.java)
        val events = page.data.orEmpty().mapNotNull { it.toEvent() }

        assertEquals(3, page.meta?.lastPage)
        assertEquals(listOf(999, 1001), events.map { it.id })

        val event = events.first()
        assertEquals(OffsetDateTime.parse("2026-11-11T10:00:00+00:00").toInstant().toEpochMilli(), event.startDate)
        assertEquals("Volkshochschule Moers", event.organizerName)
        assertEquals(listOf("Wilhelm-Schroeder-Straße 10", "47441 Moers"), event.addressLines)
        assertNull(event.imageUrl)

        val online = events.last()
        assertTrue(online.isOnline)
        assertTrue(online.isCancelled)
        assertNull(online.startDate)
    }
}
