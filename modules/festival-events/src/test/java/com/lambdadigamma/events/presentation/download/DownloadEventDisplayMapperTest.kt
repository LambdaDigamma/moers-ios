package com.lambdadigamma.events.presentation.download

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.medialibrary.Media
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.pages.data.remote.UnknownBlock
import com.lambdadigamma.pages.data.remote.model.BlockType
import com.lambdadigamma.pages.data.remote.model.Page
import com.lambdadigamma.pages.data.remote.model.PageBlock
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

class DownloadEventDisplayMapperTest {

    @Test
    fun `should hide image row state when event page has no media`() {
        val event = Event(
            id = 1,
            name = "Text only event",
            page = Page.stub(1),
        )

        val rowState = event.toDownloadDisplayable().toRowState()

        assertEquals(DownloadEventState.DOWNLOADED, rowState.contentState)
        assertNull(rowState.imageState)
    }

    @Test
    fun `should show image row state when page block media is available`() {
        val event = Event(
            id = 2,
            name = "Image event",
            page = Page.stub(2).copy(
                blocks = listOf(pageBlockWithMedia("https://example.com/page-image.jpg")),
            ),
        )

        val displayable = event.toDownloadDisplayable()
        val rowState = displayable.toRowState()

        assertTrue(displayable.hasMediaAvailable)
        assertFalse(displayable.hasMediaDownloaded)
        assertEquals(DownloadEventState.NOT_DOWNLOADED, rowState.imageState)
    }

    @Test
    fun `should mark media downloaded only when downloadable media exists`() {
        val textOnlyEvent = Event(
            id = 3,
            name = "Text only event",
            page = Page.stub(3),
        )
        val mediaEvent = Event(
            id = 4,
            name = "Media event",
            mediaCollections = mediaCollection("https://example.com/event-image.jpg"),
        )

        val textOnlyDisplayable = textOnlyEvent.toDownloadDisplayable(mediaDownloadedEventIds = setOf(3))
        val mediaDisplayable = mediaEvent.toDownloadDisplayable(mediaDownloadedEventIds = setOf(4))

        assertFalse(textOnlyDisplayable.hasMediaDownloaded)
        assertNull(textOnlyDisplayable.toRowState().imageState)
        assertTrue(mediaDisplayable.hasMediaDownloaded)
        assertEquals(DownloadEventState.DOWNLOADED, mediaDisplayable.toRowState().imageState)
    }

    private fun pageBlockWithMedia(url: String): PageBlock {
        return PageBlock(
            id = 1,
            pageID = 1,
            type = "unknown",
            data = UnknownBlock(),
            order = 1,
            mediaCollections = mediaCollection(url),
            createdAt = null,
            updatedAt = null,
            blockType = BlockType.Unknown,
        )
    }

    private fun mediaCollection(url: String): MediaCollectionsContainer {
        return MediaCollectionsContainer(
            collections = mapOf("images" to listOf(media(url))),
        )
    }

    private fun media(url: String): Media {
        return Media(
            id = 1,
            modelType = "event",
            modelId = 1,
            uuid = null,
            collectionName = "images",
            name = "image",
            fileName = "image.jpg",
            fullUrl = url,
        )
    }
}
