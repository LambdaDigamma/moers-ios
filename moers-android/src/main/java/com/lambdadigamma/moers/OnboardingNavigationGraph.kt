package com.lambdadigamma.moers

import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navigation
import com.lambdadigamma.core.user.UserType
import com.lambdadigamma.moers.onboarding.OnboardingAboutScreen
import com.lambdadigamma.moers.onboarding.OnboardingDoneScreen
import com.lambdadigamma.moers.onboarding.OnboardingFuelScreen
import com.lambdadigamma.moers.onboarding.OnboardingLocationScreen
import com.lambdadigamma.moers.onboarding.OnboardingRubbishStreetScreen
import com.lambdadigamma.moers.onboarding.OnboardingTop
import com.lambdadigamma.moers.onboarding.OnboardingUserTypeScreen
import com.lambdadigamma.moers.onboarding.OnboardingUserTypeViewModel
import com.lambdadigamma.moers.onboarding.OnboardingViewModel
import com.lambdadigamma.moers.onboarding.OnboardingWelcomeScreen
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

/**
 * Onboarding flow. Finishing it stores the onboarding state, which switches the activity to the
 * main app shell.
 */
@Composable
fun OnboardingNavigationGraph(
    navController: NavHostController = rememberNavController(),
) {
    val onboardingViewModel: OnboardingViewModel = hiltViewModel()
    val userTypeViewModel: OnboardingUserTypeViewModel = hiltViewModel()
    val scope = rememberCoroutineScope()

    Scaffold(topBar = { OnboardingTop(navController) }) { padding ->
        NavHost(
            navController = navController,
            startDestination = Destinations.Onboarding.graph,
            modifier = Modifier
                .padding(padding)
                .consumeWindowInsets(padding),
        ) {
            navigation(
                startDestination = Destinations.Onboarding.welcome,
                route = Destinations.Onboarding.graph,
            ) {
                composable(route = Destinations.Onboarding.welcome) {
                    OnboardingWelcomeScreen(onNext = {
                        navController.navigate(Destinations.Onboarding.about)
                    })
                }
                composable(route = Destinations.Onboarding.about) {
                    OnboardingAboutScreen(onContinue = {
                        navController.navigate(Destinations.Onboarding.userTypeSelection)
                    })
                }
                composable(route = Destinations.Onboarding.userTypeSelection) {
                    OnboardingUserTypeScreen(
                        viewModel = userTypeViewModel,
                        onContinue = {
                            navController.navigate(Destinations.Onboarding.location)
                        },
                    )
                }
                composable(route = Destinations.Onboarding.location) {
                    OnboardingLocationScreen(onContinue = {
                        scope.launch {
                            val next = if (userTypeViewModel.userType.first() == UserType.VISITOR) {
                                Destinations.Onboarding.fuel
                            } else {
                                Destinations.Onboarding.rubbishStreet
                            }
                            navController.navigate(next)
                        }
                    })
                }
                composable(route = Destinations.Onboarding.rubbishStreet) {
                    OnboardingRubbishStreetScreen(onContinue = {
                        navController.navigate(Destinations.Onboarding.fuel)
                    })
                }
                composable(route = Destinations.Onboarding.fuel) {
                    OnboardingFuelScreen(onContinue = {
                        navController.navigate(Destinations.Onboarding.done)
                    })
                }
                composable(route = Destinations.Onboarding.done) {
                    OnboardingDoneScreen(onContinue = {
                        scope.launch { onboardingViewModel.setFinished() }
                    })
                }
            }
        }
    }
}
