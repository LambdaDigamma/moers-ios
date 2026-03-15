package com.lambdadigamma.prosemirror

import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import org.junit.jupiter.api.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class DocumentBlankTest {

    @Test
    fun testBlankDocument() {

        val node = NodeText(
            text = ""
        )

        assertTrue { node.isBlank() }

    }

    @Test
    fun testDocumentIsBlank() {

        val document = Document(
            content = listOf(
                NodeText(
                    text = "Hallo Welt"
                )
            )
        )

        assertFalse { document.isBlank() }

    }

    @Test
    fun testDocumentIsBlankWithEmptyContent() {

        val document = Document(
            content = listOf()
        )

        assertTrue { document.isBlank() }

    }

    @Test
    fun testDocumentIsBlankWithEmptyText() {

        val document = Document(
            content = listOf(
                NodeText(
                    text = ""
                )
            )
        )

        assertTrue { document.isBlank() }

    }

    @Test
    fun testDocumentNotBlank() {

        val document = Document(
            content = listOf(
                NodeParagraph(
                    content = listOf(
                        NodeText(
                            text = "Hallo Welt"
                        )
                    )
                )
            )
        )

        assertFalse { document.isBlank() }

    }

}