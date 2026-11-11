package com.lambdadigamma.moers.ui

import androidx.annotation.StringRes
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Newspaper
import androidx.compose.material.icons.outlined.CalendarMonth
import androidx.compose.material.icons.outlined.Explore
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Newspaper
import androidx.compose.ui.graphics.vector.ImageVector
import com.lambdadigamma.moers.Destinations
import com.lambdadigamma.moers.R

enum class AppTab(
    @StringRes val title: Int,
    val inactiveIcon: ImageVector,
    val activeIcon: ImageVector,
    /** Route of the nested navigation graph of this tab. */
    val route: String,
    /** Route of the first screen of this tab. */
    val startRoute: String,
) {
    DASHBOARD(
        R.string.navigation_dashboard,
        Icons.Outlined.Home,
        Icons.Filled.Home,
        Destinations.Tabs.dashboard,
        Destinations.dashboard,
    ),
    NEWS(
        com.lambdadigamma.news.R.string.navigation_news,
        Icons.Outlined.Newspaper,
        Icons.Filled.Newspaper,
        Destinations.Tabs.news,
        Destinations.news,
    ),
    EXPLORE(
        R.string.navigation_explore,
        Icons.Outlined.Explore,
        Icons.Filled.Explore,
        Destinations.Tabs.explore,
        Destinations.explore,
    ),
    EVENTS(
        R.string.navigation_events,
        Icons.Outlined.CalendarMonth,
        Icons.Filled.CalendarMonth,
        Destinations.Tabs.events,
        Destinations.events,
    ),
}
