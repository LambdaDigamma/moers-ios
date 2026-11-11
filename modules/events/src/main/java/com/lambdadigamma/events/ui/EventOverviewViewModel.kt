package com.lambdadigamma.events.ui

import androidx.compose.foundation.text.input.TextFieldState
import androidx.compose.foundation.text.input.clearText
import androidx.compose.runtime.snapshotFlow
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.events.models.Event
import com.lambdadigamma.events.models.EventDateFilter
import com.lambdadigamma.events.models.EventFavoritesRepository
import com.lambdadigamma.events.models.EventFilter
import com.lambdadigamma.events.models.EventListBuilder
import com.lambdadigamma.events.models.EventRepository
import com.lambdadigamma.events.models.EventSection
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.ZoneId
import javax.inject.Inject

data class EventOverviewUiState(
    val filter: EventFilter = EventFilter(),
    val spotlight: List<Event> = emptyList(),
    val sections: List<EventSection> = emptyList(),
    val liveEventIds: Set<Int> = emptySet(),
    val favoriteIds: Set<Int> = emptySet(),
    val isLoading: Boolean = true,
    val isRefreshing: Boolean = false,
    val refreshFailed: Boolean = false,
) {
    val isEmpty: Boolean get() = sections.isEmpty()
}

private data class RefreshState(
    val isRefreshing: Boolean = false,
    val hasCompleted: Boolean = false,
    val failed: Boolean = false,
)

@HiltViewModel
class EventOverviewViewModel @Inject constructor(
    private val eventRepository: EventRepository,
    private val favoritesRepository: EventFavoritesRepository,
) : ViewModel() {

    /** The search text. The search field edits it directly, so typing never waits for the list. */
    val query = TextFieldState()

    private val filter = MutableStateFlow(EventFilter())
    private val refreshState = MutableStateFlow(RefreshState())

    /** Re-evaluates sections every minute so finished events disappear. */
    private val now = flow {
        while (true) {
            emit(Instant.now())
            delay(60_000)
        }
    }

    val uiState: StateFlow<EventOverviewUiState> = combine(
        eventRepository.events,
        favoritesRepository.favoriteIds,
        filter,
        refreshState,
        now,
    ) { events, favoriteIds, filter, refresh, now ->
        val builder = EventListBuilder(now, ZoneId.systemDefault(), favoriteIds)
        EventOverviewUiState(
            filter = filter,
            spotlight = if (filter.isActive) emptyList() else builder.spotlight(events),
            sections = builder.sections(events, filter),
            liveEventIds = events.filter(builder::isLive).map { it.id }.toSet(),
            favoriteIds = favoriteIds,
            isLoading = events.isEmpty() && !refresh.hasCompleted,
            isRefreshing = refresh.isRefreshing,
            refreshFailed = refresh.failed,
        )
    }
        .flowOn(Dispatchers.Default)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), EventOverviewUiState())

    init {
        refresh()
        viewModelScope.launch {
            snapshotFlow { query.text.toString() }.collect { text ->
                filter.update { it.copy(query = text) }
            }
        }
    }

    fun refresh() {
        if (refreshState.value.isRefreshing) return
        viewModelScope.launch {
            refreshState.update { it.copy(isRefreshing = true) }
            val result = eventRepository.refresh()
            refreshState.value = RefreshState(hasCompleted = true, failed = result.isFailure)
        }
    }

    fun selectDateFilter(dateFilter: EventDateFilter) {
        filter.update { current ->
            current.copy(date = if (current.date == dateFilter) EventDateFilter.ALL else dateFilter)
        }
    }

    fun toggleOnlineOnly() {
        filter.update { it.copy(onlineOnly = !it.onlineOnly) }
    }

    fun toggleFavoritesOnly() {
        filter.update { it.copy(favoritesOnly = !it.favoritesOnly) }
    }

    fun resetFilters() {
        query.clearText()
        filter.value = EventFilter()
    }
}
