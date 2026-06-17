package com.lambdadigamma.news.data.repository

import app.cash.turbine.test
import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.core.refresh.FakeRefreshMetadataStore
import com.lambdadigamma.core.refresh.RefreshMetadataKey
import com.lambdadigamma.core.refresh.RefreshMetadataStore
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.news.data.local.dao.PostDao
import com.lambdadigamma.news.data.local.models.PostCached
import com.lambdadigamma.news.data.local.models.PostWithPageCached
import com.lambdadigamma.news.data.remote.api.PostService
import com.lambdadigamma.news.data.remote.model.Post
import com.lambdadigamma.pages.data.local.dao.PageDao
import com.lambdadigamma.pages.data.local.model.PageCached
import com.lambdadigamma.pages.data.remote.model.Page
import com.lambdadigamma.pages.domain.repository.PageRepository
import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import java.io.IOException
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class PostRepositoryImplTest {

    private val postApi = mockk<PostService>(relaxed = true)
    private val postDao = mockk<PostDao>()
    private val pageRepository = mockk<PageRepository>()
    private val pageDao = mockk<PageDao>(relaxed = true)

    @Test
    fun `getPost emits cached metadata with empty page blocks when page repository fails`() = runTest {
        val postId = 13
        val pageId = 8
        every { postDao.getPost(postId) } returns flowOf(
            PostWithPageCached(
                post = PostCached(
                    id = postId,
                    title = "Cached post",
                    summary = "Cached summary",
                    feedId = 3,
                    pageId = pageId,
                    vimeoId = "",
                    publication = "",
                    externalHref = "",
                    extras = null,
                    mediaCollections = MediaCollectionsContainer(),
                    publishedAt = null,
                    createdAt = null,
                    updatedAt = null,
                    deletedAt = null,
                ),
                page = PageCached(
                    id = pageId,
                    title = "Cached page",
                ),
            ),
        )
        every { pageRepository.getPage(pageId) } returns flow<Page?> {
            throw IOException("Page refresh failed")
        }

        val repository = buildRepository()

        repository.getPost(postId).test {
            val detail = awaitItem()

            assertEquals(postId, detail?.post?.id)
            assertEquals("Cached post", detail?.post?.title)
            assertEquals(pageId, detail?.page?.id)
            assertEquals("Cached page", detail?.page?.title)
            assertTrue(detail?.page?.blocks?.isEmpty() == true)
            awaitComplete()
        }
    }

    @Test
    fun `refreshPosts marks news refresh after successful cache save`() = runTest {
        val refreshMetadataStore = FakeRefreshMetadataStore()
        coEvery { postApi.getFestivalNews(size = 20, page = 1) } returns DataResponse(
            listOf(post()),
        )
        coEvery { postDao.savePosts(any()) } returns Unit

        buildRepository(refreshMetadataStore).refreshPosts()

        assertEquals(listOf(RefreshMetadataKey.NEWS), refreshMetadataStore.markedKeys)
    }

    @Test
    fun `refreshPosts does not mark news refresh when cache save fails`() = runTest {
        val refreshMetadataStore = FakeRefreshMetadataStore()
        coEvery { postApi.getFestivalNews(size = 20, page = 1) } returns DataResponse(
            listOf(post()),
        )
        coEvery { postDao.savePosts(any()) } throws IOException("Database unavailable")

        runCatching {
            buildRepository(refreshMetadataStore).refreshPosts()
        }

        assertEquals(emptyList(), refreshMetadataStore.markedKeys)
    }

    @Test
    fun `refreshPosts succeeds when timestamp write fails`() = runTest {
        val refreshMetadataStore = FakeRefreshMetadataStore(
            writeFailure = IOException("DataStore unavailable"),
        )
        coEvery { postApi.getFestivalNews(size = 20, page = 1) } returns DataResponse(
            listOf(post()),
        )
        coEvery { postDao.savePosts(any()) } returns Unit

        val result = runCatching {
            buildRepository(refreshMetadataStore).refreshPosts()
        }

        assertTrue(result.isSuccess)
    }

    private fun buildRepository(
        refreshMetadataStore: RefreshMetadataStore = FakeRefreshMetadataStore(),
    ): PostRepositoryImpl {
        return PostRepositoryImpl(
            postApi = postApi,
            postDao = postDao,
            pageRepository = pageRepository,
            pageDao = pageDao,
            refreshMetadataStore = refreshMetadataStore,
        )
    }

    private fun post(): Post {
        return Post(
            id = 1,
            title = "Remote post",
            summary = "Remote summary",
            feedId = 3,
            pageId = 1,
        )
    }
}
