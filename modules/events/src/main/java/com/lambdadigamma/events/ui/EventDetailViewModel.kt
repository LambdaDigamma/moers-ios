package com.lambdadigamma.events.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.events.models.Event
import com.lambdadigamma.events.models.EventRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import retrofit2.HttpException
import javax.inject.Inject

sealed interface EventDetailUiState {
    data object Loading : EventDetailUiState
    data object NotFound : EventDetailUiState
    data object Failed : EventDetailUiState
    data class Loaded(val event: Event) : EventDetailUiState
}

@HiltViewModel
class EventDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val eventRepository: EventRepository,
) : ViewModel() {

    private val eventId: Int = checkNotNull(savedStateHandle["id"])

    /** `null` while the event is being refreshed from the API. */
    private val refreshResult = MutableStateFlow<Result<Unit>?>(null)

    val uiState: StateFlow<EventDetailUiState> = combine(
        eventRepository.event(eventId),
        refreshResult,
    ) { event, result ->
        when {
            event != null -> EventDetailUiState.Loaded(event)
            result == null -> EventDetailUiState.Loading
            (result.exceptionOrNull() as? HttpException)?.code() == 404 -> EventDetailUiState.NotFound
            else -> EventDetailUiState.Failed
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), EventDetailUiState.Loading)

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            refreshResult.value = null
            refreshResult.value = eventRepository.refreshEvent(eventId)
        }
    }
}
