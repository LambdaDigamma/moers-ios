package com.lambdadigamma.moersfestival

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class FestivalLinkResolverTest {

    @Test
    fun `should resolve canonical custom scheme routes`() {
        assertEquals(
            listOf(FestivalNavKey.News),
            resolveFestivalStack("moersfestival", null, listOf("posts"), "moersfestival:///posts"),
        )
        assertEquals(
            listOf(FestivalNavKey.News, FestivalNavKey.NewsDetail(12)),
            resolveFestivalStack(
                "moersfestival",
                null,
                listOf("posts", "12"),
                "moersfestival:///posts/12",
            ),
        )
        assertEquals(
            listOf(FestivalNavKey.Timetable),
            resolveFestivalStack("moersfestival", null, listOf("events"), "moersfestival:///events"),
        )
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.EventDetail(34)),
            resolveFestivalStack(
                "moersfestival",
                null,
                listOf("events", "34"),
                "moersfestival:///events/34",
            ),
        )
        assertEquals(
            listOf(FestivalNavKey.Favorites),
            resolveFestivalStack("moersfestival", null, listOf("favorites"), "moersfestival:///favorites"),
        )
        assertEquals(
            listOf(FestivalNavKey.Map),
            resolveFestivalStack("moersfestival", null, listOf("map"), "moersfestival:///map"),
        )
        assertEquals(
            listOf(FestivalNavKey.Map),
            resolveFestivalStack("moersfestival", null, listOf("venues"), "moersfestival:///venues"),
        )
        assertEquals(
            listOf(FestivalNavKey.Map, FestivalNavKey.VenueDetail(56)),
            resolveFestivalStack(
                "moersfestival",
                null,
                listOf("venues", "56"),
                "moersfestival:///venues/56",
            ),
        )
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.DownloadEvents),
            resolveFestivalStack(
                "moersfestival",
                null,
                listOf("download-events"),
                "moersfestival:///download-events",
            ),
        )
        assertEquals(
            listOf(FestivalNavKey.Info),
            resolveFestivalStack("moersfestival", null, listOf("info"), "moersfestival:///info"),
        )
        assertEquals(
            listOf(FestivalNavKey.Info, FestivalNavKey.Web(FESTIVAL_LEGAL_URL)),
            resolveFestivalStack("moersfestival", null, listOf("legal"), "moersfestival:///legal"),
        )
    }

    @Test
    fun `should resolve invalid custom scheme ids to corresponding overview`() {
        assertEquals(
            listOf(FestivalNavKey.News),
            resolveFestivalStack(
                "moersfestival",
                null,
                listOf("posts", "invalid"),
                "moersfestival:///posts/invalid",
            ),
        )
        assertEquals(
            listOf(FestivalNavKey.Timetable),
            resolveFestivalStack(
                "moersfestival",
                null,
                listOf("events", "invalid"),
                "moersfestival:///events/invalid",
            ),
        )
        assertEquals(
            listOf(FestivalNavKey.Map),
            resolveFestivalStack(
                "moersfestival",
                null,
                listOf("venues", "invalid"),
                "moersfestival:///venues/invalid",
            ),
        )
    }

    @Test
    fun `should reject non-canonical custom scheme routes`() {
        assertNull(
            resolveFestivalStack(
                "moersfestival",
                null,
                listOf("spielplan", "34"),
                "moersfestival:///spielplan/34",
            ),
        )
        assertNull(resolveFestivalStack("moersfestival", null, listOf("unknown"), "moersfestival:///unknown"))
        assertNull(resolveFestivalStack("moersfestival", "events", listOf("34"), "moersfestival://events/34"))
        assertNull(resolveFestivalStack("moersfestival", null, listOf("events"), "moersfestival:/events"))
    }

    @Test
    fun `should resolve https app links with existing route aliases and fallback to web`() {
        assertEquals(
            listOf(FestivalNavKey.Timetable),
            resolveFestivalStack("https", "moers.app", listOf("events"), "https://moers.app/events"),
        )
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.EventDetail(34)),
            resolveFestivalStack(
                "https",
                "moers.app",
                listOf("spielplan", "34"),
                "https://moers.app/spielplan/34",
            ),
        )
        assertEquals(
            listOf(FestivalNavKey.Info, FestivalNavKey.Web(FESTIVAL_LEGAL_URL)),
            resolveFestivalStack("https", "moers.app", listOf("impressum"), "https://moers.app/impressum"),
        )
        assertEquals(
            listOf(FestivalNavKey.Info, FestivalNavKey.Web("https://moers.app/unknown")),
            resolveFestivalStack("https", "moers.app", listOf("unknown"), "https://moers.app/unknown"),
        )
    }

    @Test
    fun `should ignore unsupported hosts`() {
        assertNull(resolveFestivalStack("https", "example.com", listOf("events"), "https://example.com/events"))
    }
}
