package com.lambdadigamma.prosemirror.composable

import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.nodes.MarkLinkAttributes
import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText

@Composable
fun ParagraphRenderer(paragraph: NodeParagraph, modifier: Modifier = Modifier) {

    val styledText = buildAnnotatedString {
        pushStyle(MaterialTheme.typography.bodyLarge.toSpanStyle())
        appendMarkdownChildren(paragraph, MaterialTheme.colorScheme)
        pop()
    }
    MarkdownText(styledText, MaterialTheme.typography.bodyLarge)

}

@Preview
@Composable
private fun ParagraphRendererPreview() {

    MaterialTheme {

        DocumentRenderer(
            modifier = Modifier.width(300.dp),
            document = Document(
                content = listOf(
                    NodeParagraph(
                        content = listOf(
                            NodeText(text = "This", marks = listOf(MarkType.Italic, MarkType.Strike)),
                            NodeText(text = " is a cool ", marks = listOf(MarkType.Underline)),
                            NodeText(text = "Test.", marks = listOf(MarkType.Bold)),
                        )
                    ),
                    NodeParagraph(
                        content = listOf(
                            NodeText(text = "Another paragraph with a ", marks = listOf()),
                            NodeText(
                                text = "link.",
                                marks = listOf(
                                    MarkType.Link(MarkLinkAttributes(href = "https://google.com"))
                                )
                            ),
                        )
                    ),
                )
            )
        )

    }

}
