package com.lambdadigamma.news.data.local.dao

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Upsert
import com.lambdadigamma.events.data.local.model.EventCached
import com.lambdadigamma.events.data.local.model.EventWithPlaceAndPageCached
import com.lambdadigamma.events.data.local.model.EventWithPlaceCached
import com.lambdadigamma.events.data.local.model.FavoriteEventInfoCached
import com.lambdadigamma.events.data.local.model.LikedEventCached
import com.lambdadigamma.news.data.local.models.PostCached
import com.lambdadigamma.news.data.local.models.PostWithPageCached
import kotlinx.coroutines.flow.Flow

@Dao
interface PostDao {

    @Query("SELECT * FROM posts")
    fun getPosts(): Flow<List<PostCached>>

    @Transaction
    @Query("SELECT * FROM posts WHERE id = :postId")
    fun getPost(postId: Int): Flow<PostWithPageCached?>

    @Upsert
    suspend fun savePosts(posts: List<PostCached>)

}