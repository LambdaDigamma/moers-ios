package com.lambdadigamma.moers

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import androidx.navigation.navigation
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
import com.lambdadigamma.moers.settings.RubbishStreetScreen
import com.lambdadigamma.moers.settings.SettingsScreen
import com.lambdadigamma.newsfeature.ui.NewsScreen
import com.lambdadigamma.parking.detail.ParkingAreaDetailScreen
import com.lambdadigamma.parking.list.ParkingAreasScreen
import com.lambdadigamma.radio.detail.BroadcastDetailScreen
import com.lambdadigamma.radio.overview.BroadcastOverviewScreen
import com.lambdadigamma.rubbish.ui.RubbishListScreen

@Composable
fun NavGraph(
    modifier: Modifier = Modifier,
    navController: NavHostController = rememberNavController(),
) {
    NavHost(
        navController = navController,
        startDestination = Destinations.Tabs.dashboard,
        modifier = modifier,
    ) {
        dashboardGraph(navController)
        newsGraph()
        exploreGraph(navController)
        eventsGraph(navController)
    }
}

private fun NavGraphBuilder.dashboardGraph(navController: NavHostController) {
    navigation(startDestination = Destinations.dashboard, route = Destinations.Tabs.dashboard) {
        composable(route = Destinations.dashboard) {
            DashboardScreen(
                onOpenSettings = { navController.navigate(Destinations.settings) },
                onAction = { action ->
                    when (action) {
                        DashboardAction.Rubbish -> navController.navigate(Destinations.rubbishList)
                        DashboardAction.ChooseStreet -> navController.navigate(Destinations.rubbishStreet)
                        DashboardAction.Fuel -> navController.navigate(Destinations.fuelList)
                        DashboardAction.Parking -> navController.navigate(Destinations.parkingAreas)
                        DashboardAction.About -> navController.navigate(Destinations.about)
                        DashboardAction.Feedback -> navController.navigate(Destinations.feedback)
                    }
                },
            )
        }

        composable(route = Destinations.rubbishList) {
            RubbishListScreen(
                onBack = navController::popBackStack,
                onChangeStreet = { navController.navigate(Destinations.rubbishStreet) },
            )
        }

        composable(route = Destinations.rubbishStreet) {
            RubbishStreetScreen(onBack = navController::popBackStack)
        }

        composable(route = Destinations.parkingAreas) {
            ParkingAreasScreen(
                onBack = navController::popBackStack,
                onSelectParkingArea = { parkingAreaId ->
                    navController.navigate(
                        Destinations.parkingAreaDetail.replace("{id}", "$parkingAreaId")
                    )
                },
            )
        }

        composable(
            route = Destinations.parkingAreaDetail,
            arguments = listOf(navArgument("id") { type = NavType.IntType }),
        ) { backStackEntry ->
            backStackEntry.arguments?.getInt("id")?.let { id ->
                ParkingAreaDetailScreen(id = id, onBack = navController::popBackStack)
            }
        }

        composable(route = Destinations.fuelList) {
            FuelStationListScreen(
                onBack = navController::popBackStack,
                onShowFuelStation = { id ->
                    navController.navigate(Destinations.fuelStationDetail.replace("{id}", id))
                },
            )
        }

        composable(
            route = Destinations.fuelStationDetail,
            arguments = listOf(navArgument("id") { type = NavType.StringType }),
        ) { backStackEntry ->
            backStackEntry.arguments?.getString("id")?.let { id ->
                FuelStationDetailScreen(id = id, onBack = navController::popBackStack)
            }
        }

        composable(route = Destinations.settings) {
            SettingsScreen(
                onBack = navController::popBackStack,
                onChooseStreet = { navController.navigate(Destinations.rubbishStreet) },
            )
        }

        composable(route = Destinations.about) {
            AboutScreen(onBack = navController::popBackStack)
        }

        composable(route = Destinations.feedback) {
            FeedbackScreen(onBack = navController::popBackStack)
        }
    }
}

private fun NavGraphBuilder.newsGraph() {
    navigation(startDestination = Destinations.news, route = Destinations.Tabs.news) {
        composable(route = Destinations.news) {
            NewsScreen()
        }
    }
}

private fun NavGraphBuilder.exploreGraph(navController: NavHostController) {
    navigation(startDestination = Destinations.explore, route = Destinations.Tabs.explore) {
        composable(route = Destinations.explore) {
            ExploreScreen(onNavigate = { action ->
                when (action) {
                    ExploreNavigationAction.RadioBroadcasts ->
                        navController.navigate(Destinations.radioBroadcasts)
                }
            })
        }

        composable(route = Destinations.radioBroadcasts) {
            BroadcastOverviewScreen(
                onOpenRadioBroadcast = { id ->
                    navController.navigate(Destinations.radioBroadcastDetail.replace("{id}", "$id"))
                },
                onBack = navController::popBackStack,
            )
        }

        composable(
            route = Destinations.radioBroadcastDetail,
            arguments = listOf(navArgument("id") { type = NavType.IntType }),
        ) { backStackEntry ->
            backStackEntry.arguments?.getInt("id")?.let { id ->
                BroadcastDetailScreen(id = id, onBack = navController::popBackStack)
            }
        }
    }
}

private fun NavGraphBuilder.eventsGraph(navController: NavHostController) {
    navigation(startDestination = Destinations.events, route = Destinations.Tabs.events) {
        composable(route = Destinations.events) {
            EventOverviewScreen(onSelectEvent = { id ->
                navController.navigate(Destinations.eventDetail.replace("{id}", "$id"))
            })
        }

        composable(
            route = Destinations.eventDetail,
            arguments = listOf(navArgument("id") { type = NavType.IntType }),
        ) { backStackEntry ->
            backStackEntry.arguments?.getInt("id")?.let { id ->
                EventDetailScreen(id = id, onBack = navController::popBackStack)
            }
        }
    }
}
