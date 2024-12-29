package com.lambdadigamma.moers.ui

import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.navigation.NavController
import androidx.navigation.compose.currentBackStackEntryAsState

@Composable
fun BottomBar(navController: NavController, tabs: Array<AppTab>) {

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route
        ?: AppTab.DASHBOARD.route
    val routes = remember { AppTab.values().map { it.route } }

    if (currentRoute in routes) {

        NavigationBar {
            tabs.forEach { tab ->
                NavigationBarItem(
                    icon = {
                        if (tab.route == currentRoute) {
                            Icon(painterResource(id = tab.activeIcon), contentDescription = null)
                        } else {
                            Icon(painterResource(id = tab.inactiveIcon), contentDescription = null)
                        }
                    },
                    label = {
                        Text(text = stringResource(id = tab.title))
                    },
                    selected = currentRoute == tab.route,
                    onClick = {
                        if (tab.route != currentRoute) {
                            navController.navigate(tab.route) {
                                popUpTo(navController.graph.startDestinationId) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    }
                )
            }
        }
    }

}