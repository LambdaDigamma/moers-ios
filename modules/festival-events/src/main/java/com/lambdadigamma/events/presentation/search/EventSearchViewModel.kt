package com.lambdadigamma.events.presentation.search

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.events.domain.usecase.SearchEventsUseCase
import com.lambdadigamma.events.presentation.mapper.toPresentationModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import javax.inject.Inject

@OptIn(ExperimentalCoroutinesApi::class, FlowPreview::class)
@HiltViewModel
class EventSearchViewModel @Inject constructor(
    private val searchEventsUseCase: SearchEventsUseCase,
    savedStateHandle: SavedStateHandle,
    initialState: EventSearchUiState,
) : BaseViewModel<EventSearchUiState, EventSearchPartialState, EventSearchEvents, EventSearchIntent>(
    savedStateHandle = savedStateHandle,
    initialState = initialState,
) {

    private val query = MutableStateFlow(initialState.query)

    init {
        acceptIntent(EventSearchLoadEvents)
    }

    override fun mapIntents(intent: EventSearchIntent): Flow<EventSearchPartialState> {
        return when (intent) {
            EventSearchLoadEvents -> getEvents()
            is EventSearchQueryChanged -> flow {
                query.value = intent.query
                emit(EventSearchQueryUpdated(intent.query))
            }
            is EventSearchEventClicked -> eventClicked(intent.id)
        }
    }

    override fun reduceUiState(
        previousState: EventSearchUiState,
        partialState: EventSearchPartialState,
    ): EventSearchUiState {
        return when (partialState) {
            EventSearchLoading -> previousState.copy(
                isLoading = true,
                isError = null,
            )
            is EventSearchFetched -> previousState.copy(
                isLoading = false,
                sections = partialState.sections,
                isError = null,
            )
            is EventSearchFailed -> previousState.copy(
                isLoading = false,
                sections = emptyList(),
                isError = partialState.throwable,
            )
            is EventSearchQueryUpdated -> previousState.copy(
                query = partialState.query,
            )
        }
    }

    private fun getEvents(): Flow<EventSearchPartialState> {
        return query
            .debounce(200)
            .distinctUntilChanged()
            .flatMapLatest { query ->
                searchEventsUseCase(query)
            }
            .map { result ->
                result.fold(
                    onSuccess = { events ->
                        EventSearchFetched(
                            EventSearchSectionBuilder.build(
                                events = events.map { event -> event.toPresentationModel() },
                            ),
                        )
                    },
                    onFailure = { throwable ->
                        EventSearchFailed(throwable)
                    },
                )
            }
            .onStart {
                emit(EventSearchLoading)
            }
    }

    private fun eventClicked(id: Int): Flow<EventSearchPartialState> {
        publishEvent(EventSearchShowEvent(id))
        return emptyFlow()
    }
}
