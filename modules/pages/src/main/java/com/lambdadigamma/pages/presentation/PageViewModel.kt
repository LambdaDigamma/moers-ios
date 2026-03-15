package com.lambdadigamma.pages.presentation

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.pages.domain.usecase.GetPageUseCase
import com.lambdadigamma.pages.domain.usecase.RefreshPageUseCase
import com.lambdadigamma.pages.domain.usecase.refreshPage
import com.lambdadigamma.pages.presentation.mapper.toPresentationModel
import dagger.assisted.Assisted
import dagger.assisted.AssistedFactory
import dagger.assisted.AssistedInject
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import javax.inject.Inject


@HiltViewModel(/*assistedFactory = PageViewModel.Factory::class*/)
class PageViewModel @Inject constructor(
//    @Assisted val pageId: Int,
    private val getPageUseCase: GetPageUseCase,
    private val refreshPageUseCase: RefreshPageUseCase,
//    savedStateHandle: SavedStateHandle,
    pageInitialState: PageViewUiState,
): ViewModel() /*: BaseViewModel<PageViewUiState, PageViewUiState.PartialState, PageEvents, PageIntent>(
    savedStateHandle = savedStateHandle,
    initialState = pageInitialState,
)*/ {

//    @AssistedFactory
//    interface Factory {
//        fun create(pageId: Int): PageViewModel
//    }

//    init {
//        acceptIntent(PageIntent.GetData)
//    }
//
//    override fun mapIntents(intent: PageIntent): Flow<PageViewUiState.PartialState> {
//        return when (intent) {
//            is PageIntent.GetData -> {
//                getData()
//            }
//
//            is PageIntent.RefreshPage -> {
//                refresh()
//            }
//        }
//    }
//
//    override fun reduceUiState(
//        previousState: PageViewUiState,
//        partialState: PageViewUiState.PartialState
//    ): PageViewUiState {
//        return when (partialState) {
//            is PageViewUiState.PartialState.Loading -> previousState.copy(
//                isLoading = true,
//                isError = null,
//            )
//            is PageViewUiState.PartialState.Fetched -> previousState.copy(
//                isLoading = false,
//                page = partialState.page,
//                isError = null,
//            )
//            is PageViewUiState.PartialState.Error -> previousState.copy(
//                isLoading = false,
//                isError = partialState.throwable,
//            )
//        }
//    }
//
//    private fun getData(): Flow<PageViewUiState.PartialState> = flow {
//        getPageUseCase(pageId)
//            .onStart {
//                emit(PageViewUiState.PartialState.Loading)
//            }
//            .collect { result ->
//                result
//                    .onSuccess { post ->
//                        if (post != null) {
//                            emit(PageViewUiState.PartialState.Fetched(post.toPresentationModel()))
//                        } else {
//                            emit(PageViewUiState.PartialState.Loading)
//                            acceptIntent(PageIntent.RefreshPage)
//                        }
//                    }
//                    .onFailure {
//                        emit(PageViewUiState.PartialState.Error(it))
//                    }
//            }
//    }
//
//    private fun refresh(): Flow<PageViewUiState.PartialState> = flow {
//        refreshPageUseCase(pageId)
//            .onFailure {
//                emit(PageViewUiState.PartialState.Error(it))
//            }
//
//    }


}