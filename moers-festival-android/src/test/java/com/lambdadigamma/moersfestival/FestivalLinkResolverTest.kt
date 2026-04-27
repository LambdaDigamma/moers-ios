package com.lambdadigamma.moersfestival

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class FestivalLinkResolverTest {

    @Test
    fun `should resolve custom scheme detail links to synthetic stacks`() {
        assertEquals(
            listOf(FestivalNavKey.News, FestivalNavKey.NewsDetail(12)),
            resolveFestivalStack("moersfestival", "posts", listOf("12"), "moersfestival://posts/12"),
        )
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.EventDetail(34)),
            resolveFestivalStack("moersfestival", "events", listOf("34"), "moersfestival://events/34"),
        )
        assertEquals(
            listOf(FestivalNavKey.Map, FestivalNavKey.VenueDetail(56)),
            resolveFestivalStack("moersfestival", "venues", listOf("56"), "moersfestival://venues/56"),
        )
    }

    @Test
    fun `should resolve https app links and fallback to web`() {
        assertEquals(
            listOf(FestivalNavKey.Timetable),
            resolveFestivalStack("https", "moers.app", listOf("events"), "https://moers.app/events"),
        )
        assertEquals(
            listOf(FestivalNavKey.Info, FestivalNavKey.Web(FESTIVAL_LEGAL_URL)),
            resolveFestivalStack("https", "moers.app", listOf("impressum"), "https://moers.app/impressum"),
        )
    }

    @Test
    fun `should ignore unsupported hosts`() {
        assertNull(resolveFestivalStack("https", "example.com", listOf("events"), "https://example.com/events"))
    }
}
