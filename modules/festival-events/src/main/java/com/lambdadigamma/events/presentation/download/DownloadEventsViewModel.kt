package com.lambdadigamma.events.presentation.download

import android.content.Context
import coil3.ImageLoader
import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.events.domain.usecase.DownloadContentUseCase
import com.lambdadigamma.events.domain.usecase.GetEventsUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.medialibrary.prefetchToDisk
import dagger.hilt.android.qualifiers.ApplicationContext
import com.lambdadigamma.events.presentation.timetable.TimetableEvents
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import javax.inject.Inject

@HiltViewModel
class DownloadEventsViewModel @Inject constructor(
    private val getEventsUseCase: GetEventsUseCase,
    private val refreshEventsUseCase: RefreshEventsUseCase,
    private val downloadContentUseCase: DownloadContentUseCase,
    @param:ApplicationContext private val context: Context,
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
            is DownloadEventsIntent.DownloadContent -> downloadEvents(
                includeContent = intent.includeContent,
                includeMedia = intent.includeMedia,
            )
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
                                events = events.map { event -> event.toDownloadDisplayable() }
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

    private fun downloadEvents(
        includeContent: Boolean,
        includeMedia: Boolean,
    ): Flow<DownloadEventsUiState.PartialState> = flow {
        if (includeContent) {
            downloadContentUseCase()
                .onFailure {
                    emit(DownloadEventsUiState.PartialState.Error(it))
                    return@flow
                }
        }

        val eventsResult = getEventsUseCase().first()
        eventsResult
            .onSuccess { events ->
                val mediaDownloadedEventIds = if (includeMedia) {
                    val imageLoader = ImageLoader.Builder(context).build()
                    events
                        .filter { event ->
                            event.downloadMediaUrls().onEach { url ->
                                prefetchToDisk(
                                    image = url,
                                    context = context,
                                    imageLoader = imageLoader,
                                )
                            }.isNotEmpty()
                        }
                        .map { event -> event.id }
                        .toSet()
                } else {
                    emptySet()
                }

                emit(
                    DownloadEventsUiState.PartialState.Fetched(
                        events = events.map { event ->
                            event.toDownloadDisplayable(mediaDownloadedEventIds)
                        },
                    ),
                )
            }
            .onFailure {
                emit(DownloadEventsUiState.PartialState.Error(it))
            }
    }

}
