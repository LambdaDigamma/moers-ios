package com.lambdadigamma.news.presentation.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.news.domain.usecase.GetPostDetailUseCase
import com.lambdadigamma.news.domain.usecase.RefreshPostUseCase
import com.lambdadigamma.news.presentation.mapper.toPresentationModel
import com.lambdadigamma.pages.domain.usecase.GetPageUseCase
import com.lambdadigamma.pages.domain.usecase.RefreshPageUseCase
import dagger.assisted.Assisted
import dagger.assisted.AssistedFactory
import dagger.assisted.AssistedInject
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart

@HiltViewModel(assistedFactory = PostDetailViewModel.Factory::class)
class PostDetailViewModel @AssistedInject constructor(
    private val getPostDetailUseCase: GetPostDetailUseCase,
    private val refreshPostUseCase: RefreshPostUseCase,
    private val getPageUseCase: GetPageUseCase,
    private val refreshPageUseCase: RefreshPageUseCase,
    savedStateHandle: SavedStateHandle,
    @param:Assisted private val postId: Int,
    eventDetailInitialState: PostDetailUiState,
): BaseViewModel<PostDetailUiState, PostDetailUiState.PartialState, PostDetailEvents, PostDetailIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventDetailInitialState,
) {

    init {
        acceptIntent(PostDetailIntent.GetData)
    }

    override fun mapIntents(intent: PostDetailIntent): Flow<PostDetailUiState.PartialState> {
        return when (intent) {
            is PostDetailIntent.GetData -> getData()
            is PostDetailIntent.RefreshPost -> refresh()
            else -> {
                flow { }
            }
        }
    }

    override fun reduceUiState(
        previousState: PostDetailUiState,
        partialState: PostDetailUiState.PartialState
    ): PostDetailUiState {
        return when (partialState) {
            is PostDetailUiState.PartialState.Loading -> previousState.copy(
                isLoading = true,
                isError = null,
            )
            is PostDetailUiState.PartialState.Fetched -> previousState.copy(
                isLoading = false,
                post = partialState.post,
                isError = null,
            )
            is PostDetailUiState.PartialState.Error -> previousState.copy(
                isLoading = false,
                isError = partialState.throwable,
            )
        }
    }

    // Actions

    private fun getData(): Flow<PostDetailUiState.PartialState> = flow {
        getPostDetailUseCase(postId)
            .onStart {
                emit(PostDetailUiState.PartialState.Loading)
            }
            .collect { result ->
                result
                    .onSuccess { post ->
                        if (post != null) {
                            val detailData = post.post.toPresentationModel()
                            detailData.blocks = post.page?.blocks ?: emptyList()
                            emit(PostDetailUiState.PartialState.Fetched(detailData))
                        } else {
                            emit(PostDetailUiState.PartialState.Loading)
                            acceptIntent(PostDetailIntent.RefreshPost)
                        }
                    }
                    .onFailure {
                        emit(PostDetailUiState.PartialState.Error(it))
                    }
            }
    }

    private fun refresh(): Flow<PostDetailUiState.PartialState> = flow {
        refreshPostUseCase(postId)
            .onFailure {
                emit(PostDetailUiState.PartialState.Error(it))
            }

    }

    // MARK: - Page

    @AssistedFactory
    interface Factory {
        fun create(postId: Int): PostDetailViewModel
    }

}
