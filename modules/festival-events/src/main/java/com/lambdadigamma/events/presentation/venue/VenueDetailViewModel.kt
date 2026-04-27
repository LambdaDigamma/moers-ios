package com.lambdadigamma.events.presentation.venue

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.events.domain.repository.EventRepository
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.events.presentation.mapper.toPresentationModel
import com.lambdadigamma.events.presentation.mapper.toPresentationModel as toPlacePresentationModel
import com.lambdadigamma.pages.domain.usecase.GetPageUseCase
import com.lambdadigamma.pages.domain.usecase.RefreshPageUseCase
import dagger.assisted.Assisted
import dagger.assisted.AssistedFactory
import dagger.assisted.AssistedInject
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel(assistedFactory = VenueDetailViewModel.Factory::class)
class VenueDetailViewModel @AssistedInject constructor(
    private val eventRepository: EventRepository,
    private val getPageUseCase: GetPageUseCase,
    private val refreshPageUseCase: RefreshPageUseCase,
    private val refreshEventsUseCase: RefreshEventsUseCase,
    @param:Assisted private val placeId: Long,
) : ViewModel() {

    private var hasRequestedEventsRefresh = false
    private var hasRequestedPageRefresh = false

    private val _uiState = MutableStateFlow(VenueDetailUiState(isLoading = true))
    val uiState = _uiState

    init {
        observeVenue()
    }

    private fun observeVenue() {
        viewModelScope.launch {
            val placeFlow = eventRepository.getPlace(placeId)
            val eventsFlow = eventRepository.getEventsForPlace(placeId)

            combine(
                placeFlow,
                eventsFlow,
                placeFlow.flatMapLatest { place ->
                    val pageId = place?.pageID?.toInt() ?: return@flatMapLatest flowOf(Result.success(null))
                    getPageUseCase(pageId)
                },
            ) { place, events, pageResult ->
                Triple(place, events, pageResult)
            }
                .catch { throwable ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isError = throwable,
                        )
                    }
                }
                .collect { (place, events, pageResult) ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            place = place?.toPlacePresentationModel(),
                            events = events.map { event -> event.toPresentationModel() },
                            blocks = pageResult.getOrNull()?.blocks.orEmpty(),
                            isError = pageResult.exceptionOrNull(),
                        )
                    }

                    if (place == null && events.isEmpty() && !hasRequestedEventsRefresh) {
                        hasRequestedEventsRefresh = true
                        refreshEventsUseCase()
                            .onFailure { throwable ->
                                _uiState.update { currentState ->
                                    currentState.copy(isError = throwable)
                                }
                            }
                    }

                    val pageId = place?.pageID?.toInt()
                    if (pageId != null && pageResult.getOrNull() == null && !hasRequestedPageRefresh) {
                        hasRequestedPageRefresh = true
                        refreshPageUseCase(pageId)
                            .onFailure { throwable ->
                                _uiState.update { currentState ->
                                    currentState.copy(isError = throwable)
                                }
                            }
                    }
                }
        }
    }

    @AssistedFactory
    interface Factory {
        fun create(placeId: Long): VenueDetailViewModel
    }
}
