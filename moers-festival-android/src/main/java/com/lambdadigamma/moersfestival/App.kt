package com.lambdadigamma.moersfestival

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.navigation.compose.rememberNavController
import com.lambdadigamma.core.extensions.collectWithLifecycle
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.core.navigation.NavigationHost
import com.lambdadigamma.core.navigation.NavigationManager
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.moersfestival.ui.AppTab
import com.lambdadigamma.moersfestival.ui.BottomBar

@Composable
fun App(
    navigationManager: NavigationManager,
    navigationFactories: Set<NavigationFactory>,
    finishActivity: () -> Unit,
    askNotificationPermission: () -> Unit
) {

    MoersFestivalTheme {
        val navController = rememberNavController()

        LaunchedEffect(key1 = "CheckLaunch", block = {
            askNotificationPermission()
        })

        Scaffold(bottomBar = {
            BottomBar(navController = navController, tabs = AppTab.entries.toTypedArray())
        }) { padding ->
            NavigationHost(
                modifier = Modifier
                    .padding(bottom = padding.calculateBottomPadding()),
                navController = navController,
                factories = navigationFactories,
            )
        }


        navigationManager
            .navigationEvent
            .collectWithLifecycle(
                key = navController,
            ) {
                when (it.destination) {
                    NavigationDestination.Back.route -> navController.navigateUp()
                    else -> navController.navigate(it.destination, it.configuration)
                }
            }
    }

}