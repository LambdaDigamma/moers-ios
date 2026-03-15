package com.lambdadigamma.events.presentation.download

sealed class DownloadEventsIntent {

    object GetEvents : DownloadEventsIntent()

    object RefreshEvents : DownloadEventsIntent()

    object DownloadContent: DownloadEventsIntent()

}