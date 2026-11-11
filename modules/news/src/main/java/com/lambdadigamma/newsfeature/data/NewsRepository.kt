package com.lambdadigamma.newsfeature.data

import com.lambdadigamma.core.extensions.resultOf
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import javax.inject.Inject

/** A local news feed shown in the news tab. */
data class NewsSource(val name: String, val url: String)

class NewsRepository @Inject constructor(
    private val newsDao: NewsDao,
    private val newsService: NewsService,
) {

    val articles: Flow<List<NewsArticle>> = newsDao.observeArticles()

    suspend fun refresh(): Result<Unit> = resultOf {
        val articles = SOURCES.flatMap { source ->
            val body = newsService.feed(source.url)
            withContext(Dispatchers.Default) {
                body.byteStream().use { RssParser.parse(it, source.name) }
            }
        }
        newsDao.replaceAll(articles)
    }

    companion object {
        /**
         * The Lokalkompass Moers feed now redirects to an unrelated e-paper feed and the NRZ
         * feed returns 404, so RP Online is the only source, as in the iOS app.
         */
        val SOURCES = listOf(
            NewsSource("RP Online", "https://rp-online.de/nrw/staedte/moers/feed.rss"),
        )
    }
}
