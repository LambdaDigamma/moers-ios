package com.lambdadigamma.events.data.local.preferences

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringSetPreferencesKey
import com.lambdadigamma.core.utils.dataStore
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsFilter
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

interface FavoriteEventsFilterRepository {
    fun observeFilter(): Flow<FavoriteEventsFilter>

    suspend fun setFilter(filter: FavoriteEventsFilter)

    suspend fun clearFilter()
}

@Singleton
class DefaultFavoriteEventsFilterRepository @Inject constructor(
    @param:ApplicationContext private val context: Context,
) : FavoriteEventsFilterRepository {

    override fun observeFilter(): Flow<FavoriteEventsFilter> {
        return context.dataStore.data.map { preferences ->
            val venueIds = preferences[FAVORITE_VENUE_IDS]
                .orEmpty()
                .mapNotNull(String::toLongOrNull)
                .distinct()
                .sorted()

            FavoriteEventsFilter(venueIds = venueIds)
        }
    }

    override suspend fun setFilter(filter: FavoriteEventsFilter) {
        context.dataStore.edit { preferences ->
            preferences[FAVORITE_VENUE_IDS] = filter.venueIds
                .distinct()
                .sorted()
                .map(Long::toString)
                .toSet()
        }
    }

    override suspend fun clearFilter() {
        context.dataStore.edit { preferences ->
            preferences.remove(FAVORITE_VENUE_IDS)
        }
    }

    private companion object {
        val FAVORITE_VENUE_IDS = stringSetPreferencesKey("favorite_events_filter_venue_ids")
    }
}
