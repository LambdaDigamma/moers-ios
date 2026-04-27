package com.lambdadigamma.moersfestival

import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavType
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.core.navigation.NavigationManager
import com.lambdadigamma.moersfestival.setup.NotificationSettingsRoute
import com.lambdadigamma.moersfestival.ui.AppInformationRoute
import com.lambdadigamma.moersfestival.ui.LicensesRoute
import javax.inject.Inject

class AppMetaNavigationFactory @Inject constructor() : NavigationFactory {

    @Inject
    lateinit var navigationManager: NavigationManager

    override fun create(builder: NavGraphBuilder) {

        builder.composable(NavigationDestination.AppInformation.route) {
            AppInformationRoute(onBack = {
                navigationManager.navigateBack()
            })
        }

        builder.composable(NavigationDestination.AppLicenses.route) {
            LicensesRoute(onBack = {
                navigationManager.navigateBack()
            })
        }

        builder.composable(NavigationDestination.Info.route) {
            InfoScreen(navigationManager = navigationManager)
        }

        builder.composable(NavigationDestination.NotificationSettings.route) {
            NotificationSettingsRoute(onBack = {
                navigationManager.navigateBack()
            })
        }

        builder.composable(
            route = NavigationDestination.Web.route,
            arguments = listOf(navArgument("url") { type = NavType.StringType })
        ) { backStackEntry ->
            val url = backStackEntry.arguments?.getString("url") ?: ""
            WebViewScreen(url = url, onBack = {
                navigationManager.navigateBack()
            })
        }

    }

}
