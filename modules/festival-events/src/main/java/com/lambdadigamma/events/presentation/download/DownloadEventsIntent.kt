package com.lambdadigamma.events.presentation.download

sealed class DownloadEventsIntent {

    object GetEvents : DownloadEventsIntent()

    object RefreshEvents : DownloadEventsIntent()

    data class DownloadContent(
        val includeContent: Boolean,
        val includeMedia: Boolean,
    ) : DownloadEventsIntent()

}
