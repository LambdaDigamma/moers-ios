package com.lambdadigamma.moers.onboarding

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ActivityRetainedComponent
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

@Module
@InstallIn(ActivityRetainedComponent::class)
class OnboardingRepository @Inject constructor(@ApplicationContext private val context: Context) {

    companion object {
        const val baseOnboarding = "1.0"
        private val Context.dataStore: DataStore<Preferences> by preferencesDataStore("onboarding")
        val ONBOARDING_VERSION_KEY = stringPreferencesKey("onboarding_version")
    }

    private val getOnboardingVersion: Flow<String?> = context.dataStore.data
        .map { preferences ->
            preferences[ONBOARDING_VERSION_KEY]
        }

    val isOnboarded = getOnboardingVersion.map { version ->
        version == baseOnboarding
    }

    suspend fun setOnboarded() {
        setCompletedOnboarding(baseOnboarding)
    }

    suspend fun setCompletedOnboarding(version: String) {
        context.dataStore.edit { preferences ->
            preferences[ONBOARDING_VERSION_KEY] = version
        }
    }
}