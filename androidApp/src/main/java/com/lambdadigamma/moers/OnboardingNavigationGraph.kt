package com.lambdadigamma.moers

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContentScope
import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.tween
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavHostController
import com.google.accompanist.navigation.animation.AnimatedNavHost
import com.google.accompanist.navigation.animation.composable
import com.google.accompanist.navigation.animation.navigation
import com.google.accompanist.navigation.animation.rememberAnimatedNavController
import com.google.accompanist.systemuicontroller.rememberSystemUiController
import com.lambdadigamma.core.user.UserType
import com.lambdadigamma.moers.onboarding.*
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

const val tweenTimeEnter = 500

private fun positionForRoute(route: String): Int {
    return OnboardingStep.fromRoute(route)?.value ?: -1
}

@OptIn(ExperimentalAnimationApi::class)
private fun enterTransition(
    initialRoute: String,
    destinationRoute: String,
    contentScope: AnimatedContentScope<NavBackStackEntry>
): EnterTransition {
    val initialPosition = positionForRoute(initialRoute)
    val destinationPosition = positionForRoute(destinationRoute)


    return if (
        listOf(Destinations.Onboarding.welcome, Destinations.Onboarding.about).contains(
            destinationRoute
        )
    ) {
        return EnterTransition.None
    } else if (destinationPosition > initialPosition) {
        contentScope.slideIntoContainer(
            AnimatedContentScope.SlideDirection.Left,
            animationSpec = tween(tweenTimeEnter)
        )
    } else {
        contentScope.slideIntoContainer(
            AnimatedContentScope.SlideDirection.Right,
            animationSpec = tween(tweenTimeEnter)
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalAnimationApi::class)
@Composable
fun OnboardingNavigationGraph(
    navController: NavHostController = rememberAnimatedNavController(),
    finishActivity: () -> Unit,
    onFinishOnboarding: () -> Unit,
) {

    rememberSystemUiController().setStatusBarColor(
        MaterialTheme.colorScheme.background, darkIcons = !isSystemInDarkTheme()
    )

    val onboardingViewModel: OnboardingViewModel = hiltViewModel()
    val userTypeViewModel: OnboardingUserTypeViewModel = hiltViewModel()

    Scaffold(topBar = { OnboardingTop(navController) }, modifier = Modifier.systemBarsPadding()) {
        AnimatedNavHost(
            navController = navController,
            Destinations.Onboarding.graph,
            modifier = Modifier.padding(it)
        ) {
            navigation(
                Destinations.Onboarding.welcome,
                Destinations.Onboarding.graph
            ) {
                composable(
                    route = Destinations.Onboarding.welcome,
                    enterTransition = {
                        initialState.destination.route?.let { it1 ->
                            enterTransition(
                                initialRoute = it1,
                                destinationRoute = Destinations.Onboarding.welcome,
                                contentScope = this
                            )
                        }
                    },
                ) { _: NavBackStackEntry ->
                    BackHandler {
                        finishActivity()
                    }
                    OnboardingWelcomeScreen(onNext = {
                        navController.navigate(Destinations.Onboarding.about)
                    })
                }
                composable(
                    route = Destinations.Onboarding.about,
                    enterTransition = {
                        initialState.destination.route?.let { it1 ->
                            enterTransition(
                                initialRoute = it1,
                                destinationRoute = Destinations.Onboarding.about,
                                contentScope = this
                            )
                        }
                    },
                ) {
                    BackHandler(onBack = {
                        navController.navigateUp()
                    })
                    OnboardingAboutScreen(onContinue = {
                        navController.navigate(Destinations.Onboarding.userTypeSelection)
                    })
                }
                composable(
                    route = Destinations.Onboarding.userTypeSelection,
                    enterTransition = {
                        initialState.destination.route?.let { it1 ->
                            enterTransition(
                                initialRoute = it1,
                                destinationRoute = Destinations.Onboarding.userTypeSelection,
                                contentScope = this
                            )
                        }
                    },
                ) {
                    BackHandler {
                        navController.navigateUp()
                    }
                    OnboardingUserTypeScreen(
                        viewModel = userTypeViewModel,
                        onContinue = {
                            navController.navigate(Destinations.Onboarding.location)
                        }
                    )
                }
                composable(
                    route = Destinations.Onboarding.location,
                    enterTransition = {
                        initialState.destination.route?.let { it1 ->
                            enterTransition(
                                initialRoute = it1,
                                destinationRoute = Destinations.Onboarding.location,
                                contentScope = this
                            )
                        }
                    },
                ) {
                    BackHandler {
                        navController.navigateUp()
                    }
                    OnboardingLocationScreen(
                        onContinue = {
                            userTypeViewModel.viewModelScope.launch {
                                val userType = userTypeViewModel.userType.first()

                                if (userType == UserType.VISITOR) {
                                    navController.navigate(Destinations.Onboarding.fuel)
                                } else {
                                    navController.navigate(Destinations.Onboarding.rubbishStreet)
                                }
                            }
                        }
                    )
                }
                composable(
                    route = Destinations.Onboarding.rubbishStreet,
                    enterTransition = {
                        initialState.destination.route?.let { it1 ->
                            enterTransition(
                                initialRoute = it1,
                                destinationRoute = Destinations.Onboarding.rubbishStreet,
                                contentScope = this
                            )
                        }
                    },
                ) {
                    BackHandler {
                        navController.navigateUp()
                    }
                    OnboardingRubbishStreetScreen(
                        onContinue = {
                            navController.navigate(Destinations.Onboarding.fuel)
                        }
                    )
                }
                composable(
                    route = Destinations.Onboarding.fuel,
                    enterTransition = {
                        initialState.destination.route?.let { it1 ->
                            enterTransition(
                                initialRoute = it1,
                                destinationRoute = Destinations.Onboarding.fuel,
                                contentScope = this
                            )
                        }
                    },
                ) {
                    BackHandler {
                        navController.navigateUp()
                    }
                    OnboardingFuelScreen(onContinue = {
                        navController.navigate(Destinations.Onboarding.done)
                    })
                }
                composable(
                    route = Destinations.Onboarding.done,
                    enterTransition = {
                        initialState.destination.route?.let { it1 ->
                            enterTransition(
                                initialRoute = it1,
                                destinationRoute = Destinations.Onboarding.done,
                                contentScope = this
                            )
                        }
                    },
                ) {
                    BackHandler {
                        navController.navigateUp()
                    }
                    OnboardingDoneScreen(onContinue = {
                        onboardingViewModel.viewModelScope.launch {
                            onboardingViewModel.setFinished(callback = onFinishOnboarding)
                        }
                    })
                }
            }
        }
    }
}
