package com.lambdadigamma.events.presentation.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.events.domain.usecase.GetEventDetailUseCase
import com.lambdadigamma.events.domain.usecase.ToggleFavoriteEventUseCase
import com.lambdadigamma.events.presentation.mapper.toDetailPresentationModel
import com.lambdadigamma.events.presentation.mapper.toPresentationModel
import dagger.assisted.Assisted
import dagger.assisted.AssistedFactory
import dagger.assisted.AssistedInject
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch

@HiltViewModel(assistedFactory = EventDetailViewModel.Factory::class)
class EventDetailViewModel @AssistedInject constructor(
    private val getEventDetailUseCase: GetEventDetailUseCase,
    private val toggleFavoriteEvent: ToggleFavoriteEventUseCase,
    savedStateHandle: SavedStateHandle,
    @param:Assisted private val eventId: Int,
    eventDetailInitialState: EventDetailUiState,
): BaseViewModel<EventDetailUiState, EventDetailUiState.PartialState, EventDetailEvents, EventDetailIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventDetailInitialState,
) {

    init {
        acceptIntent(EventDetailIntent.GetData)
    }

    override fun mapIntents(intent: EventDetailIntent): Flow<EventDetailUiState.PartialState> {
        return when (intent) {
            is EventDetailIntent.GetData -> getData()
            else -> {
                flow { }
            }
        }
    }

    override fun reduceUiState(
        previousState: EventDetailUiState,
        partialState: EventDetailUiState.PartialState
    ): EventDetailUiState {
        return when (partialState) {
            is EventDetailUiState.PartialState.Loading -> previousState.copy(
                isLoading = true,
                isError = null,
            )
            is EventDetailUiState.PartialState.Fetched -> previousState.copy(
                isLoading = false,
                event = partialState.event,
                isError = null,
            )
            is EventDetailUiState.PartialState.Error -> previousState.copy(
                isLoading = false,
                isError = partialState.throwable,
            )
        }
    }

    // Actions

    private fun getData(): Flow<EventDetailUiState.PartialState> = flow {
        getEventDetailUseCase(eventId)
            .onStart {
                emit(EventDetailUiState.PartialState.Loading)
            }
            .collect { result ->
                result
                    .onSuccess { event ->
                        val model = event?.toPresentationModel()
                        if (model != null) {
                            emit(EventDetailUiState.PartialState.Fetched(model))
                        } else {
                            emit(EventDetailUiState.PartialState.Loading)
                        }
                    }
                    .onFailure {
                        emit(EventDetailUiState.PartialState.Error(it))
                    }
            }
    }

    fun toggleFavorite() {

        viewModelScope.launch {
            toggleFavoriteEvent(eventId)
        }

    }

    @AssistedFactory
    interface Factory {
        fun create(eventId: Int): EventDetailViewModel
    }

}
