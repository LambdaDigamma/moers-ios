package com.lambdadigamma.moers.onboarding

import androidx.annotation.StringRes
import com.lambdadigamma.moers.Destinations
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingStepState
import com.lambdadigamma.moers.onboarding.ui.OnboardingTopBarUiState

enum class OnboardingStep constructor(val value: Int) {
    ABOUT(0),
    USER_TYPE(1),
    LOCATION(2),
    RUBBISH_STREET(3),
    FUEL(4),
    DONE(5);

    companion object {
        fun fromRoute(route: String): OnboardingStep? {
            return when (route) {
                Destinations.Onboarding.about -> {
                    ABOUT
                }
                Destinations.Onboarding.userTypeSelection -> {
                    USER_TYPE
                }
                Destinations.Onboarding.location -> {
                    LOCATION
                }
                Destinations.Onboarding.rubbishStreet -> {
                    RUBBISH_STREET
                }
                Destinations.Onboarding.fuel -> {
                    FUEL
                }
                Destinations.Onboarding.done -> {
                    DONE
                }
                else -> {
                    null
                }
            }
        }
    }
}

fun OnboardingStep.toUiState(): OnboardingTopBarUiState {
    val steps = mutableListOf<OnboardingStepState>()

    // Adds completed steps to the list
    steps.addAll(
        generateSequence { OnboardingStepState.COMPLETE }.take(
            this.value
        )
    )

    // Adds current step to the list
    steps.add(OnboardingStepState.IN_PROGRESS)

    // Adds remaining steps to the list
    steps.addAll(
        generateSequence { OnboardingStepState.NOT_COMPLETE }
            .take(OnboardingStep.values().size - (this.value + 1))
    )

    return OnboardingTopBarUiState(
        this.displayName(),
        steps
    )
}

@StringRes
fun OnboardingStep.displayName(): Int {
    return when (this) {
        OnboardingStep.ABOUT -> R.string.onboarding_about_title
        OnboardingStep.USER_TYPE -> R.string.onboarding_user_type_title
        OnboardingStep.LOCATION -> R.string.onboarding_location_title
        OnboardingStep.RUBBISH_STREET -> R.string.onboarding_rubbish_street_title
        OnboardingStep.FUEL -> R.string.feature_fuel_title
        OnboardingStep.DONE -> R.string.onboarding_done_title
    }
}
