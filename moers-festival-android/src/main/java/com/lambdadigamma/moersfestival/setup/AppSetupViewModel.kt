package com.lambdadigamma.moersfestival.setup

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.moersfestival.notifications.FestivalNotificationManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

data class AppSetupUiState(
    val isLoading: Boolean = true,
    val onboardingCompleted: Boolean = false,
    val downloadPromptHandled: Boolean = false,
    val notificationPermissionGranted: Boolean = false,
    val notificationPermissionRequested: Boolean = false,
    val notificationTopicSubscribed: Boolean = false,
    val isSyncingNotifications: Boolean = false,
) {
    val shouldShowOnboarding: Boolean
        get() = !isLoading && !onboardingCompleted

    val shouldShowDownloadPrompt: Boolean
        get() = !isLoading && onboardingCompleted && !downloadPromptHandled
}

@HiltViewModel
class AppSetupViewModel @Inject constructor(
    private val repository: AppSetupRepository,
    private val notificationManager: FestivalNotificationManager,
) : ViewModel() {

    private var storedState = AppSetupState()

    private val _uiState = MutableStateFlow(
        AppSetupUiState(
            notificationPermissionGranted = notificationManager.hasNotificationPermission(),
        )
    )
    val uiState: StateFlow<AppSetupUiState> = _uiState.asStateFlow()

    init {
        notificationManager.ensureDefaultNotificationChannel()

        viewModelScope.launch {
            repository.observeState().collect { state ->
                storedState = state
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        onboardingCompleted = state.onboardingCompleted,
                        downloadPromptHandled = state.downloadPromptHandled,
                        notificationPermissionGranted = notificationManager.hasNotificationPermission(),
                        notificationPermissionRequested = state.notificationPermissionRequested,
                        notificationTopicSubscribed = state.notificationTopicSubscribed,
                    )
                }

                maybeSyncNotificationTopic()
            }
        }
    }

    fun completeOnboarding() {
        viewModelScope.launch {
            repository.setOnboardingCompleted()
        }
    }

    fun markDownloadPromptHandled() {
        viewModelScope.launch {
            repository.setDownloadPromptHandled()
        }
    }

    fun markNotificationPermissionRequested() {
        viewModelScope.launch {
            repository.setNotificationPermissionRequested()
        }
    }

    fun refreshNotificationState() {
        viewModelScope.launch {
            _uiState.update {
                it.copy(
                    notificationPermissionGranted = notificationManager.hasNotificationPermission(),
                )
            }

            maybeSyncNotificationTopic()
        }
    }

    fun openSystemNotificationSettings() {
        notificationManager.openSystemNotificationSettings()
    }

    private suspend fun maybeSyncNotificationTopic() {
        val permissionGranted = notificationManager.hasNotificationPermission()

        _uiState.update {
            it.copy(notificationPermissionGranted = permissionGranted)
        }

        if (!permissionGranted || storedState.notificationTopicSubscribed || _uiState.value.isSyncingNotifications) {
            return
        }

        _uiState.update { it.copy(isSyncingNotifications = true) }

        notificationManager.subscribeToGeneralTopic()
            .onSuccess {
                repository.setNotificationTopicSubscribed()
            }
            .onFailure { throwable ->
                Timber.w(throwable, "Failed to subscribe to festival notification topic.")
            }

        _uiState.update {
            it.copy(
                isSyncingNotifications = false,
                notificationPermissionGranted = notificationManager.hasNotificationPermission(),
            )
        }
    }
}
