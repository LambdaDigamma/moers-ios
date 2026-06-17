package com.lambdadigamma.events.presentation.timetable

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.core.refresh.RefreshMetadataKey
import com.lambdadigamma.core.refresh.RefreshMetadataStore
import com.lambdadigamma.events.data.local.preferences.TimetableFilterRepository
import com.lambdadigamma.events.domain.usecase.GetTimetableUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.events.presentation.filter.EventFilter
import com.lambdadigamma.events.presentation.filter.EventVenueFilterOption
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import timber.log.Timber
import java.util.Locale
import javax.inject.Inject

@HiltViewModel
class TimetableViewModel @Inject constructor(
    private val getTimetableUseCase: GetTimetableUseCase,
    private val refreshEventsUseCase: RefreshEventsUseCase,
    private val filterRepository: TimetableFilterRepository,
    private val refreshMetadataStore: RefreshMetadataStore,
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
            TimetableIntent.ShowFilters -> flow {
                emit(TimetableUiState.PartialState.FilterSheetVisibilityChanged(true))
            }
            TimetableIntent.HideFilters -> flow {
                emit(TimetableUiState.PartialState.FilterSheetVisibilityChanged(false))
            }
            TimetableIntent.ClearFilter -> clearFilter()
            TimetableIntent.ToggleFavoriteFilter -> toggleFavoriteFilter()
            is TimetableIntent.ToggleVenueFilter -> toggleVenueFilter(intent.venueId)
            TimetableIntent.SelectAllVenues -> selectAllVenues()
            TimetableIntent.DeselectAllVenues -> deselectAllVenues()
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
                data = partialState.data.copy(
                    sections = partialState.data.sections,
                    isFilterSheetVisible = previousState.data.isFilterSheetVisible,
                ),
                isError = if (partialState.data.hasAnyEvents) {
                    null
                } else {
                    previousState.isError
                },
            )
            is TimetableUiState.PartialState.Error -> previousState.copy(
                isLoading = false,
                isRefreshing = false,
                isError = partialState.throwable,
            )
            is TimetableUiState.PartialState.Refreshing -> previousState.copy(
                isRefreshing = true,
                isError = null,
            )
            is TimetableUiState.PartialState.RefreshFailed -> previousState.copy(
                isRefreshing = false,
            )
            TimetableUiState.PartialState.RefreshFinished -> previousState.copy(
                isRefreshing = false,
                isError = null,
            )
            is TimetableUiState.PartialState.FilterSheetVisibilityChanged -> previousState.copy(
                data = previousState.data.copy(isFilterSheetVisible = partialState.isVisible),
            )
        }
    }

    private fun getEvents(): Flow<TimetableUiState.PartialState> {
        return combine(
            getTimetableUseCase(),
            filterRepository.observeFilter(),
        ) { result, filter ->
            result to filter
        }.map { (result, filter) ->
            result.fold(
                onSuccess = { timetableData ->
                    TimetableUiState.PartialState.Fetched(
                        data = timetableData.filteredBy(filter),
                    )
                },
                onFailure = { throwable ->
                    TimetableUiState.PartialState.Error(throwable)
                },
            )
        }.onStart {
            emit(TimetableUiState.PartialState.Loading)
        }
    }

    private fun refreshEvents(): Flow<TimetableUiState.PartialState> = flow {
        emit(TimetableUiState.PartialState.Refreshing)
        refreshEventsUseCase()
            .onSuccess {
                emit(TimetableUiState.PartialState.RefreshFinished)
            }
            .onFailure { throwable ->
                if (uiState.value.data.hasAnyEvents) {
                    publishEvent(TimetableEvents.ShowRefreshError(
                        throwable = throwable,
                        lastSuccessfulRefresh = getLastSuccessfulRefresh(),
                    ))
                    emit(TimetableUiState.PartialState.RefreshFailed(throwable))
                } else {
                    emit(TimetableUiState.PartialState.Error(throwable))
                }
            }
    }

    private suspend fun getLastSuccessfulRefresh() = runCatching {
        refreshMetadataStore.getLastSuccessfulRefresh(RefreshMetadataKey.TIMETABLE)
    }.getOrElse { throwable ->
        Timber.w(throwable, "Failed to read timetable refresh timestamp.")
        null
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

    private fun toggleFavoriteFilter(): Flow<TimetableUiState.PartialState> = flow {
        val currentFilter = uiState.value.data.filter
        filterRepository.setFilter(
            currentFilter.copy(showOnlyFavorites = !currentFilter.showOnlyFavorites),
        )
    }

    private fun toggleVenueFilter(venueId: Long): Flow<TimetableUiState.PartialState> = flow {
        filterRepository.setFilter(uiState.value.data.filter.toggledVenue(venueId))
    }

    private fun selectAllVenues(): Flow<TimetableUiState.PartialState> = flow {
        filterRepository.setFilter(
            uiState.value.data.filter.copy(
                venueIds = uiState.value.data.availableVenues.map(EventVenueFilterOption::id),
            ),
        )
    }

    private fun deselectAllVenues(): Flow<TimetableUiState.PartialState> = flow {
        filterRepository.setFilter(uiState.value.data.filter.copy(venueIds = emptyList()))
    }

    private fun clearFilter(): Flow<TimetableUiState.PartialState> = flow {
        filterRepository.clearFilter()
    }
}

internal fun TimetableData.filteredBy(
    filter: EventFilter,
): TimetableData {
    val allEvents = sections.flatMap(TimetableSection::events)
    val availableVenues = allEvents
        .mapNotNull { event -> event.place }
        .distinctBy { place -> place.id }
        .sortedBy { place -> place.name.lowercase(Locale.getDefault()) }
        .map { place ->
            EventVenueFilterOption(
                id = place.id,
                name = place.name,
            )
        }

    val availableVenueIds = availableVenues
        .map(EventVenueFilterOption::id)
        .toSet()
    val sanitizedFilter = filter.copy(
        venueIds = filter.venueIds
            .filter(availableVenueIds::contains)
            .distinct()
            .sorted(),
    )
    val filteredSections = sections
        .map { section ->
            section.copy(
                events = section.events.filter { event ->
                    val matchesVenue = sanitizedFilter.venueIds.isEmpty() ||
                        event.place?.id in sanitizedFilter.venueIds
                    val matchesFavorite = !sanitizedFilter.showOnlyFavorites || event.isFavorite
                    matchesVenue && matchesFavorite
                },
            )
        }
        .filter { section -> section.events.isNotEmpty() }

    return copy(
        sections = filteredSections,
        filter = sanitizedFilter,
        availableVenues = availableVenues,
        hasAnyEvents = allEvents.isNotEmpty(),
    )
}
