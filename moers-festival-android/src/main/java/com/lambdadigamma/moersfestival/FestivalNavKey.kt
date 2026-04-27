package com.lambdadigamma.moersfestival

import androidx.navigation3.runtime.NavKey
import kotlinx.serialization.Serializable

@Serializable
sealed interface FestivalNavKey : NavKey {
    @Serializable
    data object News : FestivalNavKey

    @Serializable
    data object Map : FestivalNavKey

    @Serializable
    data object Favorites : FestivalNavKey

    @Serializable
    data object Timetable : FestivalNavKey

    @Serializable
    data object Info : FestivalNavKey

    @Serializable
    data class NewsDetail(val postId: Int) : FestivalNavKey

    @Serializable
    data class EventDetail(val eventId: Int) : FestivalNavKey

    @Serializable
    data class VenueDetail(val placeId: Long) : FestivalNavKey

    @Serializable
    data object DownloadEvents : FestivalNavKey

    @Serializable
    data class Web(val url: String) : FestivalNavKey

    @Serializable
    data object AppInformation : FestivalNavKey

    @Serializable
    data object Licenses : FestivalNavKey

    @Serializable
    data object NotificationSettings : FestivalNavKey
}
val FestivalTopLevelNavKeys = listOf(
    FestivalNavKey.News,
    FestivalNavKey.Map,
    FestivalNavKey.Favorites,
    FestivalNavKey.Timetable,
    FestivalNavKey.Info,
)

fun FestivalNavKey.topLevelKey(): FestivalNavKey {
    return when (this) {
        FestivalNavKey.News,
        is FestivalNavKey.NewsDetail -> FestivalNavKey.News
        FestivalNavKey.Map,
        is FestivalNavKey.VenueDetail -> FestivalNavKey.Map
        FestivalNavKey.Favorites -> FestivalNavKey.Favorites
        FestivalNavKey.Timetable,
        is FestivalNavKey.EventDetail,
        FestivalNavKey.DownloadEvents -> FestivalNavKey.Timetable
        FestivalNavKey.Info,
        is FestivalNavKey.Web,
        FestivalNavKey.AppInformation,
        FestivalNavKey.Licenses,
        FestivalNavKey.NotificationSettings -> FestivalNavKey.Info
    }
}
