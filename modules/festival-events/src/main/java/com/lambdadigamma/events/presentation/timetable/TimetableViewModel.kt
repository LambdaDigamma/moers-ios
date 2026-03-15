package com.lambdadigamma.events.presentation.timetable

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.events.domain.usecase.GetEventsUseCase
import com.lambdadigamma.events.domain.usecase.GetTimetableUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import java.util.Date
import javax.inject.Inject

@HiltViewModel
class TimetableViewModel @Inject constructor(
    private val getEventsUseCase: GetEventsUseCase,
    private val getTimetableUseCase: GetTimetableUseCase,
    private val refreshEventsUseCase: RefreshEventsUseCase,
    savedStateHandle: SavedStateHandle,
    eventsInitialState: TimetableUiState,
): BaseViewModel<TimetableUiState, TimetableUiState.PartialState, TimetableEvents, TimetableIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventsInitialState,
) {

    init {
        acceptIntent(TimetableIntent.GetEvents)
    }

    override fun mapIntents(intent: TimetableIntent): Flow<TimetableUiState.PartialState> {

        return when (intent) {
            is TimetableIntent.GetEvents -> getEvents()
            is TimetableIntent.RefreshEvents -> refreshEvents()
            is TimetableIntent.EventClicked -> eventClicked(intent.id)
            is TimetableIntent.SelectedSection -> selectedSection(intent.section)
        }

    }

    override fun reduceUiState(
        previousState: TimetableUiState,
        partialState: TimetableUiState.PartialState
    ): TimetableUiState {

        return when (partialState) {
            is TimetableUiState.PartialState.Loading -> previousState.copy(
                isLoading = true,
                isError = null,
            )
            is TimetableUiState.PartialState.Fetched -> previousState.copy(
                isLoading = false,
                data = partialState.data.copy(sections = partialState.data.sections),
                isError = null,
            )
            is TimetableUiState.PartialState.Error -> previousState.copy(
                isLoading = false,
                data = previousState.data.copy(sections = emptyList(), currentIndex = 0),
                isError = partialState.throwable,
            )
        }
    }

    private fun getEvents(): Flow<TimetableUiState.PartialState> = flow {
        getTimetableUseCase()
            .onStart {
                emit(TimetableUiState.PartialState.Loading)
            }
            .collect { result ->
                result
                    .onSuccess { timetableData ->
                        emit(TimetableUiState.PartialState.Fetched(
                            data = uiState.value.data.copy(sections = timetableData.sections)
                        ))
                    }
                    .onFailure {
                        emit(TimetableUiState.PartialState.Error(it))
                    }
            }
    }

    private fun refreshEvents(): Flow<TimetableUiState.PartialState> = flow {
        refreshEventsUseCase()
            .onFailure {
                emit(TimetableUiState.PartialState.Error(it))
            }
    }

    private fun selectedSection(section: Int): Flow<TimetableUiState.PartialState> = flow {
        println(section)
        emit(TimetableUiState.PartialState.Fetched(
            data = uiState.value.data.copy(
                currentIndex = section
            )
        ))
    }

    private fun eventClicked(id: Int): Flow<TimetableUiState.PartialState> {
//        if (uri.startsWith(HTTP_PREFIX) || uri.startsWith(HTTPS_PREFIX)) {
//            publishEvent(RocketsEvent.OpenWebBrowserWithDetails(uri))
//        }
        publishEvent(TimetableEvents.ShowEvent(id))

        return emptyFlow()
    }
}