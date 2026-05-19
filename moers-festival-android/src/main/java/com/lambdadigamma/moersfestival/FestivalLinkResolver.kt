package com.lambdadigamma.moersfestival

import android.content.Intent
import android.net.Uri
import java.util.Locale

internal const val FESTIVAL_LEGAL_URL = "https://www.moers-festival.de/start/impressum/"

internal fun Intent.resolveFestivalStack(): List<FestivalNavKey>? {
    return data?.resolveFestivalStack()
}

internal fun Uri.resolveFestivalStack(): List<FestivalNavKey>? {
    return resolveFestivalStack(
        scheme = scheme,
        host = host,
        pathSegments = pathSegments,
        rawUrl = toString(),
    )
}

internal fun resolveFestivalStack(
    scheme: String?,
    host: String?,
    pathSegments: List<String>,
    rawUrl: String,
): List<FestivalNavKey>? {
    return when {
        scheme.equals("moersfestival", ignoreCase = true) -> resolveCustomSchemeStack(
            rawUrl = rawUrl,
            host = host,
            pathSegments = pathSegments,
        )
        isMoersAppLink(scheme = scheme, host = host) -> resolveHttpsStack(
            pathSegments = pathSegments,
            rawUrl = rawUrl,
        )
        else -> null
    }
}

private fun resolveCustomSchemeStack(
    rawUrl: String,
    host: String?,
    pathSegments: List<String>,
): List<FestivalNavKey>? {
    if (!rawUrl.startsWith("moersfestival:///")) return null
    if (!host.isNullOrBlank()) return null

    return resolveCanonicalCustomStack(routeSegments(pathSegments))
}

private fun resolveHttpsStack(
    pathSegments: List<String>,
    rawUrl: String,
): List<FestivalNavKey> {
    return resolveKnownStack(
        components = routeSegments(pathSegments),
        fallbackUrl = rawUrl,
    ) ?: listOf(FestivalNavKey.Info, FestivalNavKey.Web(rawUrl))
}

private fun routeSegments(
    pathSegments: List<String>,
): List<String> {
    return pathSegments.mapNotNull { segment ->
        segment
            .trim()
            .takeIf(String::isNotEmpty)
            ?.lowercase(Locale.ROOT)
    }
}

private fun resolveCanonicalCustomStack(
    components: List<String>,
): List<FestivalNavKey>? {
    val first = components.firstOrNull() ?: return null
    val second = components.getOrNull(1)

    return when {
        components.size == 1 && first == "posts" -> listOf(FestivalNavKey.News)
        components.size == 2 && first == "posts" -> {
            second?.toIntOrNull()?.let { postId ->
                listOf(FestivalNavKey.News, FestivalNavKey.NewsDetail(postId))
            } ?: listOf(FestivalNavKey.News)
        }

        components.size == 1 && first == "events" -> listOf(FestivalNavKey.Timetable)
        components.size == 2 && first == "events" -> {
            second?.toIntOrNull()?.let { eventId ->
                listOf(FestivalNavKey.Timetable, FestivalNavKey.EventDetail(eventId))
            } ?: listOf(FestivalNavKey.Timetable)
        }

        components.size == 1 && first == "favorites" -> listOf(FestivalNavKey.Favorites)
        components.size == 1 && first == "map" -> listOf(FestivalNavKey.Map)
        components.size == 1 && first == "venues" -> listOf(FestivalNavKey.Map)
        components.size == 2 && first == "venues" -> {
            second?.toLongOrNull()?.let { placeId ->
                listOf(FestivalNavKey.Map, FestivalNavKey.VenueDetail(placeId))
            } ?: listOf(FestivalNavKey.Map)
        }

        components.size == 1 && first == "download-events" -> listOf(
            FestivalNavKey.Timetable,
            FestivalNavKey.DownloadEvents,
        )

        components.size == 1 && first == "info" -> listOf(FestivalNavKey.Info)
        components.size == 1 && first == "legal" -> listOf(
            FestivalNavKey.Info,
            FestivalNavKey.Web(FESTIVAL_LEGAL_URL),
        )

        else -> null
    }
}

private fun resolveKnownStack(
    components: List<String>,
    fallbackUrl: String?,
): List<FestivalNavKey>? {
    val first = components.firstOrNull() ?: return listOf(FestivalNavKey.Timetable)
    val second = components.getOrNull(1)

    return when (first) {
        "posts", "post", "news", "neuigkeiten" -> {
            second?.toIntOrNull()?.let { postId ->
                listOf(FestivalNavKey.News, FestivalNavKey.NewsDetail(postId))
            } ?: listOf(FestivalNavKey.News)
        }

        "events", "event", "spielplan", "schedule", "veranstaltungen" -> {
            second?.toIntOrNull()?.let { eventId ->
                listOf(FestivalNavKey.Timetable, FestivalNavKey.EventDetail(eventId))
            } ?: listOf(FestivalNavKey.Timetable)
        }

        "favorites", "favourites", "schedule-user" -> listOf(FestivalNavKey.Favorites)
        "venues", "venue", "places", "place", "map", "maps", "spielorte" -> {
            second?.toLongOrNull()?.let { placeId ->
                listOf(FestivalNavKey.Map, FestivalNavKey.VenueDetail(placeId))
            } ?: listOf(FestivalNavKey.Map)
        }

        "download-events", "download", "offline" -> listOf(
            FestivalNavKey.Timetable,
            FestivalNavKey.DownloadEvents,
        )

        "info", "infos", "tickets" -> listOf(FestivalNavKey.Info)

        "impressum", "legal" -> listOf(FestivalNavKey.Info, FestivalNavKey.Web(FESTIVAL_LEGAL_URL))

        else -> fallbackUrl?.let { listOf(FestivalNavKey.Info, FestivalNavKey.Web(it)) }
    }
}

private fun isMoersAppLink(
    scheme: String?,
    host: String?,
): Boolean {
    return scheme.equals("https", ignoreCase = true) &&
        host.orEmpty().lowercase(Locale.ROOT) in setOf("moers.app", "www.moers.app")
}
