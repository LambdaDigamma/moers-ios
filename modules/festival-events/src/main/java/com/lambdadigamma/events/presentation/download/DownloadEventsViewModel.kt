package com.lambdadigamma.events.presentation.download

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.events.domain.usecase.DownloadContentUseCase
import com.lambdadigamma.events.domain.usecase.GetEventsUseCase
import com.lambdadigamma.events.domain.usecase.GetTimetableUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.events.presentation.mapper.toPresentationModel
import com.lambdadigamma.events.presentation.timetable.TimetableEvents
import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.events.presentation.timetable.TimetableUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import javax.inject.Inject

@HiltViewModel
class DownloadEventsViewModel @Inject constructor(
    private val getEventsUseCase: GetEventsUseCase,
    private val refreshEventsUseCase: RefreshEventsUseCase,
    private val downloadContentUseCase: DownloadContentUseCase,
    savedStateHandle: SavedStateHandle,
    eventsInitialState: DownloadEventsUiState,
): BaseViewModel<DownloadEventsUiState, DownloadEventsUiState.PartialState, TimetableEvents, DownloadEventsIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventsInitialState,
) {

    init {
        acceptIntent(DownloadEventsIntent.GetEvents)
    }

    override fun mapIntents(intent: DownloadEventsIntent): Flow<DownloadEventsUiState.PartialState> {

        return when (intent) {
            is DownloadEventsIntent.GetEvents -> getEvents()
            is DownloadEventsIntent.RefreshEvents -> refreshEvents()
            is DownloadEventsIntent.DownloadContent -> downloadEvents()
        }

    }

    override fun reduceUiState(
        previousState: DownloadEventsUiState,
        partialState: DownloadEventsUiState.PartialState
    ): DownloadEventsUiState = when (partialState) {
        is DownloadEventsUiState.PartialState.Loading -> previousState.copy(
            isLoading = true,
            isError = null,
        )
        is DownloadEventsUiState.PartialState.Fetched -> previousState.copy(
            isLoading = false,
            events = partialState.events,
            isError = null,
        )
        is DownloadEventsUiState.PartialState.Error -> previousState.copy(
            isLoading = false,
            isError = partialState.throwable,
        )
    }

    private fun getEvents(): Flow<DownloadEventsUiState.PartialState> = flow {
        getEventsUseCase()
            .onStart {
                emit(DownloadEventsUiState.PartialState.Loading)
            }
            .collect { result ->
                result
                    .onSuccess { events ->
                        emit(
                            DownloadEventsUiState.PartialState.Fetched(
                                events = events.map { event ->
                                    EventDownloadDisplayable(
                                        id = event.id,
                                        name = event.name,
                                        hasPageDownloaded = event.page != null,
                                        hasMediaDownloaded = false
                                    )
                                }
                            )
                        )
                    }
                    .onFailure {
                        emit(DownloadEventsUiState.PartialState.Error(it))
                    }
            }
    }

    private fun refreshEvents(): Flow<DownloadEventsUiState.PartialState> = flow {
        refreshEventsUseCase()
            .onFailure {
                emit(DownloadEventsUiState.PartialState.Error(it))
            }
    }

    private fun downloadEvents(): Flow<DownloadEventsUiState.PartialState> = flow {
        downloadContentUseCase()
            .onFailure {
                println(it)
                emit(DownloadEventsUiState.PartialState.Error(it))
            }
    }

}