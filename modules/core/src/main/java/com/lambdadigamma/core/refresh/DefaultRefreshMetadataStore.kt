package com.lambdadigamma.core.refresh

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import com.lambdadigamma.core.utils.dataStore
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.util.Date
import javax.inject.Inject

internal class DefaultRefreshMetadataStore @Inject constructor(
    @param:ApplicationContext private val context: Context,
) : RefreshMetadataStore {

    override suspend fun getLastSuccessfulRefresh(key: RefreshMetadataKey): Date? {
        return context.dataStore.data
            .map { preferences ->
                preferences[longPreferencesKey(key.preferenceName)]?.let(::Date)
            }
            .first()
    }

    override suspend fun markSuccessfulRefresh(key: RefreshMetadataKey) {
        context.dataStore.edit { preferences ->
            preferences[longPreferencesKey(key.preferenceName)] = Date().time
        }
    }
}
