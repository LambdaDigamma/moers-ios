package com.lambdadigamma.moers.ui

import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteScaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.res.stringResource
import androidx.navigation.NavDestination
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.lambdadigamma.moers.NavGraph
import com.lambdadigamma.moers.OnboardingNavigationGraph

@Composable
fun Onboarding() {
    OnboardingNavigationGraph()
}

/**
 * The main app shell. Shows a navigation bar on phones and a navigation rail on larger windows.
 * Every tab keeps its own back stack.
 */
@Composable
fun App() {
    val navController = rememberNavController()
    val backStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = backStackEntry?.destination

    NavigationSuiteScaffold(
        navigationSuiteItems = {
            AppTab.entries.forEach { tab ->
                val selected = currentDestination.isInTab(tab)
                item(
                    selected = selected,
                    onClick = { navController.navigateToTab(tab, reselect = selected) },
                    icon = {
                        Icon(
                            imageVector = if (selected) tab.activeIcon else tab.inactiveIcon,
                            contentDescription = null,
                        )
                    },
                    label = { Text(stringResource(tab.title)) },
                )
            }
        },
    ) {
        NavGraph(navController = navController)
    }
}

private fun NavDestination?.isInTab(tab: AppTab): Boolean =
    this?.hierarchy?.any { it.route == tab.route } == true

private fun NavHostController.navigateToTab(tab: AppTab, reselect: Boolean) {
    if (reselect) {
        // Selecting the current tab again returns to its root screen.
        popBackStack(tab.startRoute, inclusive = false)
        return
    }
    navigate(tab.route) {
        popUpTo(graph.findStartDestination().id) {
            saveState = true
        }
        launchSingleTop = true
        restoreState = true
    }
}
