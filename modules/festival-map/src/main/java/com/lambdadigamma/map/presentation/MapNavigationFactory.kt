package com.lambdadigamma.map.presentation

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.navigation.NavGraphBuilder
import androidx.navigation.compose.composable
import androidx.navigation.navDeepLink
import com.lambdadigamma.core.navigation.NavigationCommand
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.core.navigation.NavigationManager
import com.lambdadigamma.map.presentation.composable.MapRoute
import javax.inject.Inject

@OptIn(ExperimentalFoundationApi::class)
class MapNavigationFactory @Inject constructor() : NavigationFactory {

    @Inject
    lateinit var navigationManager: NavigationManager

    override fun create(builder: NavGraphBuilder) {
        builder.composable(
            route = NavigationDestination.Map.route,
            deepLinks = listOf(
                navDeepLink { uriPattern = "moersfestival://maps" }
            )
        ) {
            MapRoute(
                onShowPlace = { placeId ->
                    val command = object : NavigationCommand {
                        override val destination = NavigationDestination.VenueDetail.route.replace("{placeId}", placeId.toString())
                    }
                    navigationManager.navigate(command)
                },
            )
        }
    }
}
