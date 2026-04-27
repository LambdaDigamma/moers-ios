package com.lambdadigamma.events.presentation.favorites

import androidx.lifecycle.SavedStateHandle
import com.lambdadigamma.core.base.BaseViewModel
import com.lambdadigamma.events.data.local.preferences.FavoriteEventsFilterRepository
import com.lambdadigamma.events.domain.usecase.GetFavoriteEventsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import java.util.Locale
import javax.inject.Inject

@HiltViewModel
class FavoriteEventsViewModel @Inject constructor(
    private val getFavoriteEventsUseCase: GetFavoriteEventsUseCase,
    private val filterRepository: FavoriteEventsFilterRepository,
    savedStateHandle: SavedStateHandle,
    eventsInitialState: FavoriteEventsUiState,
) : BaseViewModel<FavoriteEventsUiState, FavoriteEventsUiState.PartialState, FavoriteEventsEvents, FavoriteEventsIntent>(
    savedStateHandle = savedStateHandle,
    initialState = eventsInitialState,
) {

    init {
        acceptIntent(FavoriteEventsIntent.GetEvents)
    }

    override fun mapIntents(intent: FavoriteEventsIntent): Flow<FavoriteEventsUiState.PartialState> {
        return when (intent) {
            FavoriteEventsIntent.GetEvents -> getEvents()
            FavoriteEventsIntent.ShowFilters -> flow {
                emit(FavoriteEventsUiState.PartialState.FilterSheetVisibilityChanged(true))
            }

            FavoriteEventsIntent.HideFilters -> flow {
                emit(FavoriteEventsUiState.PartialState.FilterSheetVisibilityChanged(false))
            }

            FavoriteEventsIntent.ClearFilter -> clearFilter()
            is FavoriteEventsIntent.ToggleVenueFilter -> toggleVenueFilter(intent.venueId)
            is FavoriteEventsIntent.EventClicked -> eventClicked(intent.id)
        }
    }

    override fun reduceUiState(
        previousState: FavoriteEventsUiState,
        partialState: FavoriteEventsUiState.PartialState,
    ): FavoriteEventsUiState = when (partialState) {
        is FavoriteEventsUiState.PartialState.Loading -> previousState.copy(
            isLoading = true,
            isError = null,
        )

        is FavoriteEventsUiState.PartialState.Fetched -> previousState.copy(
            isLoading = false,
            data = partialState.data.copy(
                isFilterSheetVisible = previousState.data.isFilterSheetVisible,
            ),
            isError = null,
        )

        is FavoriteEventsUiState.PartialState.Error -> previousState.copy(
            isLoading = false,
            data = previousState.data.copy(
                sections = emptyList(),
                hasAnyFavorites = false,
                availableVenues = emptyList(),
            ),
            isError = partialState.throwable,
        )

        is FavoriteEventsUiState.PartialState.FilterSheetVisibilityChanged -> previousState.copy(
            data = previousState.data.copy(isFilterSheetVisible = partialState.isVisible),
        )
    }

    private fun getEvents(): Flow<FavoriteEventsUiState.PartialState> {
        return combine(
            getFavoriteEventsUseCase(),
            filterRepository.observeFilter(),
        ) { result, filter ->
            result to filter
        }.map { (result, filter) ->
            result.fold(
                onSuccess = { data ->
                    FavoriteEventsUiState.PartialState.Fetched(
                        data = data.filteredBy(filter),
                    )
                },
                onFailure = { throwable ->
                    FavoriteEventsUiState.PartialState.Error(throwable)
                },
            )
        }.onStart {
            emit(FavoriteEventsUiState.PartialState.Loading)
        }
    }

    private fun toggleVenueFilter(venueId: Long): Flow<FavoriteEventsUiState.PartialState> = flow {
        filterRepository.setFilter(uiState.value.data.filter.toggledVenue(venueId))
    }

    private fun clearFilter(): Flow<FavoriteEventsUiState.PartialState> = flow {
        filterRepository.clearFilter()
    }

    private fun eventClicked(id: Int): Flow<FavoriteEventsUiState.PartialState> {
        publishEvent(FavoriteEventsEvents.ShowEvent(id))
        return emptyFlow()
    }
}

internal fun FavoriteEventsData.filteredBy(
    filter: FavoriteEventsFilter,
): FavoriteEventsData {
    val allEvents = sections.flatMap(FavoriteEventsSection::events)
    val availableVenues = allEvents
        .mapNotNull { event -> event.place }
        .distinctBy { place -> place.id }
        .sortedBy { place -> place.name.lowercase(Locale.getDefault()) }
        .map { place ->
            FavoriteVenueFilterOption(
                id = place.id,
                name = place.name,
            )
        }

    val availableVenueIds = availableVenues
        .map(FavoriteVenueFilterOption::id)
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
                    sanitizedFilter.isEmpty || event.place?.id in sanitizedFilter.venueIds
                },
            )
        }
        .filter { section -> section.events.isNotEmpty() }

    return copy(
        sections = filteredSections,
        filter = sanitizedFilter,
        availableVenues = availableVenues,
        hasAnyFavorites = allEvents.isNotEmpty(),
    )
}
