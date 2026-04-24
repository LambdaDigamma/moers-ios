package com.lambdadigamma.events.presentation

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.material3.Scaffold
import androidx.navigation.NavDeepLinkBuilder
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavType
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import androidx.navigation.navDeepLink
import com.lambdadigamma.core.navigation.NavigationCommand
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.core.navigation.NavigationManager
import com.lambdadigamma.events.presentation.timetable.composable.TimetableRoute
import com.lambdadigamma.events.presentation.detail.composable.EventDetailRoute
import com.lambdadigamma.events.presentation.download.DownloadEventsRoute
import com.lambdadigamma.events.presentation.favorites.composable.FavoriteEventsRoute
import com.lambdadigamma.events.presentation.venue.composable.VenueDetailRoute
import javax.inject.Inject

@OptIn(ExperimentalFoundationApi::class)
class EventsNavigationFactory @Inject constructor() : NavigationFactory {

    @Inject
    lateinit var navigationManager: NavigationManager

    override fun create(builder: NavGraphBuilder) {
        builder.composable(
            route = NavigationDestination.Timetable.route,
            deepLinks = listOf(
                navDeepLink { uriPattern = "moersfestival://events" }
            )
        ) {
            TimetableRoute(
                onShowEvent = { id ->
                    val command = object : NavigationCommand {
                        override val destination = NavigationDestination.EventDetail.route.replace("{eventId}", id.toString())
                    }
                    navigationManager.navigate(command)
                },
                onShowDownload = {
                    val command = object : NavigationCommand {
                        override val destination = NavigationDestination.EventDownload.route
                    }
                    navigationManager.navigate(command)
                }
            )
        }
        builder.composable(
            route = NavigationDestination.FavoriteEvents.route,
            deepLinks = listOf(
                navDeepLink { uriPattern = "moersfestival://favorites" }
            )
        ) {
            FavoriteEventsRoute(
                onShowEvent = { id ->
                    val command = object : NavigationCommand {
                        override val destination = NavigationDestination.EventDetail.route.replace("{eventId}", id.toString())
                    }
                    navigationManager.navigate(command)
                },
                onShowTimetable = {
                    val command = object : NavigationCommand {
                        override val destination = NavigationDestination.Timetable.route
                    }
                    navigationManager.navigate(command)
                },
            )
        }
        builder.composable(
            route = NavigationDestination.EventDownload.route,
            deepLinks = listOf(
                navDeepLink { uriPattern = "moersfestival://download-events" }
            )
        ) {
            DownloadEventsRoute(onBack = {
                navigationManager.navigateBack()
            })
        }
        builder.composable(
            route = NavigationDestination.EventDetail.route,
            arguments = listOf(navArgument("eventId") { type = NavType.IntType }),
            deepLinks = listOf(
                navDeepLink { uriPattern = "moersfestival://events/{eventId}" }
            )
        ) { backStackEntry ->
            val eventId = checkNotNull(backStackEntry.arguments?.getInt("eventId"))
            EventDetailRoute(
                eventId = eventId,
                onBack = {
                    navigationManager.navigateBack()
                },
                onShowVenue = { placeId ->
                    val command = object : NavigationCommand {
                        override val destination = NavigationDestination.VenueDetail.route
                            .replace("{placeId}", placeId.toString())
                    }
                    navigationManager.navigate(command)
                },
            )
        }
        builder.composable(
            route = NavigationDestination.VenueDetail.route,
            arguments = listOf(navArgument("placeId") { type = NavType.LongType }),
            deepLinks = listOf(
                navDeepLink { uriPattern = "moersfestival://venues/{placeId}" }
            )
        ) { backStackEntry ->
            val placeId = checkNotNull(backStackEntry.arguments?.getLong("placeId"))
            VenueDetailRoute(
                placeId = placeId,
                onBack = {
                    navigationManager.navigateBack()
                },
                onShowEvent = { id ->
                    val command = object : NavigationCommand {
                        override val destination = NavigationDestination.EventDetail.route.replace("{eventId}", id.toString())
                    }
                    navigationManager.navigate(command)
                },
            )
        }
    }
}
