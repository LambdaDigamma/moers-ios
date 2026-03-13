package com.lambdadigamma.moersfestival

import androidx.compose.material3.Text
import androidx.navigation.NavGraphBuilder
import androidx.navigation.compose.composable
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.core.navigation.NavigationManager
import com.lambdadigamma.moersfestival.ui.AppInformationRoute
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

        builder.composable(NavigationDestination.Info.route) {
            InfoScreen()
        }

    }

}
