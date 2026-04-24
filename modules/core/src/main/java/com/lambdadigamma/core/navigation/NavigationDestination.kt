package com.lambdadigamma.core.navigation

sealed class NavigationDestination(
    val route: String,
) {
    data object News : NavigationDestination("posts")

    data object NewsDetail : NavigationDestination("posts/{postId}")

    data object Map : NavigationDestination("mapDestination")

    data object Timetable : NavigationDestination("timetableDestination")

    data object Info : NavigationDestination("infoDestination")

    data object Web : NavigationDestination("web?url={url}")

    data object EventDownload : NavigationDestination("download-events")

    data object FavoriteEvents : NavigationDestination("favorite-events")

    data object Events : NavigationDestination("events")

    data object EventDetail : NavigationDestination("events/{eventId}")

    data object VenueDetail : NavigationDestination("venues/{placeId}")

    data object AppInformation : NavigationDestination("app/information")

    data object AppLicenses : NavigationDestination("app/licenses")

    data object NotificationSettings : NavigationDestination("app/notifications")

    data object Back : NavigationDestination("navigationBack")
}
