package com.lambdadigamma.moers.ui

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.lambdadigamma.moers.Destinations
import com.lambdadigamma.moers.R

enum class AppTab(
    @StringRes val title: Int,
    @DrawableRes val inactiveIcon: Int,
    @DrawableRes val activeIcon: Int,
    val route: String
) {
    DASHBOARD(
        R.string.navigation_dashboard,
        R.drawable.ic_outline_home_24,
        R.drawable.ic_baseline_home_24,
        Destinations.dashboard
    ),
    NEWS(
        com.lambdadigamma.newsfeature.R.string.navigation_news,
        R.drawable.ic_outline_newspaper_24,
        R.drawable.ic_outline_newspaper_24,
        Destinations.news
    ),
    EXPLORE(
        R.string.navigation_explore,
        R.drawable.ic_outline_explore_24,
        R.drawable.ic_baseline_explore_24,
        Destinations.explore
    ),
    EVENTS(
        R.string.navigation_events,
        R.drawable.ic_outline_calendar_month_24,
        R.drawable.ic_baseline_calendar_month_24,
        Destinations.events
    ),
//    SEARCH(
//        R.string.navigation_search,
//        R.drawable.ic_baseline_search_24,
//        R.drawable.ic_baseline_search_24,
////        Icons.Outlined.Search,
////        Icons.Filled.Search,
//        Destinations.search
//    )
//    OTHER(
//        R.string.navigation_other,
//        R.drawable.ic_baseline_menu_24,
//        Destinations.other
//    ),
}