package com.lambdadigamma.news.presentation.list

import java.util.Date

sealed class NewsListEvents {
    data class ShowNews(val id: Int) : NewsListEvents()
    data class OpenExternalLink(val url: String) : NewsListEvents()
    data class ShowRefreshError(
        val throwable: Throwable,
        val lastSuccessfulRefresh: Date?,
    ) : NewsListEvents()
}
