package com.lambdadigamma.events.presentation.timetable

import com.lambdadigamma.events.data.local.preferences.TimetableFilterRepository
import com.lambdadigamma.events.presentation.filter.EventFilter
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow

class FakeTimetableFilterRepository(
    initialFilter: EventFilter = EventFilter(),
) : TimetableFilterRepository {
    private val filter = MutableStateFlow(initialFilter)

    override fun observeFilter(): Flow<EventFilter> = filter

    override suspend fun setFilter(filter: EventFilter) {
        this.filter.value = filter
    }

    override suspend fun clearFilter() {
        filter.value = EventFilter()
    }
}
