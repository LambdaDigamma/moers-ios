package com.lambdadigamma.prosemirror.composable

import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.text.style.TextDecoration
import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeHardBreak
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import com.lambdadigamma.prosemirror.nodes.ProsemirrorNode

fun AnnotatedString.Builder.appendMarkdownChildren(
    parent: ProsemirrorNode, colors: ColorScheme
) {

    val children = parent.content.orEmpty()

    for (child in children) {
        when (child) {
            is NodeParagraph -> appendMarkdownChildren(child, colors)
            is NodeText -> {
                appendMarkedText(child, colors)
            }
            is NodeHardBreak -> {
                appendLine()
            }
//            is Code -> {
//                pushStyle(TextStyle(fontFamily = FontFamily.Monospace).toSpanStyle())
//                append(child.literal)
//                pop()
//            }
//            is Link -> {
//                val underline = SpanStyle(colors.primary, textDecoration = TextDecoration.Underline)
//                pushStyle(underline)
//                pushStringAnnotation(TAG_URL, child.destination)
//                appendMarkdownChildren(child, colors)
//                pop()
//                pop()
//            }
        }
    }

}

private fun AnnotatedString.Builder.appendMarkedText(
    child: NodeText,
    colors: ColorScheme
) {
    val start = length
    append(child.text)
    val end = length

    if (start == end) return

    createSpanStyle(child.marks, colors)?.let { style ->
        addStyle(style = style, start = start, end = end)
    }

    child.marks
        .filterIsInstance<MarkType.Link>()
        .firstNotNullOfOrNull { mark -> mark.attrs?.href?.takeIf(String::isNotBlank) }
        ?.let { href ->
            addLink(LinkAnnotation.Url(href), start = start, end = end)
        }
}

private fun createSpanStyle(
    marks: List<MarkType>,
    colors: ColorScheme
): SpanStyle? {
    if (marks.isEmpty()) return null

    val hasLink = marks.any { it is MarkType.Link }
    val textDecorations = buildList {
        if (marks.any { it is MarkType.Underline } || hasLink) {
            add(TextDecoration.Underline)
        }
        if (marks.any { it is MarkType.Strike }) {
            add(TextDecoration.LineThrough)
        }
    }

    return SpanStyle(
        color = if (hasLink) colors.primary else Color.Unspecified,
        fontStyle = if (marks.any { it is MarkType.Italic }) FontStyle.Italic else null,
        fontWeight = if (marks.any { it is MarkType.Bold } || hasLink) {
            FontWeight.SemiBold
        } else {
            null
        },
        baselineShift = if (marks.any { it is MarkType.Superscript }) {
            BaselineShift.Superscript
        } else {
            null
        },
        textDecoration = textDecorations
            .takeIf { it.isNotEmpty() }
            ?.let(TextDecoration::combine),
    )
}

@Composable
fun MarkdownText(text: AnnotatedString, style: TextStyle, modifier: Modifier = Modifier) {
    val uriHandler = LocalUriHandler.current
    val layoutResult = remember { mutableStateOf<TextLayoutResult?>(null) }

    Text(
        text = text,
        modifier = modifier.pointerInput(Unit) {
            detectTapGestures { offset ->
                layoutResult.value?.let { layoutResult ->
                    val position = layoutResult.getOffsetForPosition(offset)
                    text.getLinkAnnotations(position, position)
                        .firstOrNull()
                        ?.let { sa ->
                            val link = sa.item
                            if (link is LinkAnnotation.Url) {
                                uriHandler.openUri(link.url)
                            }
                        }
                }
            }
        },
        style = style,
        onTextLayout = { layoutResult.value = it }
    )
}
