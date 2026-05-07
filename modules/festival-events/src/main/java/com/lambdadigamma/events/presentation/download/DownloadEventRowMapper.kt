package com.lambdadigamma.events.presentation.download

internal fun EventDownloadDisplayable.toRowState(): DownloadEventRowState {
    return DownloadEventRowState(
        name = name,
        contentState = if (hasPageDownloaded) {
            DownloadEventState.DOWNLOADED
        } else {
            DownloadEventState.NOT_DOWNLOADED
        },
        imageState = when {
            !hasMediaAvailable -> null
            hasMediaDownloaded -> DownloadEventState.DOWNLOADED
            else -> DownloadEventState.NOT_DOWNLOADED
        },
    )
}
