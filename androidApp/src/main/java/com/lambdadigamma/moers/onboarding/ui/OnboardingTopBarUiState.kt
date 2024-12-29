package com.lambdadigamma.moers.onboarding.ui

import androidx.annotation.StringRes
import com.lambdadigamma.moers.R

data class OnboardingTopBarUiState(
    @StringRes val title: Int,
    val steps: List<OnboardingStepState>
) {
    companion object {
        fun default(): OnboardingTopBarUiState {
            return OnboardingTopBarUiState(
                R.string.onboarding_about_title,
                listOf()
            )
        }
    }
}