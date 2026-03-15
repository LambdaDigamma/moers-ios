package com.lambdadigamma.news.domain.repository

import com.lambdadigamma.news.data.remote.model.Post
import com.lambdadigamma.news.data.remote.model.PostId
import com.lambdadigamma.news.domain.models.PostDetailData
import com.lambdadigamma.news.presentation.PostDisplayable
import kotlinx.coroutines.flow.Flow

interface PostRepository {

    /**
     * Get a specific post.
     */
    fun getPost(postId: PostId): Flow<PostDetailData?>

    /**
     * Get posts.
     */
    fun getPosts(): Flow<List<PostDisplayable>>

    suspend fun refreshPosts()

    suspend fun refreshPost(postId: PostId)

}