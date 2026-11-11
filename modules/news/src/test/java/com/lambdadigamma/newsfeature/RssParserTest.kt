package com.lambdadigamma.newsfeature

import com.lambdadigamma.newsfeature.data.RssParser
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import java.time.OffsetDateTime

class RssParserTest {

    private val feed = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/">
          <channel>
            <title>Moers | RP ONLINE</title>
            <link>https://rp-online.de/nrw/staedte/moers/feed.rss</link>
            <atom:link rel="self" href="https://rp-online.de/nrw/staedte/moers/feed.rss"/>
            <item>
              <title>Lesung in Moers: Stilles Gedenken statt Beifall</title>
              <link>https://rp-online.de/nrw/staedte/moers/lesung_aid-158142261</link>
              <guid isPermaLink="true">https://rp-online.de/158142261</guid>
              <description><![CDATA[
                <img src="https://rp-online.de/imgs/small.jpg" hspace="5" align="left"/>
                Die Schilderung der Deportation &amp; bewegende Momente des Gedenkens.
              ]]></description>
              <enclosure url="https://rp-online.de/imgs/large.jpg" length="761509" type="image/jpeg" />
              <pubDate>Tue, 10 Nov 2026 17:15:00 +0100</pubDate>
            </item>
            <item>
              <title>Wunschbäume für Kinder &#039;und&#039; Senioren</title>
              <link> https://rp-online.de/nrw/staedte/moers/wunschbaeume_aid-1 </link>
              <description><![CDATA[<img src="https://rp-online.de/imgs/fallback.jpg"/> Text]]></description>
              <pubDate>not a date</pubDate>
            </item>
            <item>
              <title></title>
              <link>https://rp-online.de/empty</link>
            </item>
          </channel>
        </rss>
    """.trimIndent()

    @Test
    fun `parses title, link, guid, image and date of each item`() {
        val articles = RssParser.parse(feed.byteInputStream(), "RP Online")

        assertEquals(2, articles.size)

        val first = articles[0]
        assertEquals("https://rp-online.de/158142261", first.id)
        assertEquals("Lesung in Moers: Stilles Gedenken statt Beifall", first.title)
        assertEquals("https://rp-online.de/nrw/staedte/moers/lesung_aid-158142261", first.link)
        assertEquals("https://rp-online.de/imgs/large.jpg", first.imageUrl)
        assertEquals("Die Schilderung der Deportation & bewegende Momente des Gedenkens.", first.summary)
        assertEquals(OffsetDateTime.parse("2026-11-10T17:15:00+01:00").toInstant().toEpochMilli(), first.publishedAt)
        assertEquals("RP Online", first.source)
    }

    @Test
    fun `falls back to the link as id and the description image`() {
        val second = RssParser.parse(feed.byteInputStream(), "RP Online")[1]

        assertEquals("https://rp-online.de/nrw/staedte/moers/wunschbaeume_aid-1", second.id)
        assertEquals("Wunschbäume für Kinder 'und' Senioren", second.title)
        assertEquals("https://rp-online.de/imgs/fallback.jpg", second.imageUrl)
        assertNull(second.publishedAt)
    }
}
