package com.lambdadigamma.newsfeature.data

import androidx.room.Entity
import androidx.room.PrimaryKey

/** A news article from a local news feed. */
@Entity(tableName = "news_articles")
data class NewsArticle(
    /** The feed's guid, or the article link when the feed has no guid. */
    @PrimaryKey val id: String,
    val title: String,
    val link: String,
    val summary: String?,
    val imageUrl: String?,
    /** Publication time in epoch milliseconds. */
    val publishedAt: Long?,
    val source: String,
)
