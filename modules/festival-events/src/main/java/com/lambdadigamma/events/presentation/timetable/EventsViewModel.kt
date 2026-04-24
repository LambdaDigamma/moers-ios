package com.lambdadigamma.events.presentation.timetable

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.events.domain.usecase.GetEventsUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.events.presentation.mapper.toPresentationModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import javax.inject.Inject

@HiltViewModel
class EventsViewModel @Inject constructor(
    private val getEventsUseCase: GetEventsUseCase,
    private val refreshEventsUseCase: RefreshEventsUseCase,
    savedStateHandle: SavedStateHandle,
    eventsInitialState: EventsUiState,
): BaseViewModel<EventsUiState, EventsUiState.PartialState, TimetableEvents, TimetableIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventsInitialState,
) {

    init {
        acceptIntent(TimetableIntent.GetEvents)
    }

    override fun mapIntents(intent: TimetableIntent): Flow<EventsUiState.PartialState> {

        return when (intent) {
            is TimetableIntent.GetEvents -> getEvents()
            is TimetableIntent.RefreshEvents -> refreshEvents()
            is TimetableIntent.EventClicked -> eventClicked(intent.id)
            is TimetableIntent.SelectedSection -> flow {}
            else -> emptyFlow()
        }

    }

    override fun reduceUiState(
        previousState: EventsUiState,
        partialState: EventsUiState.PartialState
    ): EventsUiState {

        if (previousState.events.isNotEmpty() && partialState is EventsUiState.PartialState.Loading) {
            return previousState.copy(
                isLoading = false,
                isError = null,
            )
        }

        return when (partialState) {
            is EventsUiState.PartialState.Loading -> previousState.copy(
                isLoading = true,
                isError = null,
            )

            is EventsUiState.PartialState.Fetched -> previousState.copy(
                isLoading = false,
                events = partialState.list,
                isError = null,
            )

            is EventsUiState.PartialState.Error -> previousState.copy(
                isLoading = false,
                isError = partialState.throwable,
            )
        }
    }

    private fun getEvents(): Flow<EventsUiState.PartialState> = flow {
        getEventsUseCase()
            .onStart {
                emit(EventsUiState.PartialState.Loading)
            }
            .collect { result ->
                result
                    .onSuccess { eventList ->
                        emit(EventsUiState.PartialState.Fetched(eventList.map { it.toPresentationModel() }))
                    }
                    .onFailure {
                        emit(EventsUiState.PartialState.Error(it))
                    }
            }
    }

    private fun refreshEvents(): Flow<EventsUiState.PartialState> = flow {
        refreshEventsUseCase()
            .onFailure {
                emit(EventsUiState.PartialState.Error(it))
            }
    }

    private fun eventClicked(id: Int): Flow<EventsUiState.PartialState> {
//        if (uri.startsWith(HTTP_PREFIX) || uri.startsWith(HTTPS_PREFIX)) {
//            publishEvent(RocketsEvent.OpenWebBrowserWithDetails(uri))
//        }
        publishEvent(TimetableEvents.ShowEvent(id))

        return emptyFlow()
    }
}
