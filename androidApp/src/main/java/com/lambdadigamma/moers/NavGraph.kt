package com.lambdadigamma.moers

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavOptions
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.google.accompanist.systemuicontroller.rememberSystemUiController
import com.lambdadigamma.events.ui.EventDetailScreen
import com.lambdadigamma.events.ui.EventOverviewScreen
import com.lambdadigamma.fuel.detail.FuelStationDetailScreen
import com.lambdadigamma.fuel.list.FuelStationListScreen
import com.lambdadigamma.moers.dashboard.DashboardAction
import com.lambdadigamma.moers.dashboard.DashboardScreen
import com.lambdadigamma.moers.explore.ExploreNavigationAction
import com.lambdadigamma.moers.explore.ExploreScreen
import com.lambdadigamma.moers.misc.AboutScreen
import com.lambdadigamma.moers.misc.FeedbackScreen
import com.lambdadigamma.moers.search.SearchScreen
import com.lambdadigamma.newsfeature.ui.NewsScreen
import com.lambdadigamma.newsfeature.ui.NewsWebDetailScreen
import com.lambdadigamma.parking.detail.ParkingAreaDetailScreen
import com.lambdadigamma.parking.list.ParkingAreasScreen
import com.lambdadigamma.radio.detail.BroadcastDetailScreen
import com.lambdadigamma.radio.overview.BroadcastOverviewScreen
import com.lambdadigamma.rubbish.ui.RubbishListScreen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NavGraph(
    modifier: Modifier = Modifier,
    finishActivity: () -> Unit = {},
    navController: NavHostController = rememberNavController(),
    startDestination: String = Destinations.dashboard
) {

    rememberSystemUiController().setStatusBarColor(
        MaterialTheme.colorScheme.background, darkIcons = !isSystemInDarkTheme()
    )

    NavHost(
        navController = navController,
        startDestination = startDestination,
        modifier = modifier

    ) {

        // ------------------------------------------------------------
        // Dashboard
        // ------------------------------------------------------------

        composable(route = Destinations.dashboard) {
            DashboardScreen(onOpenSettings = {
                navController.navigate(
                    Destinations.settings,
                    navOptions = NavOptions.Builder().build(),
                )
            }, onAction = {
                when (it) {
                    DashboardAction.Rubbish -> {
                        navController.navigate(
                            Destinations.rubbishList
                        )
                    }
                    DashboardAction.Fuel -> {
                        navController.navigate(
                            Destinations.fuelList
                        )
                    }
                    DashboardAction.Parking -> {
                        navController.navigate(
                            Destinations.parkingAreas
                        )
                    }
                    DashboardAction.About -> {
                        navController.navigate(
                            Destinations.about
                        )
                    }
                    DashboardAction.Feedback -> {
                        navController.navigate(
                            Destinations.feedback
                        )
                    }
                }
            })
        }

        // ------------------------------------------------------------
        // Rubbish
        // ------------------------------------------------------------

        composable(route = Destinations.rubbishList) {
            RubbishListScreen(onBack = {
                navController.popBackStack()
            })
        }

        // ------------------------------------------------------------
        // Parking areas
        // ------------------------------------------------------------

        composable(route = Destinations.parkingAreas) {
            ParkingAreasScreen(
                onBack = {
                    navController.popBackStack()
                },
                onSelectParkingArea = { parkingAreaId ->
                    navController.navigate(
                        Destinations.parkingAreaDetail.replace(
                            "{id}",
                            "$parkingAreaId"
                        ),
                        navOptions = NavOptions.Builder().build(),
                    )
                }
            )
        }

        composable(
            route = Destinations.parkingAreaDetail,
            arguments = listOf(navArgument("id") { type = NavType.IntType })
        ) { backStackEntry ->

            val id = backStackEntry.arguments?.getInt("id")

            id?.let {
                ParkingAreaDetailScreen(id = it, onBack = {
                    navController.popBackStack()
                })
            }

        }

        // ------------------------------------------------------------
        // Fuel Stations
        // ------------------------------------------------------------

        composable(route = Destinations.fuelList) {
            FuelStationListScreen(
                onBack = {
                    navController.popBackStack()
                },
                onShowFuelStation = { id ->
                    navController.navigate(
                        Destinations.fuelStationDetail.replace(
                            "{id}",
                            id
                        ),
                        navOptions = NavOptions.Builder().build(),
                    )
                }
            )
        }

        composable(
            route = Destinations.fuelStationDetail,
            arguments = listOf(navArgument("id") { type = NavType.StringType })
        ) { backStackEntry ->

            val id = backStackEntry.arguments?.getString("id")

            id?.let {
                FuelStationDetailScreen(id = it, onBack = {
                    navController.popBackStack()
                })
            }

        }

        // ------------------------------------------------------------
        // News
        // ------------------------------------------------------------

        composable(route = Destinations.news) {
            NewsScreen(onShowRssItem = {
                navController.navigate(
                    Destinations.showNewsWebDetail.replace(
                        "{id}",
                        it.toString()
                    )
                )
            })
        }

        // ------------------------------------------------------------
        // Explore
        // ------------------------------------------------------------

        composable(route = Destinations.explore) {
            ExploreScreen(onNavigate = { action ->
                when (action) {
                    ExploreNavigationAction.RadioBroadcasts -> {
                        navController.navigate(
                            Destinations.radioBroadcasts
                        )
                    }
                }
            })
        }

        composable(route = Destinations.radioBroadcasts) {
            BroadcastOverviewScreen(
                onOpenRadioBroadcast = { id ->
                    navController.navigate(
                        Destinations.radioBroadcastDetail.replace(
                            "{id}",
                            id.toString()
                        )
                    )
                },
                onBack = {
                    navController.popBackStack()
                }
            )
        }

        composable(
            route = Destinations.radioBroadcastDetail,
            arguments = listOf(navArgument("id") { type = NavType.IntType })
        ) { backStackEntry ->

            val id = backStackEntry.arguments?.getInt("id")

            id?.let {
                BroadcastDetailScreen(
                    id = it,
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }
        }

        composable(route = Destinations.search) {
            SearchScreen()
        }
        composable(route = Destinations.events) {
            EventOverviewScreen(onSelectEvent = {
                navController.navigate(
                    Destinations.eventDetail.replace(
                        "{id}",
                        it.toString()
                    )
                )
            })
        }

        composable(
            route = Destinations.eventDetail,
            arguments = listOf(navArgument("id") { type = NavType.IntType })
        ) { backStackEntry ->

            val id = backStackEntry.arguments?.getInt("id")

            id?.let {
                EventDetailScreen(id = it, onBack = {
                    navController.popBackStack()
                })
            }

        }

        composable(route = Destinations.settings) {
            SettingsScreen(onBack = {
                navController.popBackStack()
            })
        }

        composable(
            route = Destinations.showNewsWebDetail,
            arguments = listOf(navArgument("id") { type = NavType.IntType })
        ) { backStackEntry ->

            val id = backStackEntry.arguments?.getInt("id")

            id?.let {
                NewsWebDetailScreen(
                    id = id,
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }

        }

        composable(route = Destinations.about) {
            AboutScreen(onBack = {
                navController.popBackStack()
            })
        }

        composable(route = Destinations.feedback) {
            FeedbackScreen(onBack = {
                navController.popBackStack()
            })
        }

    }
}
