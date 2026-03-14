package com.lambdadigamma.moersfestival.ui

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.moersfestival.R

enum class AppTab(
    @param:StringRes val title: Int,
    @param:DrawableRes val inactiveIcon: Int,
    @param:DrawableRes val activeIcon: Int,
    val route: String
) {
//    DASHBOARD(
//        R.string.navigation_dashboard,
//        R.drawable.ic_outline_home_24,
//        R.drawable.ic_baseline_home_24,
//        Destinations.dashboard
//    ),
    NEWS(
        R.string.navigation_news,
        R.drawable.outline_newspaper_24,
        R.drawable.baseline_newspaper_24,
        NavigationDestination.News.route
    ),
    MAP(
        R.string.navigation_map,
        R.drawable.outline_map_24,
        R.drawable.baseline_map_24,
        NavigationDestination.Map.route
    ),
    //    EXPLORE(
//        R.string.navigation_explore,
//        R.drawable.ic_outline_explore_24,
//        R.drawable.ic_baseline_explore_24,
//        Destinations.explore
//    ),
    FAVORITES(
        R.string.navigation_favorites,
        R.drawable.outline_favorite_border_24,
        R.drawable.baseline_favorite_24,
        NavigationDestination.FavoriteEvents.route
    ),
    EVENTS(
        R.string.navigation_events,
        R.drawable.outline_calendar_month_24,
        R.drawable.baseline_calendar_month_24,
        NavigationDestination.Timetable.route
    ),
    INFOS(
        R.string.navigation_info,
        R.drawable.outline_info_24,
        R.drawable.outline_info_24,
        NavigationDestination.Info.route
    )
}