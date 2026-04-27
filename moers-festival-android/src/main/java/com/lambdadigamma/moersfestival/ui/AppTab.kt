package com.lambdadigamma.moersfestival.ui

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.lambdadigamma.moersfestival.FestivalNavKey
import com.lambdadigamma.moersfestival.R

enum class AppTab(
    @param:StringRes val title: Int,
    @param:DrawableRes val inactiveIcon: Int,
    @param:DrawableRes val activeIcon: Int,
    val key: FestivalNavKey,
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
        FestivalNavKey.News,
    ),
    MAP(
        R.string.navigation_map,
        R.drawable.outline_map_24,
        R.drawable.baseline_map_24,
        FestivalNavKey.Map,
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
        FestivalNavKey.Favorites,
    ),
    EVENTS(
        R.string.navigation_events,
        R.drawable.outline_calendar_month_24,
        R.drawable.baseline_calendar_month_24,
        FestivalNavKey.Timetable,
    ),
    INFOS(
        R.string.navigation_info,
        R.drawable.outline_info_24,
        R.drawable.outline_info_24,
        FestivalNavKey.Info,
    )
}
