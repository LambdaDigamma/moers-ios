package com.lambdadigamma.events.presentation.download

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.pages.data.remote.model.PageBlock

internal fun Event.toDownloadDisplayable(
    mediaDownloadedEventIds: Set<Int> = emptySet(),
): EventDownloadDisplayable {
    val hasMediaAvailable = downloadMediaUrls().isNotEmpty()

    return EventDownloadDisplayable(
        id = id,
        name = name,
        hasPageDownloaded = page != null,
        hasMediaAvailable = hasMediaAvailable,
        hasMediaDownloaded = hasMediaAvailable && id in mediaDownloadedEventIds,
    )
}

internal fun Event.downloadMediaUrls(): List<String> {
    return buildList {
        addAll(mediaCollections.allMedia().mapNotNull { media -> media.fullUrl })

        page?.let { page ->
            addAll(page.mediaCollections.allMedia().mapNotNull { media -> media.fullUrl })
            addAll(page.blocks.flatMap(PageBlock::downloadMediaUrls))
        }
    }.distinct()
}

private fun PageBlock.downloadMediaUrls(): List<String> {
    return buildList {
        addAll(mediaCollections?.allMedia().orEmpty().mapNotNull { media -> media.fullUrl })
        addAll(children.flatMap(PageBlock::downloadMediaUrls))
    }
}
