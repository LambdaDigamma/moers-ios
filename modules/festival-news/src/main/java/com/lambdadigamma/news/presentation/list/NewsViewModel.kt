package com.lambdadigamma.news.presentation.list

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.core.refresh.RefreshMetadataKey
import com.lambdadigamma.core.refresh.RefreshMetadataStore
import com.lambdadigamma.news.domain.usecase.GetPostsUseCase
import com.lambdadigamma.news.domain.usecase.RefreshPostsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import timber.log.Timber
import javax.inject.Inject

@HiltViewModel
class NewsViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    eventsInitialState: NewsListUiState,
    private val refreshPostsUseCase: RefreshPostsUseCase,
    private val getPostsUseCase: GetPostsUseCase,
    private val refreshMetadataStore: RefreshMetadataStore,
): BaseViewModel<NewsListUiState, NewsListUiState.PartialState, NewsListEvents, NewsListIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventsInitialState,
) {

    init {
        acceptIntent(NewsListIntent.GetNews)
    }

    override fun mapIntents(intent: NewsListIntent): Flow<NewsListUiState.PartialState> {

        return when (intent) {
            is NewsListIntent.GetNews -> getNews()
            is NewsListIntent.RefreshNews -> refreshNews()
            is NewsListIntent.ShowPost -> showPost(intent.id)
            is NewsListIntent.OpenExternalPost -> openExternalPost(intent.url)
        }

    }

    override fun reduceUiState(
        previousState: NewsListUiState,
        partialState: NewsListUiState.PartialState
    ): NewsListUiState {

        return when (partialState) {
            is NewsListUiState.PartialState.Loading -> previousState.copy(
                isLoading = true,
                isError = null,
            )
            is NewsListUiState.PartialState.Fetched -> previousState.copy(
                isLoading = false,
                isRefreshing = false,
                data = partialState.data,
                isError = null,
            )
            is NewsListUiState.PartialState.Error -> previousState.copy(
                isLoading = false,
                isRefreshing = false,
                isError = partialState.throwable,
            )
            NewsListUiState.PartialState.Refreshing -> previousState.copy(
                isLoading = false,
                isRefreshing = true,
                isError = null,
            )
            is NewsListUiState.PartialState.RefreshFailed -> previousState.copy(
                isLoading = false,
                isRefreshing = false,
            )
            NewsListUiState.PartialState.RefreshFinished -> previousState.copy(
                isLoading = false,
                isRefreshing = false,
                isError = null,
            )
        }

    }

    private fun getNews(): Flow<NewsListUiState.PartialState> = flow {
        getPostsUseCase()
            .onStart {
                emit(NewsListUiState.PartialState.Loading)
            }
            .collect { result ->
                result
                    .onSuccess { data ->
                        emit(NewsListUiState.PartialState.Fetched(
                            data = NewsListData(items = data)
                        ))
                    }
                    .onFailure {
                        emit(NewsListUiState.PartialState.Error(it))
                    }
            }
    }

    private fun refreshNews(): Flow<NewsListUiState.PartialState> = flow {
        emit(NewsListUiState.PartialState.Refreshing)
        refreshPostsUseCase()
            .onSuccess {
                emit(NewsListUiState.PartialState.RefreshFinished)
            }
            .onFailure { throwable ->
                if (uiState.value.data.items.isNotEmpty()) {
                    publishEvent(NewsListEvents.ShowRefreshError(
                        throwable = throwable,
                        lastSuccessfulRefresh = getLastSuccessfulRefresh(),
                    ))
                    emit(NewsListUiState.PartialState.RefreshFailed(throwable))
                } else {
                    emit(NewsListUiState.PartialState.Error(throwable))
                }
            }
    }

    private suspend fun getLastSuccessfulRefresh() = runCatching {
        refreshMetadataStore.getLastSuccessfulRefresh(RefreshMetadataKey.NEWS)
    }.getOrElse { throwable ->
        Timber.w(throwable, "Failed to read news refresh timestamp.")
        null
    }

    private fun showPost(id: Int): Flow<NewsListUiState.PartialState> {
//        if (uri.startsWith(HTTP_PREFIX) || uri.startsWith(HTTPS_PREFIX)) {
//            publishEvent(RocketsEvent.OpenWebBrowserWithDetails(uri))
//        }
        publishEvent(NewsListEvents.ShowNews(id))

        return emptyFlow()
    }

    private fun openExternalPost(url: String): Flow<NewsListUiState.PartialState> {
        publishEvent(NewsListEvents.OpenExternalLink(url))

        return emptyFlow()
    }

}
