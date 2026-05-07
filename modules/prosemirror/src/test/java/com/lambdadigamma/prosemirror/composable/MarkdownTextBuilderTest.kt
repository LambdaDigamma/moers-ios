package com.lambdadigamma.prosemirror.composable

import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.buildAnnotatedString
import com.lambdadigamma.prosemirror.nodes.MarkLinkAttributes
import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeHardBreak
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue

class MarkdownTextBuilderTest {

    private val colorScheme = lightColorScheme(primary = Color(0xFF1565C0))

    @Test
    fun `linked text produces a bounded link annotation`() {
        val text = buildText(
            NodeParagraph(
                content = listOf(
                    NodeText(
                        text = "moers festival",
                        marks = listOf(
                            MarkType.Link(
                                MarkLinkAttributes("https://moers.app")
                            )
                        )
                    )
                )
            )
        )

        val links = text.getLinkAnnotations(0, text.length)

        assertEquals("moers festival", text.text)
        assertEquals(1, links.size)
        assertEquals(0, links.single().start)
        assertEquals(text.length, links.single().end)
        assertIs<LinkAnnotation.Url>(links.single().item)
        assertRangesInsideBounds(text)
    }

    @Test
    fun `empty linked text does not produce a zero length link annotation`() {
        val text = buildText(
            NodeParagraph(
                content = listOf(
                    NodeText(
                        text = "",
                        marks = listOf(
                            MarkType.Link(
                                MarkLinkAttributes("https://moers.app")
                            )
                        )
                    )
                )
            )
        )

        assertEquals("", text.text)
        assertEquals(emptyList(), text.getLinkAnnotations(0, text.length))
        assertRangesInsideBounds(text)
    }

    @Test
    fun `mixed marks and hard breaks keep all ranges inside text bounds`() {
        val text = buildText(
            NodeParagraph(
                content = listOf(
                    NodeText(
                        text = "Alpha",
                        marks = listOf(
                            MarkType.Bold,
                            MarkType.Italic,
                            MarkType.Underline,
                            MarkType.Strike,
                            MarkType.Superscript,
                            MarkType.Link(
                                MarkLinkAttributes("https://moers.app/alpha")
                            )
                        )
                    ),
                    NodeHardBreak(),
                    NodeText(
                        text = "",
                        marks = listOf(
                            MarkType.Link(
                                MarkLinkAttributes("https://moers.app/empty")
                            )
                        )
                    ),
                    NodeText(
                        text = "Beta",
                        marks = listOf(
                            MarkType.Underline,
                            MarkType.Strike
                        )
                    )
                )
            )
        )

        assertEquals("Alpha\nBeta", text.text)
        assertEquals(1, text.getLinkAnnotations(0, text.length).size)
        assertRangesInsideBounds(text)
    }

    private fun buildText(parent: NodeParagraph): AnnotatedString {
        return buildAnnotatedString {
            appendMarkdownChildren(parent, colorScheme)
        }
    }

    private fun assertRangesInsideBounds(text: AnnotatedString) {
        text.spanStyles.forEach { range ->
            assertTrue(range.start >= 0)
            assertTrue(range.end <= text.length)
            assertTrue(range.start < range.end)
        }
        text.getLinkAnnotations(0, text.length).forEach { range ->
            assertTrue(range.start >= 0)
            assertTrue(range.end <= text.length)
            assertTrue(range.start < range.end)
        }
    }
}
