package com.lambdadigamma.events.data.local.preferences

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringSetPreferencesKey
import com.lambdadigamma.core.utils.dataStore
import com.lambdadigamma.events.presentation.filter.EventFilter
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

interface TimetableFilterRepository {
    fun observeFilter(): Flow<EventFilter>

    suspend fun setFilter(filter: EventFilter)

    suspend fun clearFilter()
}
@Singleton
class DefaultTimetableFilterRepository @Inject constructor(
    @param:ApplicationContext private val context: Context,
) : TimetableFilterRepository {

    override fun observeFilter(): Flow<EventFilter> {
        return context.dataStore.data.map { preferences ->
            EventFilter(
                venueIds = preferences[TIMETABLE_VENUE_IDS]
                    .orEmpty()
                    .mapNotNull(String::toLongOrNull)
                    .distinct()
                    .sorted(),
                showOnlyFavorites = preferences[TIMETABLE_ONLY_FAVORITES] ?: false,
            )
        }
    }

    override suspend fun setFilter(filter: EventFilter) {
        context.dataStore.edit { preferences ->
            preferences[TIMETABLE_VENUE_IDS] = filter.venueIds
                .distinct()
                .sorted()
                .map(Long::toString)
                .toSet()
            preferences[TIMETABLE_ONLY_FAVORITES] = filter.showOnlyFavorites
        }
    }

    override suspend fun clearFilter() {
        context.dataStore.edit { preferences ->
            preferences.remove(TIMETABLE_VENUE_IDS)
            preferences.remove(TIMETABLE_ONLY_FAVORITES)
        }
    }

    private companion object {
        val TIMETABLE_VENUE_IDS = stringSetPreferencesKey("timetable_filter_venue_ids")
        val TIMETABLE_ONLY_FAVORITES = booleanPreferencesKey("timetable_filter_only_favorites")
    }
}
