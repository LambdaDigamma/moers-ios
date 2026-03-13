package com.lambdadigamma.prosemirror.composable

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.tooling.preview.Preview
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.nodes.NodeBulletList
import com.lambdadigamma.prosemirror.nodes.NodeList
import com.lambdadigamma.prosemirror.nodes.NodeListItem
import com.lambdadigamma.prosemirror.nodes.NodeOrderedList
import com.lambdadigamma.prosemirror.nodes.NodeText
import com.lambdadigamma.prosemirror.nodes.ProsemirrorNode


@Composable
fun BulletListRenderer(bulletList: NodeBulletList, modifier: Modifier = Modifier) {
    val marker = "•"

    ListItemsRenderer(listBlock = bulletList, modifier = modifier) {
        val text = buildAnnotatedString {
            pushStyle(MaterialTheme.typography.bodyLarge.toSpanStyle())
            append("$marker ")
            appendMarkdownChildren(it, MaterialTheme.colorScheme)
            pop()
        }
        MarkdownText(text, MaterialTheme.typography.bodyLarge, modifier)
    }

}

@Composable
fun OrderedListRenderer(orderedList: NodeOrderedList, modifier: Modifier = Modifier) {
    var number = 1 // orderedList.startNumber
    val delimiter = "." //orderedList.delimiter
    ListItemsRenderer(orderedList, modifier) {
        val text = buildAnnotatedString {
            pushStyle(MaterialTheme.typography.bodyLarge.toSpanStyle())
            append("${number++}$delimiter ")
            appendMarkdownChildren(it, MaterialTheme.colorScheme)
            pop()
        }
        MarkdownText(text, MaterialTheme.typography.bodyLarge, modifier)
    }
}

@Composable
fun ListItemsRenderer(
    listBlock: NodeList,
    modifier: Modifier = Modifier,
    item: @Composable (node: ProsemirrorNode) -> Unit
) {
//    val bottom = if (listBlock.parent is Document) 8.dp else 0.dp
//    val start = if (listBlock.parent is Document) 0.dp else 8.dp
    Column(modifier = modifier) {

        for (listItem in listBlock.content.orEmpty()) {
            when (listItem) {
                is NodeBulletList -> BulletListRenderer(listItem, modifier)
                is NodeOrderedList -> OrderedListRenderer(listItem, modifier)
                else -> item(listItem)
            }
        }

    }
}

@Preview
@Composable
private fun BulletListPreview() {
    
    MaterialTheme {
        DocumentRenderer(document = Document(
            content = listOf(
                NodeBulletList(
                    content = listOf(
                        NodeListItem(
                            content = listOf(
                                NodeText(text = "Item 1")
                            )
                        ),
                        NodeListItem(
                            content = listOf(
                                NodeText(text = "Item 2")
                            )
                        )
                    )
                )
            )
        ))
    }
    
}