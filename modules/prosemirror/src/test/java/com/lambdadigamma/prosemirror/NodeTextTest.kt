package com.lambdadigamma.prosemirror

import com.lambdadigamma.prosemirror.nodes.MarkLinkAttributes
import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeText
import org.junit.jupiter.api.Test

class NodeTextTest: DefaultNodeProsemirrorTest() {

    @Test
    fun encodeMarkBoldAndLinkWithHrefPresent() {

        val text = NodeText(
            text = "Hallo Welt",
            marks = listOf(
                MarkType.Bold,
                MarkType.Link(
                    MarkLinkAttributes(
                        href = "https://example.com"
                    )
                )
            )
        )

        val document = Document(
            content = listOf(
                text
            )
        )

        assertEncodeCorrect(
            encoding = document,
            expectedJson = """
                {"type":"doc","content":[{"type":"text","text":"Hallo Welt","marks":[{"type":"bold"},{"type":"link","attrs":{"href":"https://example.com"}}]}]}
            """.trimIndent()
        )

    }

    @Test
    fun encodeItalicAndUnderline() {

        val text = NodeText(
            text = "Hallo Welt",
            marks = listOf(
                MarkType.Italic,
                MarkType.Underline,
            )
        )

        val document = Document(
            content = listOf(
                text
            )
        )

        assertEncodeCorrect(
            encoding = document,
            expectedJson = """
                {"type":"doc","content":[{"type":"text","text":"Hallo Welt","marks":[{"type":"italic"},{"type":"underline"}]}]}
            """.trimIndent()
        )

    }

    @Test
    fun decodeMarkBoldAndLinkWithHrefPresent() {

        val expectedText = NodeText(
            text = "Hallo Welt",
            marks = listOf(
                MarkType.Bold,
                MarkType.Link(
                    MarkLinkAttributes(
                        href = "https://example.com"
                    )
                )
            )
        )

        assertDecodeCorrect(
            json = """
                {"type":"doc","content":[{"type":"text","text":"Hallo Welt","marks":[{"type":"bold"},{"type":"link","attrs":{"href":"https://example.com"}}]}]}
            """.trimIndent(),
            expectedDocument = Document(content = listOf(expectedText))
        )

    }

}