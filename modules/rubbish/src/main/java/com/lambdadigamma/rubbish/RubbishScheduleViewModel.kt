package com.lambdadigamma.rubbish

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

data class RubbishPickupDay(val date: LocalDate, val types: List<RubbishWasteType>)

data class RubbishScheduleUiState(
    val streetName: String? = null,
    val days: List<RubbishPickupDay> = emptyList(),
    val remindersEnabled: Boolean = false,
    val isLoading: Boolean = true,
    val isRefreshing: Boolean = false,
    val refreshFailed: Boolean = false,
) {
    val hasStreet: Boolean get() = streetName != null
}

private data class RefreshState(
    val isRefreshing: Boolean = false,
    val hasCompleted: Boolean = false,
    val failed: Boolean = false,
)

/** Backs the waste calendar screen and the dashboard card. */
@HiltViewModel
class RubbishScheduleViewModel @Inject constructor(
    private val rubbishRepository: RubbishRepository,
) : ViewModel() {

    private val refreshState = MutableStateFlow(RefreshState())

    val uiState: StateFlow<RubbishScheduleUiState> = combine(
        rubbishRepository.currentStreet,
        rubbishRepository.upcomingPickups,
        rubbishRepository.reminderEnabled,
        refreshState,
    ) { street, pickups, remindersEnabled, refresh ->
        RubbishScheduleUiState(
            streetName = street?.name,
            days = pickups.toDays(),
            remindersEnabled = remindersEnabled,
            isLoading = street != null && pickups.isEmpty() && !refresh.hasCompleted,
            isRefreshing = refresh.isRefreshing,
            refreshFailed = refresh.failed,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), RubbishScheduleUiState())

    init {
        refresh()
    }

    fun refresh() {
        if (refreshState.value.isRefreshing) return
        viewModelScope.launch {
            refreshState.update { it.copy(isRefreshing = true) }
            val result = rubbishRepository.refreshPickups()
            refreshState.value = RefreshState(hasCompleted = true, failed = result.isFailure)
        }
    }

    fun setRemindersEnabled(enabled: Boolean) {
        viewModelScope.launch { rubbishRepository.setRemindersEnabled(enabled) }
    }

    companion object {
        fun List<RubbishCollectionItem>.toDays(): List<RubbishPickupDay> =
            mapNotNull { item -> item.localDate?.let { it to item.type } }
                .groupBy({ it.first }, { it.second })
                .toSortedMap()
                .map { (date, types) -> RubbishPickupDay(date, types.distinct()) }
    }
}
