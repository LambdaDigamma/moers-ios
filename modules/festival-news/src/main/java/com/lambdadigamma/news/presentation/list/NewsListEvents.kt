package com.lambdadigamma.news.presentation.list

sealed class NewsListEvents {
    data class ShowNews(val id: Int) : NewsListEvents()
    data class OpenExternalLink(val url: String) : NewsListEvents()
}
