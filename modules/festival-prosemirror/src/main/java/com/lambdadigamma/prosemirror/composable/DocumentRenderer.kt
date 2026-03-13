package com.lambdadigamma.prosemirror.composable

import androidx.compose.foundation.layout.Column
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.nodes.NodeBlockquote
import com.lambdadigamma.prosemirror.nodes.NodeBulletList
import com.lambdadigamma.prosemirror.nodes.NodeOrderedList
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.ProsemirrorNode

@Composable
fun DocumentRenderer(
    document: Document,
    modifier: Modifier = Modifier
) {

    Column(modifier = modifier) {
        DocumentChildren(parentNode = document)
    }

}

@Composable
private fun DocumentChildren(parentNode: ProsemirrorNode) {

    for (child in parentNode.content.orEmpty()) {
        when (child) {
            is NodeParagraph -> ParagraphRenderer(paragraph = child)
            is NodeBlockquote -> BlockquoteRenderer(blockQuote = child)
            is NodeBulletList -> BulletListRenderer(bulletList = child)
            is NodeOrderedList -> OrderedListRenderer(orderedList = child)
        }
    }

}
