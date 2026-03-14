package com.lambdadigamma.prosemirror.composable

import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.ParagraphStyle
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
                for (mark in child.marks) {
                    when (mark) {
                        is MarkType.Italic -> {
                            pushStyle(style = SpanStyle(
                                fontStyle = FontStyle.Italic
                            ))
                        }
                        is MarkType.Bold -> {
                            pushStyle(style = SpanStyle(
                                fontWeight = FontWeight.SemiBold
                            ))
                        }
                        is MarkType.Underline -> {
                            pushStyle(style = SpanStyle(
                                textDecoration = TextDecoration.Underline
                            ))
                        }
                        is MarkType.Strike -> {
                            pushStyle(style = SpanStyle(
                                textDecoration = TextDecoration.LineThrough
                            ))
                        }
                        is MarkType.Superscript -> {
                            pushStyle(style = SpanStyle(
                                baselineShift = BaselineShift.Superscript
                            ))
                        }
                        is MarkType.Link -> {
                            pushStyle(style = SpanStyle(
                                color = colors.primary,
                                textDecoration = TextDecoration.Underline,
                                fontWeight = FontWeight.SemiBold
                            ))
                            pushLink(LinkAnnotation.Url(mark.attrs?.href.orEmpty()))
                        }
                    }
                }
                append(child.text)
                for (mark in child.marks) {
                    when (mark) {
                        is MarkType.Link -> {
                            pop()
                            pop()
                        }
                        else -> pop()
                    }
                }
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