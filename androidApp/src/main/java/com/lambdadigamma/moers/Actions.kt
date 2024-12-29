package com.lambdadigamma.moers

import androidx.lifecycle.Lifecycle
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavHostController

/**
 * Models the navigation actions in the app.
 */
class MainActions(navController: NavHostController) {
    val onboardingComplete: () -> Unit = {
        navController.popBackStack()
    }

    val upPress: (from: NavBackStackEntry) -> Unit = { from ->
        // In order to discard duplicated navigation events, we check the Lifecycle
        if (from.lifecycleIsResumed()) {
            navController.navigateUp()
        }
    }
}

class OnboardingActions(navController: NavHostController) {

    val continueToPrivacy = { from: NavBackStackEntry ->
        // In order to discard duplicated navigation events, we check the Lifecycle
        if (from.lifecycleIsResumed()) {
            navController.navigate(Destinations.Onboarding.about)
        }
    }

    val continueToUserTypeSelection = { from: NavBackStackEntry ->
        if (from.lifecycleIsResumed()) {
            navController.navigate(Destinations.Onboarding.userTypeSelection)
        }
    }

    val continueToLocation = { from: NavBackStackEntry ->
        if (from.lifecycleIsResumed()) {
            navController.navigate(Destinations.Onboarding.location)
        }
    }

    val continueToNotifications = { from: NavBackStackEntry ->
        if (from.lifecycleIsResumed()) {
            navController.navigate(Destinations.Onboarding.notifications)
        }
    }

    val continueToFuel = { from: NavBackStackEntry ->
        if (from.lifecycleIsResumed()) {
            navController.navigate(Destinations.Onboarding.fuel)
        }
    }

}

/**
 * If the lifecycle is not resumed it means this NavBackStackEntry already processed a nav event.
 *
 * This is used to de-duplicate navigation events.
 */
private fun NavBackStackEntry.lifecycleIsResumed() =
    this.lifecycle.currentState == Lifecycle.State.RESUMED
