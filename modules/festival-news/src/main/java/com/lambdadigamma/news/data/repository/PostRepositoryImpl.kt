package com.lambdadigamma.news.data.repository

import android.icu.text.SimpleDateFormat
import com.lambdadigamma.events.data.calculateDateRange
import com.lambdadigamma.events.data.local.dao.PlaceDao
import com.lambdadigamma.events.data.local.model.LikedEventCached
import com.lambdadigamma.events.data.mapper.toDomainModel
import com.lambdadigamma.events.data.mapper.toEntity
import com.lambdadigamma.events.data.mapper.toEntityModel
import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.domain.models.EventDetailData
import com.lambdadigamma.events.domain.repository.EventRepository
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsData
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsSection
import com.lambdadigamma.events.presentation.mapper.toPresentationModel
import com.lambdadigamma.events.presentation.timetable.TimetableData
import com.lambdadigamma.events.presentation.timetable.TimetableSection
import com.lambdadigamma.news.data.local.dao.PostDao
import com.lambdadigamma.news.data.mapper.toDomainModel
import com.lambdadigamma.news.data.mapper.toEntityModel
import com.lambdadigamma.news.data.remote.api.PostService
import com.lambdadigamma.news.data.remote.model.Post
import com.lambdadigamma.news.data.remote.model.PostId
import com.lambdadigamma.news.domain.models.PostDetailData
import com.lambdadigamma.news.domain.repository.PostRepository
import com.lambdadigamma.news.presentation.PostDisplayable
import com.lambdadigamma.news.presentation.mapper.toPresentationModel
import com.lambdadigamma.pages.data.local.dao.PageDao
import com.lambdadigamma.pages.data.mapper.toDomainModel
import com.lambdadigamma.pages.data.mapper.toEntityModel
import com.lambdadigamma.pages.domain.repository.PageRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map
import timber.log.Timber
import java.util.Date
import java.util.Locale
import javax.inject.Inject

class PostRepositoryImpl @Inject constructor(
    private val postApi: PostService,
    private val postDao: PostDao,
    private val pageRepository: PageRepository,
    private val pageDao: PageDao
) : PostRepository {

    companion object {
        private const val FESTIVAL_NEWS_FEED_ID = 3
    }

    override fun getPost(postId: PostId): Flow<PostDetailData?> {

        return postDao.getPost(postId)
            .map { postCached ->

                if (postCached == null) {
                    return@map null
                }

                val post = postCached.post.toDomainModel()

                return@map PostDetailData(
                    post = post,
                    page = postCached.page?.toDomainModel()
                )

            }
            .flatMapLatest { data ->

                val pageId = data?.post?.pageId ?: return@flatMapLatest flowOf(data)

                return@flatMapLatest pageRepository
                    .getPage(pageId)
                    .map { page ->
                        data.copy(page = page)
                    }
                    .catch { error ->
                        Timber.e(error)
                        flowOf(data)
                    }

            }
    }

    override fun getPosts(): Flow<List<PostDisplayable>> {
        return postDao.getPosts()
            .map { posts ->
                posts.map {
                    it.toDomainModel().apply {
//                        place = item.place?.toDomainModel()
//                        isFavorite = item.isLiked // item.favoriteEvent != null
                    }.toPresentationModel()
                }.sortedByDescending { it.publishedAt }
            }

    }

    override suspend fun refreshPosts() {
        postApi
            .getFestivalNews(size = 20, page = 1)
            .data
            .map { post ->
                if (post.feedId == 0) {
                    post.copy(feedId = FESTIVAL_NEWS_FEED_ID)
                } else {
                    post
                }
            }
            .also { posts ->
                save(posts)
            }
    }

    override suspend fun refreshPost(postId: PostId) {
        postApi
            .getPost(postId)
            .data
            .also { post ->
                save(listOf(post))
            }
    }

    private suspend fun save(posts: List<Post>) {

        postDao.savePosts(posts.map { it.toEntityModel() })

        posts.mapNotNull { it.page }.let { pages ->
            pageDao.savePages(pages.map { it.toEntityModel() })

            val pageBlocks = pages
                .flatMap { it.blocks }
                .map { it.toEntityModel() }

            pageDao.savePageBlocks(pageBlocks)
        }

//        eventDao.deleteAllEvents()
//
//        val pages = events
//            .mapNotNull { it.page?.toEntityModel() }
//
//        if (pages.isEmpty()) {
//            return
//        } else {
//            // TODO: This may be not the best option
//            // Instead of deleting all pages and blocks, only delete the ones that are in the database.
//            pageDao.deletePageBlocksByPageIds(pages.map { it.id })
//
//            val pageBlocks = events
//                .flatMap { it.page?.blocks ?: emptyList() }
//                .map { it.toEntityModel() }
//
//            pageDao.savePages(pages)
//            pageDao.savePageBlocks(pageBlocks)
//
//        }
    }
}
