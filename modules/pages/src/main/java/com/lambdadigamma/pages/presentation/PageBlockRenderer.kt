package com.lambdadigamma.pages.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.OpenInNew
import androidx.compose.material.icons.rounded.Language
import androidx.compose.material.icons.rounded.Link
import androidx.compose.material.icons.rounded.MusicNote
import androidx.compose.material.icons.rounded.PlayCircleOutline
import androidx.compose.material.icons.rounded.SmartDisplay
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.lambdadigamma.medialibrary.composable.MediaImageView
import com.lambdadigamma.pages.R
import com.lambdadigamma.pages.data.remote.ExternalLinkBlock
import com.lambdadigamma.pages.data.remote.ImageCollectionBlock
import com.lambdadigamma.pages.data.remote.LinkListBlock
import com.lambdadigamma.pages.data.remote.SoundcloudBlock
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.data.remote.UnknownBlock
import com.lambdadigamma.pages.data.remote.YoutubeVideoBlock
import com.lambdadigamma.pages.data.remote.model.PageBlock
import com.lambdadigamma.prosemirror.composable.DocumentRenderer

@Composable
fun PageBlockRenderer(
    blocks: List<PageBlock>,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        blocks.forEach { pageBlock ->
            PageBlockItem(pageBlock = pageBlock)
        }
    }
}

@Composable
private fun PageBlockItem(
    pageBlock: PageBlock,
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        when (val block = pageBlock.data) {
            is TextBlock -> {
                if (!block.isBlank()) {
                    TextBlockRenderer(
                        block = block,
                        modifier = Modifier.padding(horizontal = 16.dp),
                    )
                }
            }

            is ImageCollectionBlock -> {
                ImageCollectionBlockRenderer(
                    pageBlock = pageBlock,
                    block = block,
                )
            }

            is ExternalLinkBlock -> {
                if (!block.isBlank()) {
                    ExternalLinkBlockRenderer(
                        block = block,
                        modifier = Modifier.padding(horizontal = 16.dp),
                    )
                }
            }

            is LinkListBlock -> {
                if (!block.isBlank()) {
                    LinkListBlockRenderer(
                        block = block,
                        modifier = Modifier.padding(horizontal = 16.dp),
                    )
                }
            }

            is YoutubeVideoBlock -> {
                if (!block.isBlank()) {
                    YoutubeVideoBlockRenderer(
                        block = block,
                        modifier = Modifier.padding(horizontal = 16.dp),
                    )
                }
            }

            is SoundcloudBlock -> {
                if (!block.isBlank()) {
                    SoundcloudBlockRenderer(
                        block = block,
                        modifier = Modifier.padding(horizontal = 16.dp),
                    )
                }
            }

            is UnknownBlock -> Unit
        }

        if (pageBlock.children.isNotEmpty()) {
            PageBlockRenderer(blocks = pageBlock.children)
        }
    }
}

@Composable
fun ImageCollectionBlockRenderer(
    pageBlock: PageBlock,
    block: ImageCollectionBlock,
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        pageBlock.mediaCollections?.getFirstMedia("images")?.let { media ->
            MediaImageView(
                media = media,
                alignment = Alignment.TopCenter,
                contentScale = ContentScale.FillWidth,
                modifier = Modifier.fillMaxWidth(),
            )
        }

        if (!block.isBlank()) {
            TextBlockBody(
                block.text,
                modifier = Modifier.padding(horizontal = 16.dp),
            )
        }
    }
}

@Composable
fun TextBlockRenderer(
    block: TextBlock,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        block.title
            ?.takeIf { it.isNotBlank() }
            ?.let { title ->
                Text(
                    text = title,
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                )
            }

        block.subtitle
            ?.takeIf { it.isNotBlank() }
            ?.let { subtitle ->
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

        TextBlockBody(block.text)
    }
}

@Composable
private fun ExternalLinkBlockRenderer(
    block: ExternalLinkBlock,
    modifier: Modifier = Modifier,
) {
    val uriHandler = LocalUriHandler.current

    ActionBlockCard(
        modifier = modifier,
        title = block.title ?: stringResource(R.string.page_block_external_link),
        supportingText = {
            TextBlockBody(block.text)
            block.url
                ?.takeIf { it.isNotBlank() }
                ?.let { url ->
                    Text(
                        text = url,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
        },
        icon = Icons.AutoMirrored.Rounded.OpenInNew,
        actionLabel = stringResource(R.string.page_block_open_link),
        onAction = {
            block.url?.let(uriHandler::openUri)
        },
        enabled = !block.url.isNullOrBlank(),
    )
}

@Composable
private fun LinkListBlockRenderer(
    block: LinkListBlock,
    modifier: Modifier = Modifier,
) {
    val uriHandler = LocalUriHandler.current

    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Text(
            text = stringResource(R.string.page_block_links),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
        )

        block.links.forEach { entry ->
            val (containerColor, contentColor) = entry.color.blockColors()

            Button(
                onClick = { uriHandler.openUri(entry.href) },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = containerColor,
                    contentColor = contentColor,
                ),
                shape = RoundedCornerShape(18.dp),
            ) {
                Icon(
                    imageVector = entry.icon.blockIcon(),
                    contentDescription = null,
                )
                Text(
                    text = entry.text,
                    modifier = Modifier
                        .weight(1f)
                        .padding(start = 12.dp),
                )
                Icon(
                    imageVector = Icons.AutoMirrored.Rounded.OpenInNew,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp),
                )
            }
        }
    }
}

@Composable
private fun YoutubeVideoBlockRenderer(
    block: YoutubeVideoBlock,
    modifier: Modifier = Modifier,
) {
    val uriHandler = LocalUriHandler.current
    val url = block.videoId?.takeIf { it.isNotBlank() }?.let { videoId ->
        "https://www.youtube.com/watch?v=$videoId"
    }

    ActionBlockCard(
        modifier = modifier,
        title = block.title ?: stringResource(R.string.page_block_youtube),
        supportingText = {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp)
                    .background(
                        color = MaterialTheme.colorScheme.secondaryContainer,
                        shape = RoundedCornerShape(18.dp),
                    ),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = Icons.Rounded.PlayCircleOutline,
                    contentDescription = null,
                    modifier = Modifier.size(48.dp),
                    tint = MaterialTheme.colorScheme.onSecondaryContainer,
                )
            }

            TextBlockBody(block.text)
        },
        icon = Icons.Rounded.SmartDisplay,
        actionLabel = stringResource(R.string.page_block_watch_video),
        onAction = { url?.let(uriHandler::openUri) },
        enabled = url != null,
    )
}

@Composable
private fun SoundcloudBlockRenderer(
    block: SoundcloudBlock,
    modifier: Modifier = Modifier,
) {
    val uriHandler = LocalUriHandler.current
    val url = block.url
        ?.takeIf { it.isNotBlank() }
        ?: block.trackId
            ?.takeIf { it.isNotBlank() }
            ?.let { trackId ->
                "https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/$trackId"
            }

    ActionBlockCard(
        modifier = modifier,
        title = block.title ?: stringResource(R.string.page_block_soundcloud),
        supportingText = {
            Surface(
                shape = RoundedCornerShape(18.dp),
                color = MaterialTheme.colorScheme.secondaryContainer,
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Icon(
                        imageVector = Icons.Rounded.MusicNote,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onSecondaryContainer,
                    )
                    Text(
                        text = stringResource(R.string.page_block_soundcloud_description),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSecondaryContainer,
                    )
                }
            }

            TextBlockBody(block.text)
        },
        icon = Icons.Rounded.MusicNote,
        actionLabel = stringResource(R.string.page_block_open_soundcloud),
        onAction = { url?.let(uriHandler::openUri) },
        enabled = url != null,
    )
}

@Composable
private fun ActionBlockCard(
    title: String,
    actionLabel: String,
    onAction: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    icon: ImageVector = Icons.Rounded.Link,
    supportingText: @Composable () -> Unit = {},
) {
    ElevatedCard(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.elevatedCardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.35f),
        ),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Column(
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                )
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                )
            }

            supportingText()

            Button(
                enabled = enabled,
                onClick = onAction,
            ) {
                Text(text = actionLabel)
            }
        }
    }
}

@Composable
private fun TextBlockBody(
    document: com.lambdadigamma.prosemirror.Document?,
    modifier: Modifier = Modifier,
) {
    document?.takeIf { !it.isBlank() }?.let {
        Column(modifier = modifier) {
            DocumentRenderer(document = it)
        }
    }
}

@Composable
private fun String?.blockColors(): Pair<Color, Color> {
    return when (this) {
        "red" -> Color(0xFFB3261E) to Color.White
        "yellow" -> Color(0xFFF9DE70) to Color(0xFF1D1B20)
        "pink" -> Color(0xFFD81B60) to Color.White
        "green" -> Color(0xFF2E7D32) to Color.White
        "orange" -> Color(0xFFF57C00) to Color.White
        "blue" -> Color(0xFF1565C0) to Color.White
        "black" -> Color(0xFF1D1B20) to Color.White
        else -> MaterialTheme.colorScheme.secondaryContainer to MaterialTheme.colorScheme.onSecondaryContainer
    }
}

private fun String?.blockIcon(): ImageVector {
    return when (this) {
        "youtube" -> Icons.Rounded.SmartDisplay
        "instagram", "facebook", "twitter", "spotify", "apple-music", "bandcamp" -> Icons.Rounded.Language
        "soundcloud" -> Icons.Rounded.MusicNote
        else -> Icons.Rounded.Link
    }
}
