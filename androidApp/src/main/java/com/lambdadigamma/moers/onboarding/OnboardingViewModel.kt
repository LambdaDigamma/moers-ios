package com.lambdadigamma.moers.onboarding

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class OnboardingViewModel @Inject constructor(
    private val onboardingRepository: OnboardingRepository
) : ViewModel() {

    val isOnboardingComplete = onboardingRepository.isOnboarded
    val isCitizen = true

    suspend fun setFinished(callback: suspend () -> Unit) {
        onboardingRepository.setOnboarded()
        callback()
    }

}