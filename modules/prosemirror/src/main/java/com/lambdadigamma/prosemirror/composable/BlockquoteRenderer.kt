package com.lambdadigamma.prosemirror.composable

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.nodes.MarkLinkAttributes
import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeBlockquote
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText

@Composable
fun BlockquoteRenderer(blockQuote: NodeBlockquote, modifier: Modifier = Modifier) {
    val color = MaterialTheme.colorScheme.onBackground
    Box(modifier = modifier
        .drawBehind {
            drawLine(
                color = color,
                strokeWidth = 4f,
                start = Offset(12.dp.value, 0f),
                end = Offset(12.dp.value, size.height)
            )
        }
        .padding(start = 16.dp, top = 4.dp, bottom = 4.dp)) {
        val text = buildAnnotatedString {
            pushStyle(
                MaterialTheme.typography.bodyLarge.toSpanStyle()
//                    .plus(SpanStyle(fontStyle = FontStyle.Italic))
            )
            appendMarkdownChildren(blockQuote, MaterialTheme.colorScheme)
            pop()
        }
        Text(text, modifier)
    }
}

@Preview
@Composable
private fun BlockquoteRendererPreview() {

    MaterialTheme {

        DocumentRenderer(
            modifier = Modifier.width(300.dp),
            document = Document(
                content = listOf(
                    NodeBlockquote(
                        content = listOf(
                            NodeText(text = "This", marks = listOf()),
                            NodeText(text = " is a cool ", marks = listOf()),
                            NodeText(text = "Test.", marks = listOf()),
                        )
                    )
                )
            )
        )

    }

}
