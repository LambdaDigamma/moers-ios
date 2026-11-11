package com.lambdadigamma.moers

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.moers.onboarding.OnboardingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    onboardingRepository: OnboardingRepository,
) : ViewModel() {

    /** `null` until the stored onboarding state is known; the splash screen stays up meanwhile. */
    val isOnboarded: StateFlow<Boolean?> = onboardingRepository.isOnboarded
        .stateIn(viewModelScope, SharingStarted.Eagerly, null)

}
