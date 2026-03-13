package com.lambdadigamma.pages.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import com.lambdadigamma.medialibrary.composable.MediaImageView
import com.lambdadigamma.pages.data.remote.ImageCollectionBlock
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.data.remote.model.PageBlock
import com.lambdadigamma.prosemirror.composable.DocumentRenderer


@Composable
fun PageBlockRenderer(blocks: List<PageBlock>, modifier: Modifier = Modifier) {

    Column(modifier = modifier) {

        for (pageBlock in blocks) {

            when (val block = pageBlock.data) {
                is TextBlock -> {
                    TextBlockRenderer(block = block, modifier = modifier.padding(horizontal = 16.dp, vertical = 12.dp))
                }
                is ImageCollectionBlock -> {
                    ImageCollectionBlockRenderer(
                        pageBlock = pageBlock,
                        block = block,
                    )
                }
            }
        }

    }

}

@Composable
fun ImageCollectionBlockRenderer(pageBlock: PageBlock, block: ImageCollectionBlock) {

    pageBlock.mediaCollections?.getFirstMedia("images")?.let { media ->
        MediaImageView(
            media = media,
            alignment = Alignment.TopCenter,
            contentScale = ContentScale.FillWidth,
            modifier = Modifier
                .fillMaxWidth()
        )
    }

}

@Composable
fun TextBlockRenderer(block: TextBlock, modifier: Modifier = Modifier) {

    Column(modifier = modifier) {
        block.text?.let {
            DocumentRenderer(document = it)
        }
    }

}