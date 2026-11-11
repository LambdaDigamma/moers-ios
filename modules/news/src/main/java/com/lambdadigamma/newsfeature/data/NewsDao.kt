package com.lambdadigamma.newsfeature.data

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Upsert
import kotlinx.coroutines.flow.Flow

@Dao
abstract class NewsDao {

    @Query("SELECT * FROM news_articles ORDER BY publishedAt DESC")
    abstract fun observeArticles(): Flow<List<NewsArticle>>

    @Upsert
    abstract suspend fun upsert(articles: List<NewsArticle>)

    @Query("DELETE FROM news_articles WHERE id NOT IN (:ids)")
    abstract suspend fun deleteAllExcept(ids: List<String>)

    @Transaction
    open suspend fun replaceAll(articles: List<NewsArticle>) {
        upsert(articles)
        deleteAllExcept(articles.map { it.id })
    }

}
