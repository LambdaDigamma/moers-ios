package com.lambdadigamma.newsfeature.data

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface NewsDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertNews(news: List<RssItem>): List<Long>

    @Query("SELECT * FROM rss_items")
    fun getNews(): LiveData<List<RssItem>>

    @Query("SELECT * FROM rss_items WHERE id = :id")
    fun getRssItem(id: Long): LiveData<RssItem>

}