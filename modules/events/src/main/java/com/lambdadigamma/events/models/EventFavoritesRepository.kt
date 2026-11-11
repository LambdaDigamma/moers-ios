package com.lambdadigamma.events.models

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.eventFavoritesDataStore: DataStore<Preferences> by preferencesDataStore("event_favorites")

/** Events the user marked as favorite. Stored on the device only. */
@Singleton
class EventFavoritesRepository @Inject constructor(
    @param:ApplicationContext private val context: Context,
) {

    private val key = stringSetPreferencesKey("favorite_event_ids")

    val favoriteIds: Flow<Set<Int>> = context.eventFavoritesDataStore.data.map { preferences ->
        preferences[key].orEmpty().mapNotNull { it.toIntOrNull() }.toSet()
    }

    suspend fun toggle(eventId: Int) {
        context.eventFavoritesDataStore.edit { preferences ->
            val current = preferences[key].orEmpty()
            val id = eventId.toString()
            preferences[key] = if (id in current) current - id else current + id
        }
    }
}
