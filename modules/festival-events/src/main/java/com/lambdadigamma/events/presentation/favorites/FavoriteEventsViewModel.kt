package com.lambdadigamma.events.presentation.favorites

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.events.domain.usecase.GetFavoriteEventsUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import javax.inject.Inject

@HiltViewModel
class FavoriteEventsViewModel @Inject constructor(
    private val getFavoriteEventsUseCase: GetFavoriteEventsUseCase,
    savedStateHandle: SavedStateHandle,
    eventsInitialState: FavoriteEventsUiState,
): BaseViewModel<FavoriteEventsUiState, FavoriteEventsUiState.PartialState, FavoriteEventsEvents, FavoriteEventsIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventsInitialState,
) {

    init {
        acceptIntent(FavoriteEventsIntent.GetEvents)
    }

    override fun mapIntents(intent: FavoriteEventsIntent): Flow<FavoriteEventsUiState.PartialState> {

        return when (intent) {
            is FavoriteEventsIntent.GetEvents -> getEvents()
            is FavoriteEventsIntent.EventClicked -> eventClicked(intent.id)
            is FavoriteEventsIntent.SelectedSection -> selectedSection(intent.section)
        }

    }

    override fun reduceUiState(
        previousState: FavoriteEventsUiState,
        partialState: FavoriteEventsUiState.PartialState
    ): FavoriteEventsUiState = when (partialState) {
        is FavoriteEventsUiState.PartialState.Loading -> previousState.copy(
            isLoading = true,
            data = previousState.data.copy(),
            isError = null,
        )
        is FavoriteEventsUiState.PartialState.Fetched -> previousState.copy(
            isLoading = false,
            data = previousState.data.copy(sections = partialState.data.sections),
            isError = null,
        )
        is FavoriteEventsUiState.PartialState.Error -> previousState.copy(
            isLoading = false,
            data = previousState.data.copy(sections = emptyList(), currentIndex = 0),
            isError = partialState.throwable,
        )
    }

    private fun getEvents(): Flow<FavoriteEventsUiState.PartialState> = flow {
        getFavoriteEventsUseCase()
            .onStart {
                emit(FavoriteEventsUiState.PartialState.Loading)
            }
            .collect { result ->
                result
                    .onSuccess { data ->
                        emit(
                            FavoriteEventsUiState.PartialState.Fetched(
                            data = uiState.value.data.copy(sections = data.sections)
                        ))
                    }
                    .onFailure {
                        emit(FavoriteEventsUiState.PartialState.Error(it))
                    }
            }
    }

    private fun selectedSection(section: Int): Flow<FavoriteEventsUiState.PartialState> = flow {
//        println(section)
//        emit(
//            TimetableUiState.PartialState.Fetched(
//            data = uiState.value.data.copy(
//                currentIndex = section
//            )
//        ))
    }

    private fun eventClicked(id: Int): Flow<FavoriteEventsUiState.PartialState> {
//        if (uri.startsWith(HTTP_PREFIX) || uri.startsWith(HTTPS_PREFIX)) {
//            publishEvent(RocketsEvent.OpenWebBrowserWithDetails(uri))
//        }
        publishEvent(FavoriteEventsEvents.ShowEvent(id))

        return emptyFlow()
    }
}