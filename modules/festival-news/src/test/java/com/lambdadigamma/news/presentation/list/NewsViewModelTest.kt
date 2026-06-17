package com.lambdadigamma.news.presentation.list

import androidx.lifecycle.SavedStateHandle
import app.cash.turbine.test
import com.lambdadigamma.core.refresh.FakeRefreshMetadataStore
import com.lambdadigamma.core.refresh.RefreshMetadataKey
import com.lambdadigamma.core.refresh.RefreshMetadataStore
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.news.domain.usecase.GetPostsUseCase
import com.lambdadigamma.news.domain.usecase.RefreshPostsUseCase
import com.lambdadigamma.news.presentation.PostDisplayable
import com.lambdadigamma.news.presentation.PostType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import java.io.IOException
import java.util.Date
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertIs
import kotlin.test.assertNull

@OptIn(ExperimentalCoroutinesApi::class)
class NewsViewModelTest {

    private val dispatcher = UnconfinedTestDispatcher()

    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `should keep cached posts and emit refresh error when refresh fails`() = runTest(dispatcher) {
        val cachedPosts = listOf(postDisplayable(id = 1))
        val throwable = IOException("Network unavailable")
        val lastSuccessfulRefresh = Date(123_456L)
        val objectUnderTest = buildViewModel(
            posts = cachedPosts,
            refreshResult = Result.failure(throwable),
            refreshMetadataStore = FakeRefreshMetadataStore(
                mutableMapOf(RefreshMetadataKey.NEWS to lastSuccessfulRefresh),
            ),
        )
        advanceUntilIdle()

        objectUnderTest.event.test {
            objectUnderTest.acceptIntent(NewsListIntent.RefreshNews)
            advanceUntilIdle()

            assertEquals(cachedPosts, objectUnderTest.uiState.value.data.items)
            assertFalse(objectUnderTest.uiState.value.isRefreshing)
            assertNull(objectUnderTest.uiState.value.isError)
            assertEquals(
                NewsListEvents.ShowRefreshError(throwable, lastSuccessfulRefresh),
                awaitItem(),
            )
            expectNoEvents()
        }
    }

    @Test
    fun `should emit refresh error without timestamp when timestamp read fails`() = runTest(dispatcher) {
        val cachedPosts = listOf(postDisplayable(id = 1))
        val throwable = IOException("Network unavailable")
        val objectUnderTest = buildViewModel(
            posts = cachedPosts,
            refreshResult = Result.failure(throwable),
            refreshMetadataStore = FakeRefreshMetadataStore(
                readFailure = IOException("DataStore unavailable"),
            ),
        )
        advanceUntilIdle()

        objectUnderTest.event.test {
            objectUnderTest.acceptIntent(NewsListIntent.RefreshNews)
            advanceUntilIdle()

            val event = assertIs<NewsListEvents.ShowRefreshError>(awaitItem())
            assertEquals(throwable, event.throwable)
            assertNull(event.lastSuccessfulRefresh)
            expectNoEvents()
        }
    }

    @Test
    fun `should expose retryable error when refresh fails without cached posts`() = runTest(dispatcher) {
        val throwable = IOException("Network unavailable")
        val objectUnderTest = buildViewModel(
            posts = emptyList(),
            refreshResult = Result.failure(throwable),
        )
        advanceUntilIdle()

        objectUnderTest.event.test {
            objectUnderTest.acceptIntent(NewsListIntent.RefreshNews)
            advanceUntilIdle()

            assertEquals(emptyList(), objectUnderTest.uiState.value.data.items)
            assertFalse(objectUnderTest.uiState.value.isRefreshing)
            assertEquals(throwable, objectUnderTest.uiState.value.isError)
            expectNoEvents()
        }
    }

    private fun buildViewModel(
        posts: List<PostDisplayable>,
        refreshResult: Result<Unit>,
        refreshMetadataStore: RefreshMetadataStore = FakeRefreshMetadataStore(),
    ): NewsViewModel {
        val postsFlow = MutableStateFlow(Result.success(posts))

        return NewsViewModel(
            savedStateHandle = SavedStateHandle(),
            eventsInitialState = NewsListUiState(),
            refreshPostsUseCase = RefreshPostsUseCase { refreshResult },
            getPostsUseCase = GetPostsUseCase { postsFlow },
            refreshMetadataStore = refreshMetadataStore,
        )
    }

    private fun postDisplayable(id: Int): PostDisplayable {
        return PostDisplayable(
            id = id,
            title = "Post $id",
            summary = "Summary $id",
            type = PostType.DEFAULT,
            pageId = id,
            externalHref = null,
            mediaCollections = MediaCollectionsContainer(),
            publishedAt = Date(id * 1_000L),
        )
    }
}
