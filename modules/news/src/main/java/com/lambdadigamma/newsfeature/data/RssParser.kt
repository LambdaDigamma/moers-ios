package com.lambdadigamma.newsfeature.data

import org.w3c.dom.Element
import java.io.InputStream
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException
import javax.xml.parsers.DocumentBuilderFactory

/** Parses the items of an RSS 2.0 feed. */
object RssParser {

    private const val MEDIA_NAMESPACE = "http://search.yahoo.com/mrss/"

    fun parse(input: InputStream, source: String): List<NewsArticle> {
        val factory = DocumentBuilderFactory.newInstance().apply {
            isNamespaceAware = true
            isExpandEntityReferences = false
            trySetFeature("http://apache.org/xml/features/disallow-doctype-decl", true)
            trySetFeature("http://xml.org/sax/features/external-general-entities", false)
        }
        val document = factory.newDocumentBuilder().parse(input)
        val items = document.getElementsByTagName("item")

        return (0 until items.length)
            .mapNotNull { index -> (items.item(index) as? Element)?.toArticle(source) }
            .distinctBy { it.id }
    }

    private fun Element.toArticle(source: String): NewsArticle? {
        val title = childText("title")?.let(::cleanText)?.takeIf { it.isNotEmpty() } ?: return null
        val link = childText("link")?.trim()?.takeIf { it.isNotEmpty() } ?: return null
        val description = childText("description")
        return NewsArticle(
            id = childText("guid")?.trim()?.takeIf { it.isNotEmpty() } ?: link,
            title = title,
            link = link,
            summary = description?.let(::cleanText)?.takeIf { it.isNotEmpty() },
            imageUrl = imageUrl() ?: description?.let(::imageFromHtml),
            publishedAt = childText("pubDate")?.let(::parseDate),
            source = source,
        )
    }

    private fun Element.imageUrl(): String? {
        childElements("enclosure").firstOrNull { it.getAttribute("type").startsWith("image") || it.getAttribute("type").isEmpty() }
            ?.getAttribute("url")?.takeIf { it.isNotBlank() }?.let { return it }
        for (name in listOf("content", "thumbnail")) {
            val media = getElementsByTagNameNS(MEDIA_NAMESPACE, name)
            if (media.length > 0) {
                (media.item(0) as Element).getAttribute("url").takeIf { it.isNotBlank() }?.let { return it }
            }
        }
        return null
    }

    private fun Element.childElements(name: String): List<Element> =
        (0 until childNodes.length)
            .map { childNodes.item(it) }
            .filterIsInstance<Element>()
            .filter { it.localName == name || it.nodeName == name }

    private fun Element.childText(name: String): String? =
        childElements(name).firstOrNull()?.textContent

    private fun parseDate(value: String): Long? = try {
        ZonedDateTime.parse(value.trim(), DateTimeFormatter.RFC_1123_DATE_TIME).toInstant().toEpochMilli()
    } catch (_: DateTimeParseException) {
        null
    }

    private val tags = Regex("<[^>]+>")
    private val whitespace = Regex("\\s+")
    private val imageSource = Regex("<img[^>]+src=\"([^\"]+)\"", RegexOption.IGNORE_CASE)

    private fun imageFromHtml(html: String): String? = imageSource.find(html)?.groupValues?.get(1)

    /** Removes HTML tags and decodes the entities that commonly appear in feed text. */
    internal fun cleanText(value: String): String = value
        .replace(tags, " ")
        .replace("&nbsp;", " ")
        .replace("&amp;", "&")
        .replace("&quot;", "\"")
        .replace("&#39;", "'")
        .replace("&#039;", "'")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace(whitespace, " ")
        .trim()

    private fun DocumentBuilderFactory.trySetFeature(feature: String, value: Boolean) {
        try {
            setFeature(feature, value)
        } catch (_: Exception) {
            // The platform parser does not support this feature.
        }
    }
}
