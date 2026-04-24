package com.lambdadigamma.pages

import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.pages.data.local.model.PageBlockCached
import com.lambdadigamma.pages.data.mapper.toDomainModel
import com.lambdadigamma.pages.data.mapper.toEntityModel
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.data.remote.model.BlockType
import com.lambdadigamma.pages.data.remote.model.PageBlock
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import org.junit.jupiter.api.Test
import java.util.Date
import kotlin.test.assertEquals

class PageBlockMapperTest {

    @Test
    fun mapPageBlockToPageBlockCached() {

        val pageBlock = PageBlock(
            id = 978,
            pageID = 405,
            type = "tip-tap-text-with-media",
            data = TextBlock(
                title = "Just testing",
                subtitle = null,
                text = Document(content = listOf(
                    NodeParagraph(content = listOf(
                        NodeText(text = "Just testing")
                    ))
                ))
            ),
            order = 0,
            createdAt = Date(1685112300000),
            updatedAt = Date(1685112300000),
            children = emptyList(),
            mediaCollections = MediaCollectionsContainer(),
            blockType = BlockType.Text,
        )

        val cachedPageBlock = pageBlock.toEntityModel()

        assertEquals(978, cachedPageBlock.id)
        assertEquals(405, cachedPageBlock.pageID)
        assertEquals("tip-tap-text-with-media", cachedPageBlock.type)
        assertEquals("""
            {"title":"Just testing","text":{"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Just testing","marks":[]}]}]}}
        """.trimIndent(), cachedPageBlock.data)
        assertEquals(0, cachedPageBlock.mediaCollectionsContainer?.collections?.size)

    }

    @Test
    fun mapCachedPageBlockToPageBlock() {

        val cachedPageBlock = PageBlockCached(
            id = 978,
            pageID = 405,
            type = "tip-tap-text-with-media",
            data = """
                {"title":"Just testing","text":{"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Just testing","marks":[]}]}]}}
            """.trimIndent(),
            createdAt = Date(1685112300000),
            updatedAt = Date(1685112300000),
            mediaCollectionsContainer = MediaCollectionsContainer(),
        )

        val pageBlock = cachedPageBlock.toDomainModel()

        assertEquals(978, pageBlock.id)
        assertEquals(405, pageBlock.pageID)
        assertEquals("tip-tap-text-with-media", pageBlock.type)
        assertEquals(
            TextBlock(
                title = "Just testing",
                subtitle = null,
                text = Document(content = listOf(
                    NodeParagraph(content = listOf(
                        NodeText(text = "Just testing")
                    ))
                ))
            ),
            pageBlock.data
        )
        assertEquals(0, pageBlock.mediaCollections?.collections?.size)
        assertEquals(emptyList(), pageBlock.children)

    }


}
