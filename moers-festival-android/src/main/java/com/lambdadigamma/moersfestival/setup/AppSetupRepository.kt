package com.lambdadigamma.moersfestival.setup

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import com.lambdadigamma.core.utils.dataStore
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

data class AppSetupState(
    val onboardingCompleted: Boolean = false,
    val downloadPromptHandled: Boolean = false,
    val notificationPermissionRequested: Boolean = false,
    val notificationTopicSubscribed: Boolean = false,
)

@Singleton
class AppSetupRepository @Inject constructor(
    @ApplicationContext private val context: Context,
) {

    fun observeState(): Flow<AppSetupState> {
        return context.dataStore.data.map { preferences ->
            AppSetupState(
                onboardingCompleted = preferences[Keys.onboardingCompleted] ?: false,
                downloadPromptHandled = preferences[Keys.downloadPromptHandled] ?: false,
                notificationPermissionRequested = preferences[Keys.notificationPermissionRequested] ?: false,
                notificationTopicSubscribed = preferences[Keys.notificationTopicSubscribed] ?: false,
            )
        }
    }

    suspend fun setOnboardingCompleted(completed: Boolean = true) {
        context.dataStore.edit { preferences ->
            preferences[Keys.onboardingCompleted] = completed
        }
    }

    suspend fun setDownloadPromptHandled(handled: Boolean = true) {
        context.dataStore.edit { preferences ->
            preferences[Keys.downloadPromptHandled] = handled
        }
    }

    suspend fun setNotificationPermissionRequested(requested: Boolean = true) {
        context.dataStore.edit { preferences ->
            preferences[Keys.notificationPermissionRequested] = requested
        }
    }

    suspend fun setNotificationTopicSubscribed(subscribed: Boolean = true) {
        context.dataStore.edit { preferences ->
            preferences[Keys.notificationTopicSubscribed] = subscribed
        }
    }

    private object Keys {
        val onboardingCompleted = booleanPreferencesKey("festival_setup_onboarding_completed")
        val downloadPromptHandled = booleanPreferencesKey("festival_setup_download_prompt_handled")
        val notificationPermissionRequested = booleanPreferencesKey("festival_setup_notification_permission_requested")
        val notificationTopicSubscribed = booleanPreferencesKey("festival_setup_notification_topic_subscribed")
    }
}
