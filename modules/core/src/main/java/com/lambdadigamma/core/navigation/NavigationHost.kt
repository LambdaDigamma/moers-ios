package com.lambdadigamma.core.navigation

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import com.google.accompanist.systemuicontroller.rememberSystemUiController

@Composable
fun NavigationHost(
    navController: NavHostController,
    factories: Set<NavigationFactory>,
    modifier: Modifier = Modifier,
) {
    rememberSystemUiController().setStatusBarColor(
        MaterialTheme.colorScheme.background, darkIcons = !isSystemInDarkTheme()
    )

    NavHost(
        navController = navController,
        startDestination = NavigationDestination.Timetable.route,
        modifier = modifier,
    ) {
        factories.forEach {
            it.create(this)
        }
    }
}
